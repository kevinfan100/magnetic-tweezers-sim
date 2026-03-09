%% fit_charge_model_6coil.m  -  Fit point-charge model using all 6 coil simulations
%  Two analyses:
%    1. Per-coil: fit (ell, R_a) independently for each coil
%    2. Joint: fit shared (ell, R_a) using stacked data from all 6 coils
%  Fitting region: 100 um cube at WP center (dissertation approach)
%
%  Sign convention (verified empirically from FEM center-field direction):
%    APDL SOURC36 winding: positive current drives flux INTO the pole for
%    lower poles, but OUT of the pole for upper poles. To unify the model,
%    we apply coil_sign = +1 (lower) / -1 (upper) to I_vec, so that
%    I_eff = coil_sign * I_nominal makes the excited pole always a SINK.
%
%  Mathematical formulation:
%    Model (Eq. 2.2-2.4):
%      B_model(p) = k_m * sum_i Q_i * (p - c_i) / |p - c_i|^3
%      c_i = ell * d_i          (charge positions, shared ell, b=0)
%      Q = -(N_c/(mu_0*R_a)) * K_I * I_eff
%
%    Since B is proportional to 1/R_a, define C = N_c/(mu_0*R_a):
%      B_model = C * B_unit(ell)     where B_unit uses R_a_unit = N_c/mu_0
%
%    For given ell, solve C analytically (linear least-squares):
%      C_opt(ell) = (b_unit' * b_fem) / (b_unit' * b_unit)
%      R_a = N_c / (mu_0 * C_opt)
%
%    Joint fit: stack B_unit and B_fem from all 6 coils, solve single C_opt
%      b_unit_all = [b_unit_1; ...; b_unit_6]   (each with different I_vec)
%      C_opt = (b_unit_all' * b_fem_all) / (b_unit_all' * b_unit_all)
%
%    Minimize J(ell) = ||C_opt(ell) * b_unit_all(ell) - b_fem_all||^2
%    via 1D scan + fminbnd refinement.

%% 1. Setup
c = mt_constants();
K_I = eye(6) - ones(6)/6;   % Nominal K_I (Eq. 2.8)

% APDL coil index -> Paper pole index
%   APDL [1,2,3,4,5,6] -> Paper [P1,P3,P6,P5,P2,P4] -> index [1,3,6,5,2,4]
apdl_to_paper_idx = [1, 3, 6, 5, 2, 4];

%% 2. Load and preprocess all 6 coils
fprintf('Loading 6 coil simulations...\n');
N_coils = 6;
coils = struct('x',{},'y',{},'z',{},'bx',{},'by',{},'bz',{}, ...
    'air_mask',{},'I_vec',{},'pole',{},'is_lower',{});

for k = 1:N_coils
    coilname = sprintf('coil%d', k);
    data = import_ansys_data(fullfile('..', 'results', coilname), 'wp', coilname);

    % Iron exclusion (geometric, identical for all coils)
    [air_mask, ~] = filter_iron_nodes(data.x, data.y, data.z, c, ...
        struct('visualize', false));

    % Convert z to WP frame
    z_wp = data.z - c.SPH_OFST;

    % Build I_vec in paper pole order (P1-P6)
    % Apply coil_sign: +1 for lower poles, -1 for upper poles
    % (APDL SOURC36 winding drives flux OUT of upper poles for positive I)
    paper_idx = apdl_to_paper_idx(k);
    coil_sign = 1 - 2 * (1 - c.pole_is_lower(paper_idx));  % +1 lower, -1 upper
    I_vec = zeros(6,1);
    I_vec(paper_idx) = coil_sign;

    coils(k).x = data.x;
    coils(k).y = data.y;
    coils(k).z = z_wp;
    coils(k).bx = data.bx;
    coils(k).by = data.by;
    coils(k).bz = data.bz;
    coils(k).air_mask = air_mask;
    coils(k).I_vec = I_vec;
    coils(k).pole = c.apdl_to_paper{k};
    coils(k).is_lower = c.pole_is_lower(paper_idx);

    layer = 'Upper';
    if coils(k).is_lower, layer = 'Lower'; end
    fprintf('  Coil %d -> %s (%s): %d air nodes\n', ...
        k, coils(k).pole, layer, sum(air_mask));
end

%% 3. Build fitting region masks (100 um cube at WP center)
cube_half = 50e-6;   % +/-50 um

for k = 1:N_coils
    coils(k).fit_mask = coils(k).air_mask & ...
        abs(coils(k).x) < cube_half & ...
        abs(coils(k).y) < cube_half & ...
        abs(coils(k).z) < cube_half;
end

%% 4. Per-coil individual fits
fprintf('\n========== Per-Coil Individual Fits (100 um cube) ==========\n');

