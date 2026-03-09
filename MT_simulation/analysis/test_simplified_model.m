%% test_simplified_model.m  -  Compare simplified 1-charge model with full 6-charge model
%
%  Simplified model: |B(p)| = a^2 / r^2
%    r = |p - c|,  c = (R_norm + b) * d_pole   (charge recessed by b from tip)
%    Two parameters: a (amplitude), b (recession distance)
%
%  Full model (from fit_charge_model_6coil.m): 6 charges, shared (ell, R_a)
%
%  Comparison on: 100 um cube at WP center, per-coil

%% 1. Setup
c = mt_constants();
K_I = eye(6) - ones(6)/6;
apdl_to_paper_idx = [1, 3, 6, 5, 2, 4];

cube_half = 50e-6;
b_scan = linspace(0, 800e-6, 2000);  % fine scan

% Load full 6-charge fit results
full_fit = load(fullfile('..', 'data', 'charge_model_6coil_fit.mat'));

%% 2. Fit and compare for each coil
fprintf('Loading and fitting all 6 coils...\n\n');

results = struct();

for k = 1:6
    coilname = sprintf('coil%d', k);
    data = import_ansys_data(fullfile('..', 'results', coilname), 'wp', coilname);
    [air_mask, ~] = filter_iron_nodes(data.x, data.y, data.z, c, struct('visualize', false));
    z_wp = data.z - c.SPH_OFST;

    mask = air_mask & ...
        abs(data.x) < cube_half & abs(data.y) < cube_half & abs(z_wp) < cube_half;

    px = data.x(mask);  py = data.y(mask);  pz = z_wp(mask);
    bx_f = data.bx(mask); by_f = data.by(mask); bz_f = data.bz(mask);
    bmag_f = sqrt(bx_f.^2 + by_f.^2 + bz_f.^2);
    N = sum(mask);

    paper_idx = apdl_to_paper_idx(k);
    tip = [c.pole_tip_x(paper_idx); c.pole_tip_y(paper_idx); c.pole_tip_z_wp(paper_idx)];
    d_pole = tip / norm(tip);
    R_norm = norm(tip);

    % --- Simplified 1-charge model: scan b ---
    cost_scan = zeros(size(b_scan));
    a2_scan   = zeros(size(b_scan));

    for j = 1:length(b_scan)
        charge_pos = (R_norm + b_scan(j)) * d_pole;
        dx = px - charge_pos(1);
        dy = py - charge_pos(2);
        dz = pz - charge_pos(3);
        r2 = dx.^2 + dy.^2 + dz.^2;
        m = 1 ./ r2;   % basis function

        % Solve a^2 analytically: |B| = a^2 * m
        a2 = (m' * bmag_f) / (m' * m);
        residual = a2 * m - bmag_f;
        cost_scan(j) = sum(residual.^2);
        a2_scan(j) = a2;
    end

    [~, imin] = min(cost_scan);
    b_opt = b_scan(imin);
    a2_opt = a2_scan(imin);

    % 1-charge model prediction and error (on |B|)
    charge_pos_opt = (R_norm + b_opt) * d_pole;
    dx = px - charge_pos_opt(1);
    dy = py - charge_pos_opt(2);
    dz = pz - charge_pos_opt(3);
    r2_opt = dx.^2 + dy.^2 + dz.^2;
    bmag_1ch = a2_opt ./ r2_opt;

    rel_err_1ch = abs(bmag_1ch - bmag_f) ./ bmag_f;
    mean_err_1ch = mean(rel_err_1ch);
    med_err_1ch  = median(rel_err_1ch);

    % --- Full 6-charge model: compute |B| at same points ---
    p_wp = [px, py, pz];
    ell_k  = full_fit.per_coil(k).ell;
    R_a_k  = full_fit.per_coil(k).R_a;

    % Build I_vec with sign correction
    coil_sign = 1 - 2 * (1 - c.pole_is_lower(paper_idx));
    I_vec = zeros(6,1);
    I_vec(paper_idx) = coil_sign;

    [bx_6, by_6, bz_6] = point_charge_model(p_wp, ell_k, R_a_k, I_vec, K_I, c);
    bmag_6ch = sqrt(bx_6.^2 + by_6.^2 + bz_6.^2);

    rel_err_6ch = abs(bmag_6ch - bmag_f) ./ bmag_f;
    mean_err_6ch = mean(rel_err_6ch);
    med_err_6ch  = median(rel_err_6ch);

    % --- Also compute the x+b approximation error ---
    % x = distance from field point to tip
    x_tip = sqrt((px - tip(1)).^2 + (py - tip(2)).^2 + (pz - tip(3)).^2);
    bmag_approx = a2_opt ./ (x_tip + b_opt).^2;
    rel_err_approx = abs(bmag_approx - bmag_f) ./ bmag_f;
    mean_err_approx = mean(rel_err_approx);

    % Store results
    results(k).pole = c.apdl_to_paper{k};
    results(k).is_lower = c.pole_is_lower(paper_idx);
    results(k).b_opt = b_opt;
    results(k).a2_opt = a2_opt;
    results(k).ell_equiv = R_norm + b_opt;
    results(k).mean_err_1ch = mean_err_1ch;
    results(k).med_err_1ch  = med_err_1ch;
    results(k).mean_err_6ch = mean_err_6ch;
    results(k).med_err_6ch  = med_err_6ch;
    results(k).mean_err_approx = mean_err_approx;
    results(k).N = N;
