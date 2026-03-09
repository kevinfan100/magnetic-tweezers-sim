%% fit_3d_vector_all_coils.m  -  3D vector charge fitting for all 6 coils
%
%  Model: B(p) = Q * (p - c) / |p - c|^3
%  For fixed c = (cx, cy, cz), Q solved analytically (normal equation).
%  fminsearch optimizes c using vector SSE as cost.
%
%  Runs on all 6 coils, prints summary table, saves results.

clear; clc; close all;

%% Setup
cnst = mt_constants();
apdl_to_paper_idx = [1, 3, 6, 5, 2, 4];
cube_half = 50e-6;
b_scan = linspace(0, 800e-6, 2000);
fms_opts = optimset('Display', 'off', 'TolX', 1e-10, 'TolFun', 1e-22, 'MaxIter', 10000);

results = struct();

fprintf('Fitting 3D vector charge model for all 6 coils...\n\n');

for k = 1:6
    coilname = sprintf('coil%d', k);
    data = import_ansys_data(fullfile('..', 'results', coilname), 'wp', coilname);
    [air_mask, ~] = filter_iron_nodes(data.x, data.y, data.z, cnst, struct('visualize', false));
    z_wp = data.z - cnst.SPH_OFST;

    % Fitting region: 100 um cube
    mask_fit = air_mask & ...
        abs(data.x) < cube_half & abs(data.y) < cube_half & abs(z_wp) < cube_half;

    px = data.x(mask_fit);  py = data.y(mask_fit);  pz = z_wp(mask_fit);
    bx_f = data.bx(mask_fit); by_f = data.by(mask_fit); bz_f = data.bz(mask_fit);
    bmag_f = sqrt(bx_f.^2 + by_f.^2 + bz_f.^2);
    bvec_fem = [bx_f; by_f; bz_f];
    N_fit = sum(mask_fit);

    paper_idx = apdl_to_paper_idx(k);
    tip = [cnst.pole_tip_x(paper_idx); cnst.pole_tip_y(paper_idx); cnst.pole_tip_z_wp(paper_idx)];
    d_pole = tip / norm(tip);
    R_norm = norm(tip);

    % --- 1D baseline for initial guess ---
    cost_scan = zeros(size(b_scan));
    for j = 1:length(b_scan)
        cp = (R_norm + b_scan(j)) * d_pole;
        r2 = (px - cp(1)).^2 + (py - cp(2)).^2 + (pz - cp(3)).^2;
        m = 1 ./ r2;
        a2 = (m' * bmag_f) / (m' * m);
        cost_scan(j) = sum((a2 * m - bmag_f).^2);
    end
    [~, imin] = min(cost_scan);
    charge_1d = (R_norm + b_scan(imin)) * d_pole;

    % --- 3D vector fit ---
    cost_fn = @(pos) vector_charge_cost(pos, px, py, pz, bvec_fem);
    [c1, f1] = fminsearch(cost_fn, charge_1d(:)', fms_opts);
    [c2, f2] = fminsearch(cost_fn, -charge_1d(:)', fms_opts);
    if f2 < f1, charge_opt = c2; else, charge_opt = c1; end

    % Recover Q
    [dx, dy, dz] = deal(px - charge_opt(1), py - charge_opt(2), pz - charge_opt(3));
    r2 = dx.^2 + dy.^2 + dz.^2;  r = sqrt(r2);  r3 = r2 .* r;
    mvec = [dx ./ r3; dy ./ r3; dz ./ r3];
    Q_opt = (mvec' * bvec_fem) / (mvec' * mvec);

    % Predicted B and errors (fitting region)
    bx_pred = Q_opt * dx ./ r3;
    by_pred = Q_opt * dy ./ r3;
    bz_pred = Q_opt * dz ./ r3;
    delta_mag = sqrt((bx_pred - bx_f).^2 + (by_pred - by_f).^2 + (bz_pred - bz_f).^2);
    vec_err = delta_mag ./ bmag_f;
    bmag_pred = sqrt(bx_pred.^2 + by_pred.^2 + bz_pred.^2);
    scalar_err = abs(bmag_pred - bmag_f) ./ bmag_f;

    % Geometric analysis
    ell = norm(charge_opt);
    d_fit = charge_opt(:) / ell;
    angle_dev = acosd(abs(dot(d_fit, d_pole)));
    proj_along = abs(dot(charge_opt(:), d_pole));
    proj_perp  = norm(charge_opt(:) - dot(charge_opt(:), d_pole) * d_pole);

    % Recover R_a from Q
    % In 6-charge model: Q_phys = -(N_c/(mu_0*R_a)) * (K_I*I)_excited
    % With coil_sign correction: lower=+1, upper=-1
    % Q_1ch = k_m * coil_sign * Q_phys
    % => R_a = -(k_m * N_c * 5 * coil_sign) / (6 * mu_0 * Q_opt)
    coil_sign = 1 - 2 * (1 - cnst.pole_is_lower(paper_idx));  % +1 lower, -1 upper
    R_a = -(cnst.k_m * cnst.N_c * 5 * coil_sign) / (6 * cnst.mu_0 * Q_opt);

    % Store results
    results(k).apdl_coil = k;
    results(k).pole = cnst.apdl_to_paper{k};
    results(k).paper_idx = paper_idx;
    results(k).is_lower = cnst.pole_is_lower(paper_idx);
    results(k).tip = tip(:)';
    results(k).charge = charge_opt;
    results(k).charge_1d = charge_1d(:)';
    results(k).Q = Q_opt;
    results(k).ell = ell;
    results(k).R_a = R_a;
    results(k).angle_dev = angle_dev;
    results(k).proj_perp = proj_perp;
    results(k).vec_err_mean = mean(vec_err);
    results(k).vec_err_median = median(vec_err);
    results(k).vec_err_max = max(vec_err);
    results(k).scalar_err_mean = mean(scalar_err);
    results(k).N = N_fit;

    fprintf('  Coil %d (%s): ell=%.1f um, R_a=%.2e, vec_err=%.2f%%, dev=%.2f deg\n', ...
        k, results(k).pole, ell*1e6, R_a, mean(vec_err)*100, angle_dev);
end

%% Summary table
fprintf('\n');
fprintf('===================================================================================\n');
fprintf('  3D Vector Charge Fit — All 6 Coils (100 um cube at WP center)\n');
fprintf('===================================================================================\n\n');

fprintf('%-5s %-6s  %7s  %9s  %10s  %6s  %8s  %8s  %8s\n', ...
    'Coil', 'Pole', 'Layer', 'ell[um]', 'R_a[A/Wb]', 'Dev[°]', 'Vec err', 'Scl err', 'N');
fprintf('%s\n', repmat('-', 1, 85));

for k = 1:6
    layer = 'Upper';
    if results(k).is_lower, layer = 'Lower'; end
    fprintf('  %d   %-4s  %-6s  %7.1f  %9.2e  %6.2f  %7.2f%%  %7.2f%%  %5d\n', ...
        k, results(k).pole, layer, ...
        results(k).ell*1e6, results(k).R_a, results(k).angle_dev, ...
        results(k).vec_err_mean*100, results(k).scalar_err_mean*100, ...
        results(k).N);
end

%% Lower/Upper averages
lower_idx = find([results.is_lower] == 1);
upper_idx = find([results.is_lower] == 0);

fprintf('\n--- Layer Averages ---\n');
fprintf('Lower (P1,P3,P6): ell = %.1f um, R_a = %.2e, vec_err = %.2f%%\n', ...
    mean([results(lower_idx).ell])*1e6, ...
    mean([results(lower_idx).R_a]), ...
    mean([results(lower_idx).vec_err_mean])*100);
fprintf('Upper (P2,P4,P5): ell = %.1f um, R_a = %.2e, vec_err = %.2f%%\n', ...
    mean([results(upper_idx).ell])*1e6, ...
    mean([results(upper_idx).R_a]), ...
    mean([results(upper_idx).vec_err_mean])*100);
fprintf('All 6:             ell = %.1f um, R_a = %.2e, vec_err = %.2f%%\n', ...
    mean([results.ell])*1e6, ...
    mean([results.R_a]), ...
    mean([results.vec_err_mean])*100);

%% Charge positions table
fprintf('\n--- Charge & Tip Positions [um] ---\n');
fprintf('%-5s  %8s %8s %8s  %6s  |  %8s %8s %8s  %6s\n', ...
    'Pole', 'cx', 'cy', 'cz', '|c|', 'tip_x', 'tip_y', 'tip_z', '|tip|');
fprintf('%s\n', repmat('-', 1, 80));
for k = 1:6
    ch = results(k).charge * 1e6;
    tp = results(k).tip * 1e6;
    fprintf('%-5s  %+8.1f %+8.1f %+8.1f  %6.1f  |  %+8.1f %+8.1f %+8.1f  %6.1f\n', ...
        results(k).pole, ch(1), ch(2), ch(3), results(k).ell*1e6, ...
        tp(1), tp(2), tp(3), norm(results(k).tip)*1e6);
end

%% Q sign check
fprintf('\n--- Charge Q and Sign ---\n');
for k = 1:6
    layer = 'Lower(sink)';
    if ~results(k).is_lower, layer = 'Upper(src) '; end
    sign_str = 'negative';
    if results(k).Q > 0, sign_str = 'positive'; end
    fprintf('%-4s %s  Q = %+.4e  (%s)\n', ...
        results(k).pole, layer, results(k).Q, sign_str);
end

%% Save results
save_path = fullfile('..', 'data', 'vecfit_3d_all_coils.mat');
save(save_path, 'results');
fprintf('\nResults saved to %s\n', save_path);

%% Local function
function cost = vector_charge_cost(pos, px, py, pz, bvec_fem)
    dx = px - pos(1);  dy = py - pos(2);  dz = pz - pos(3);
    r3 = (dx.^2 + dy.^2 + dz.^2).^(3/2);
    mvec = [dx ./ r3; dy ./ r3; dz ./ r3];
    Q = (mvec' * bvec_fem) / (mvec' * mvec);
    residual = Q * mvec - bvec_fem;
    cost = sum(residual.^2);
end