per_coil = struct('ell',{},'R_a',{},'C',{},'err',{},'N',{},'pole',{},'is_lower',{});

for k = 1:N_coils
    mask = coils(k).fit_mask;
    p_wp = [coils(k).x(mask), coils(k).y(mask), coils(k).z(mask)];
    b_fem = [coils(k).bx(mask); coils(k).by(mask); coils(k).bz(mask)];

    [ell_k, R_a_k, C_k, err_k] = fit_ell_1d(p_wp, b_fem, coils(k).I_vec, K_I, c);

    per_coil(k).ell = ell_k;
    per_coil(k).R_a = R_a_k;
    per_coil(k).C   = C_k;
    per_coil(k).err = err_k;
    per_coil(k).N   = sum(mask);
    per_coil(k).pole = coils(k).pole;
    per_coil(k).is_lower = coils(k).is_lower;

    layer = 'Upper';
    if coils(k).is_lower, layer = 'Lower'; end
    fprintf('  Coil %d (%s, %s): ell = %6.1f um, R_a = %.3e, mean err = %.2f%%, N = %d\n', ...
        k, coils(k).pole, layer, ell_k*1e6, R_a_k, 100*err_k.mean_rel, sum(mask));
end

%% 5. Joint fit: shared (ell, R_a) from all 6 coils
fprintf('\n========== Joint Fit: All 6 Coils (100 um cube) ==========\n');

% Collect per-coil data for joint fitting
joint_data = struct('p_wp',{},'b_fem',{},'I_vec',{});
for k = 1:N_coils
    mask = coils(k).fit_mask;
    joint_data(k).p_wp  = [coils(k).x(mask), coils(k).y(mask), coils(k).z(mask)];
    joint_data(k).b_fem = [coils(k).bx(mask); coils(k).by(mask); coils(k).bz(mask)];
    joint_data(k).I_vec = coils(k).I_vec;
end

[ell_joint, R_a_joint, C_joint, err_joint] = fit_ell_joint(joint_data, K_I, c);

fprintf('  Joint: ell = %.1f um, R_a = %.3e, mean err = %.2f%%\n', ...
    ell_joint*1e6, R_a_joint, 100*err_joint.mean_rel);

%% 6. Summary table
fprintf('\n========== Summary ==========\n');
fprintf('%-6s  %-6s  %10s  %12s  %10s  %10s\n', ...
    'Pole', 'Layer', 'ell [um]', 'R_a [A/Wb]', 'Mean [%]', 'Median [%]');
fprintf('%s\n', repmat('-', 1, 62));

for k = 1:N_coils
    layer = 'Upper';
    if per_coil(k).is_lower, layer = 'Lower'; end
    fprintf('%-6s  %-6s  %10.1f  %12.3e  %10.2f  %10.2f\n', ...
        per_coil(k).pole, layer, per_coil(k).ell*1e6, per_coil(k).R_a, ...
        100*per_coil(k).err.mean_rel, 100*per_coil(k).err.median_rel);
end

fprintf('%s\n', repmat('-', 1, 62));
fprintf('%-6s  %-6s  %10.1f  %12.3e  %10.2f  %10.2f\n', ...
    'Joint', 'All', ell_joint*1e6, R_a_joint, ...
    100*err_joint.mean_rel, 100*err_joint.median_rel);
fprintf('%-6s  %-6s  %10.1f  %12.3e\n', 'Diss.', 'Ref', 900.0, 6.3e8);

% Lower vs Upper statistics
lower_idx = find([per_coil.is_lower] == 1);
upper_idx = find([per_coil.is_lower] == 0);

ell_lower_avg = mean([per_coil(lower_idx).ell]);
ell_upper_avg = mean([per_coil(upper_idx).ell]);
R_a_lower_avg = mean([per_coil(lower_idx).R_a]);
R_a_upper_avg = mean([per_coil(upper_idx).R_a]);

fprintf('\n--- Lower vs Upper ---\n');
fprintf('Lower (P1,P3,P6): avg ell = %.1f um, avg R_a = %.3e\n', ...
    ell_lower_avg*1e6, R_a_lower_avg);
fprintf('Upper (P2,P4,P5): avg ell = %.1f um, avg R_a = %.3e\n', ...
    ell_upper_avg*1e6, R_a_upper_avg);
fprintf('Difference: delta_ell = %.1f um (%.1f%%)\n', ...
    (ell_upper_avg - ell_lower_avg)*1e6, ...
    100*(ell_upper_avg - ell_lower_avg)/ell_lower_avg);

%% 7. Figures

% --- Fig 1: Per-coil ell and R_a bar chart ---
figure('Name', 'Per-Coil Fit Parameters', 'Position', [50 50 900 600]);