end

%% 3. Summary table
fprintf('\n========== Simplified 1-Charge vs Full 6-Charge Model ==========\n');
fprintf('Fitting region: 100 um cube at WP center\n\n');

fprintf('%-6s %-6s  %8s  %10s  |  %-22s  |  %-22s  |  %-12s\n', ...
    'Pole', 'Layer', 'b [um]', 'ell_eq[um]', ...
    '1-charge |B| err', '6-charge |B| err', 'a^2/(x+b)^2');
fprintf('%s\n', repmat('-', 1, 100));

for k = 1:6
    layer = 'Upper';
    if results(k).is_lower, layer = 'Lower'; end
    fprintf('%-6s %-6s  %8.1f  %10.1f  |  mean=%5.2f%% med=%5.2f%%  |  mean=%5.2f%% med=%5.2f%%  |  mean=%5.2f%%\n', ...
        results(k).pole, layer, ...
        results(k).b_opt*1e6, results(k).ell_equiv*1e6, ...
        100*results(k).mean_err_1ch, 100*results(k).med_err_1ch, ...
        100*results(k).mean_err_6ch, 100*results(k).med_err_6ch, ...
        100*results(k).mean_err_approx);
end

%% 4. Lower/Upper averages
lower_idx = find([results.is_lower] == 1);
upper_idx = find([results.is_lower] == 0);

fprintf('\n--- Averages ---\n');
fprintf('Lower: b = %.1f um, 1-ch err = %.2f%%, 6-ch err = %.2f%%\n', ...
    mean([results(lower_idx).b_opt])*1e6, ...
    100*mean([results(lower_idx).mean_err_1ch]), ...
    100*mean([results(lower_idx).mean_err_6ch]));
fprintf('Upper: b = %.1f um, 1-ch err = %.2f%%, 6-ch err = %.2f%%\n', ...
    mean([results(upper_idx).b_opt])*1e6, ...
    100*mean([results(upper_idx).mean_err_1ch]), ...
    100*mean([results(upper_idx).mean_err_6ch]));

%% 5. Figure: Error comparison
figure('Name', '1-Charge vs 6-Charge Error', 'Position', [100 100 800 400]);

err_1ch = 100 * [results.mean_err_1ch];
err_6ch = 100 * [results.mean_err_6ch];
err_apx = 100 * [results.mean_err_approx];
pole_names = {results.pole};

bar_data = [err_1ch; err_6ch; err_apx]';
b = bar(bar_data);
b(1).FaceColor = [0.85 0.3 0.2];
b(2).FaceColor = [0.2 0.5 0.8];
b(3).FaceColor = [0.5 0.8 0.3];

set(gca, 'XTick', 1:6, 'XTickLabel', pole_names);
ylabel('Mean |B| Relative Error [%]');
title('Model Comparison (100 \mum cube)');
legend('1-charge (exact r)', '6-charge (full model)', '1-charge (x+b approx)', ...
    'Location', 'best');
grid on;