% Sort by pole name for display
pole_names = {per_coil.pole};
ells = [per_coil.ell] * 1e6;
R_as = [per_coil.R_a] * 1e-8;
is_lower = [per_coil.is_lower];

% Colors: blue = lower, red = upper
clr_lower = [0.2 0.4 0.8];
clr_upper = [0.85 0.3 0.2];

subplot(2,1,1);
hold on;
h_lo = []; h_up = [];
for k = 1:N_coils
    if is_lower(k)
        h = bar(k, ells(k), 'FaceColor', clr_lower, 'EdgeColor', 'k');
        if isempty(h_lo), h_lo = h; end
    else
        h = bar(k, ells(k), 'FaceColor', clr_upper, 'EdgeColor', 'k');
        if isempty(h_up), h_up = h; end
    end
end
h_j = yline(ell_joint*1e6, 'k--', 'LineWidth', 1.5);
h_d = yline(900, 'g--', 'LineWidth', 1.5);
hold off;
set(gca, 'XTick', 1:N_coils, 'XTickLabel', pole_names);
ylabel('\ell [\mum]');
title('Fitted \ell per Coil');
legend([h_lo, h_up, h_j, h_d], {'Lower', 'Upper', ...
    sprintf('Joint = %.0f \\mum', ell_joint*1e6), ...
    'Diss. = 900 \\mum'}, 'Location', 'best');
grid on;

subplot(2,1,2);
hold on;
for k = 1:N_coils
    if is_lower(k)
        bar(k, R_as(k), 'FaceColor', clr_lower, 'EdgeColor', 'k');
    else
        bar(k, R_as(k), 'FaceColor', clr_upper, 'EdgeColor', 'k');
    end
end
yline(R_a_joint*1e-8, 'k--', 'LineWidth', 1.5);
yline(6.3, 'g--', 'LineWidth', 1.5);
hold off;
set(gca, 'XTick', 1:N_coils, 'XTickLabel', pole_names);
ylabel('\Re_a [10^8 A/Wb]');
title('Fitted \Re_a per Coil');
grid on;

% --- Fig 2: Per-coil error comparison ---
figure('Name', 'Per-Coil Fitting Error', 'Position', [100 100 800 400]);
err_mean_vals = cellfun(@(e) e.mean_rel, {per_coil.err}) * 100;
err_med_vals  = cellfun(@(e) e.median_rel, {per_coil.err}) * 100;

hold on;
bar_data = [err_mean_vals; err_med_vals]';
b = bar(bar_data);
b(1).FaceColor = [0.3 0.5 0.8];
b(2).FaceColor = [0.8 0.5 0.3];
yline(100*err_joint.mean_rel, 'k--', sprintf('Joint mean = %.2f%%', 100*err_joint.mean_rel), ...
    'LineWidth', 1.5);
hold off;
set(gca, 'XTick', 1:N_coils, 'XTickLabel', pole_names);
ylabel('Relative Error [%]');
title('Fitting Error per Coil (100 \mum cube)');
legend('Mean', 'Median', 'Location', 'best');
grid on;

%% 8. Save results
results.per_coil   = per_coil;
results.joint.ell  = ell_joint;
results.joint.R_a  = R_a_joint;
results.joint.C    = C_joint;
results.joint.err  = err_joint;
results.K_I        = K_I;
results.fit_region = '100 um cube';
results.lower_avg  = struct('ell', ell_lower_avg, 'R_a', R_a_lower_avg);
results.upper_avg  = struct('ell', ell_upper_avg, 'R_a', R_a_upper_avg);

save(fullfile('..', 'data', 'charge_model_6coil_fit.mat'), '-struct', 'results');
fprintf('\nSaved to data/charge_model_6coil_fit.mat\n');


%% ===== Local functions =====

function [ell, R_a, C, err] = fit_ell_1d(p_wp, b_fem, I_vec, K_I, c)
% FIT_ELL_1D  Fit (ell, R_a) using 1D scan over ell for a single coil
%   B_model = C * B_unit(ell),  C_opt = (b_unit'*b_fem)/(b_unit'*b_unit)
%   R_a = N_c / (mu_0 * C_opt)

    cost_fn = @(el) ell_cost(el, p_wp, b_fem, I_vec, K_I, c);

    % Coarse scan
    ell_scan = linspace(400e-6, 2000e-6, 300);
    cost_scan = arrayfun(cost_fn, ell_scan);
    [~, imin] = min(cost_scan);
    ell_0 = ell_scan(imin);

    % Refine with fminbnd
    ell = fminbnd(cost_fn, max(100e-6, ell_0 - 200e-6), ell_0 + 200e-6, ...
        optimset('TolX', 1e-8, 'Display', 'off'));

    % Recover R_a and error
    [~, C] = ell_cost(ell, p_wp, b_fem, I_vec, K_I, c);
    R_a = c.N_c / (c.mu_0 * C);

    [bx_m, by_m, bz_m] = point_charge_model(p_wp, ell, R_a, I_vec, K_I, c);
    N = size(p_wp, 1);
    err = compute_error(bx_m, by_m, bz_m, ...
        b_fem(1:N), b_fem(N+1:2*N), b_fem(2*N+1:3*N));
end


function [ell, R_a, C, err] = fit_ell_joint(joint_data, K_I, c)
% FIT_ELL_JOINT  Fit shared (ell, R_a) using stacked data from multiple coils
%   For each coil k: B_model_k = C * B_unit_k(ell)
%   Stack all coils:  C_opt = (b_unit_all' * b_fem_all) / (b_unit_all' * b_unit_all)

    N_coils = length(joint_data);

    cost_fn = @(el) joint_cost(el, joint_data, K_I, c);

    % Coarse scan
    ell_scan = linspace(400e-6, 2000e-6, 300);
    cost_scan = arrayfun(cost_fn, ell_scan);
    [~, imin] = min(cost_scan);
    ell_0 = ell_scan(imin);

    % Refine
    ell = fminbnd(cost_fn, max(100e-6, ell_0 - 200e-6), ell_0 + 200e-6, ...
        optimset('TolX', 1e-8, 'Display', 'off'));

    % Recover C and R_a
    [~, C] = joint_cost(ell, joint_data, K_I, c);
    R_a = c.N_c / (c.mu_0 * C);

    % Compute overall error (stacked)
    bx_all_m = []; by_all_m = []; bz_all_m = [];
    bx_all_f = []; by_all_f = []; bz_all_f = [];
    for k = 1:N_coils
        N_k = size(joint_data(k).p_wp, 1);
        [bx, by, bz] = point_charge_model(joint_data(k).p_wp, ell, R_a, ...
            joint_data(k).I_vec, K_I, c);
        bx_all_m = [bx_all_m; bx];
        by_all_m = [by_all_m; by];
        bz_all_m = [bz_all_m; bz];
        bx_all_f = [bx_all_f; joint_data(k).b_fem(1:N_k)];
        by_all_f = [by_all_f; joint_data(k).b_fem(N_k+1:2*N_k)];
        bz_all_f = [bz_all_f; joint_data(k).b_fem(2*N_k+1:3*N_k)];
    end
    err = compute_error(bx_all_m, by_all_m, bz_all_m, bx_all_f, by_all_f, bz_all_f);
end


function [cost, C_opt] = ell_cost(ell, p_wp, b_fem, I_vec, K_I, c)
% ELL_COST  SSR cost for given ell (single coil)
    R_a_unit = c.N_c / c.mu_0;   % C = 1
    [bx, by, bz] = point_charge_model(p_wp, ell, R_a_unit, I_vec, K_I, c);
    b_unit = [bx; by; bz];

    C_opt = (b_unit' * b_fem) / (b_unit' * b_unit);
    residual = C_opt * b_unit - b_fem;
    cost = sum(residual.^2);
end


function [cost, C_opt] = joint_cost(ell, joint_data, K_I, c)
% JOINT_COST  SSR cost for given ell using stacked data from all coils
    R_a_unit = c.N_c / c.mu_0;
    b_unit_all = [];
    b_fem_all  = [];

    for k = 1:length(joint_data)
        [bx, by, bz] = point_charge_model(joint_data(k).p_wp, ell, R_a_unit, ...
            joint_data(k).I_vec, K_I, c);
        b_unit_all = [b_unit_all; bx; by; bz];
        b_fem_all  = [b_fem_all; joint_data(k).b_fem];
    end

    C_opt = (b_unit_all' * b_fem_all) / (b_unit_all' * b_unit_all);
    residual = C_opt * b_unit_all - b_fem_all;
    cost = sum(residual.^2);
end


function err = compute_error(bx_m, by_m, bz_m, bx_f, by_f, bz_f)
% COMPUTE_ERROR  Per-node and aggregate error metrics
    dx = bx_m - bx_f;
    dy = by_m - by_f;
    dz = bz_m - bz_f;
    err_mag = sqrt(dx.^2 + dy.^2 + dz.^2);
    fem_mag = sqrt(bx_f.^2 + by_f.^2 + bz_f.^2);

    valid = fem_mag > 1e-6 * max(fem_mag);
    rel = err_mag ./ fem_mag;
    rel(~valid) = 0;

    err.rel_per_node = rel;
    err.mean_rel   = mean(rel(valid));
    err.median_rel = median(rel(valid));
    err.p95_rel    = prctile(rel(valid), 95);
    err.max_rel    = max(rel(valid));
    err.rms_T      = sqrt(mean(err_mag.^2));
end
