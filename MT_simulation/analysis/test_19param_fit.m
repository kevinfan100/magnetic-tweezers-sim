%% test_19param_fit.m — Test fitting with 19 free parameters (18 positions + R_a)
%
%  Compare:
%    Model A: 2 params (ell, R_a) — dissertation approach, charges on sphere
%    Model B: 19 params (6x3 positions + R_a) — free 3D positions per charge
%
%  For Model B, Variable Projection: C solved analytically, optimize 18 positions.
%  Run from multiple initial conditions to test identifiability.

clear; clc; close all;

%% 1. Load data
cnst = mt_constants();
K_I = eye(6) - ones(6)/6;
I_vec = [1; 0; 0; 0; 0; 0];  % Coil 1 = P1

data = import_ansys_data(fullfile('..', 'results', 'coil1'), 'wp', 'coil1');
[air_mask, ~] = filter_iron_nodes(data.x, data.y, data.z, cnst, struct('visualize', false));
z_wp = data.z - cnst.SPH_OFST;

cube_half = 50e-6;
mask = air_mask & abs(data.x) < cube_half & abs(data.y) < cube_half & abs(z_wp) < cube_half;
N = sum(mask);

px = data.x(mask); py = data.y(mask); pz = z_wp(mask);
p_wp = [px, py, pz];
bx_f = data.bx(mask); by_f = data.by(mask); bz_f = data.bz(mask);
b_fem = [bx_f; by_f; bz_f];
bmag_f = sqrt(bx_f.^2 + by_f.^2 + bz_f.^2);

KI_w = K_I * I_vec;  % [5/6, -1/6, -1/6, -1/6, -1/6, -1/6]
k_m = cnst.k_m;

fprintf('Fitting region: 100 um cube, N = %d nodes\n\n', N);

%% 2. Model A: 2-param (ell, R_a) baseline
fprintf('===== Model A: 2 params (ell, R_a) =====\n');

cost_A_fn = @(ell) ell_cost_sphere(ell, p_wp, b_fem, I_vec, K_I, cnst);
ell_scan = linspace(400e-6, 2000e-6, 300);
cost_scan = arrayfun(cost_A_fn, ell_scan);
[~, imin] = min(cost_scan);
ell_A = fminbnd(cost_A_fn, max(100e-6, ell_scan(imin)-200e-6), ell_scan(imin)+200e-6, ...
    optimset('TolX', 1e-8, 'Display', 'off'));
[cost_A, C_A] = ell_cost_sphere(ell_A, p_wp, b_fem, I_vec, K_I, cnst);
R_a_A = cnst.N_c / (cnst.mu_0 * C_A);

% Charge positions for Model A
alpha = cnst.alpha;
pos_A = zeros(3, 6);
for i = 1:6
    theta = cnst.pole_angles(i) * pi/180;
    z_sign = sign(cnst.pole_tip_z_wp(i));
    pos_A(:,i) = ell_A * [cos(theta)*sin(alpha); sin(theta)*sin(alpha); z_sign*cos(alpha)];
end

[bx_mA, by_mA, bz_mA] = point_charge_model(p_wp, ell_A, R_a_A, I_vec, K_I, cnst);
err_A = sqrt((bx_mA-bx_f).^2 + (by_mA-by_f).^2 + (bz_mA-bz_f).^2) ./ bmag_f;

fprintf('  ell = %.1f um, R_a = %.3e\n', ell_A*1e6, R_a_A);
fprintf('  Cost = %.6e, Mean vec err = %.2f%%\n\n', cost_A, mean(err_A)*100);

%% 3. Model B: 19-param — multiple initial conditions
fprintf('===== Model B: 19 params (18 positions + C) =====\n');

fms_opts = optimset('Display', 'off', 'TolX', 1e-10, 'TolFun', 1e-22, ...
    'MaxIter', 50000, 'MaxFunEvals', 500000);

% Cost function: x = 18x1 positions, C solved analytically
cost_B_fn = @(x) cost_free_positions(x, px, py, pz, b_fem, KI_w, k_m);

% 5 different initial conditions
x0_sphere = pos_A(:);                          % 1: sphere solution
rng(42);  x0_noise1 = pos_A(:) + 50e-6*randn(18,1);   % 2: +50um noise
rng(123); x0_noise2 = pos_A(:) + 100e-6*randn(18,1);  % 3: +100um noise
pos_far = 1.5 * pos_A; x0_far = pos_far(:);            % 4: 1.5x radius
pos_near = 0.7 * pos_A; x0_near = pos_near(:);         % 5: 0.7x radius

inits = {x0_sphere, x0_noise1, x0_noise2, x0_far, x0_near};
init_names = {'Sphere(ell=835)', '+50um noise', '+100um noise', '1.5x sphere', '0.7x sphere'};

results_B = struct();

fprintf('\n%-22s  %12s  %10s  %12s\n', 'Initial', 'Cost', 'Err [%]', 'R_a');
fprintf('%s\n', repmat('-', 1, 60));

for trial = 1:length(inits)
    [x_opt, cost_opt] = fminsearch(cost_B_fn, inits{trial}, fms_opts);

    [~, C_opt] = cost_free_positions(x_opt, px, py, pz, b_fem, KI_w, k_m);
    R_a_opt = cnst.N_c / (cnst.mu_0 * C_opt);

    pos_opt = reshape(x_opt, 3, 6);
    [bx_m, by_m, bz_m] = eval_free_model(pos_opt, C_opt, KI_w, k_m, p_wp);
    err_vec = sqrt((bx_m-bx_f).^2 + (by_m-by_f).^2 + (bz_m-bz_f).^2) ./ bmag_f;

    results_B(trial).name = init_names{trial};
    results_B(trial).pos = pos_opt;
    results_B(trial).cost = cost_opt;
    results_B(trial).C = C_opt;
    results_B(trial).R_a = R_a_opt;
    results_B(trial).mean_err = mean(err_vec);

    fprintf('%-22s  %12.6e  %10.2f  %12.3e\n', ...
        init_names{trial}, cost_opt, mean(err_vec)*100, R_a_opt);
end

%% 4. Identifiability analysis
fprintf('\n===== Identifiability: how much do positions vary across trials? =====\n');

% Collect all optimal positions
all_pos = cat(3, results_B.pos);  % 3 x 6 x ntrials
all_costs = [results_B.cost];

fprintf('\n--- Per-pole distance from WP center [um] ---\n');
fprintf('%-22s', 'Trial');
for i = 1:6, fprintf('  P%d      ', i); end
fprintf('\n%s\n', repmat('-', 1, 82));

for trial = 1:length(results_B)
    fprintf('%-22s', results_B(trial).name);
    for i = 1:6
        fprintf('  %7.1f ', norm(results_B(trial).pos(:,i))*1e6);
    end
    fprintf('\n');
end

% Model A reference
fprintf('%-22s', 'Model A (sphere)');
for i = 1:6, fprintf('  %7.1f ', norm(pos_A(:,i))*1e6); end
fprintf('\n');

% Spread
fprintf('\n--- Spread (std) of position across trials [um] ---\n');
for i = 1:6
    pos_i = squeeze(all_pos(:,i,:)) * 1e6;  % 3 x ntrials
    fprintf('P%d: std(x)=%6.1f  std(y)=%6.1f  std(z)=%6.1f  total_spread=%6.1f\n', ...
        i, std(pos_i(1,:)), std(pos_i(2,:)), std(pos_i(3,:)), ...
        sqrt(sum(std(pos_i, 0, 2).^2)));
end

%% 5. Direct comparison: best B vs A
[~, best_idx] = min(all_costs);
best = results_B(best_idx);

fprintf('\n===== Best Model B vs Model A =====\n');
fprintf('Model A: cost = %.6e, err = %.2f%%, params = 2\n', cost_A, mean(err_A)*100);
fprintf('Model B: cost = %.6e, err = %.2f%%, params = 19 (init: %s)\n', ...
    best.cost, best.mean_err*100, best.name);
fprintf('Cost reduction: %.4f%%\n', (1 - best.cost/cost_A)*100);
fprintf('Error reduction: %.4f pp\n', (mean(err_A) - best.mean_err)*100);

fprintf('\n--- Charge position comparison (best B vs A) [um] ---\n');
fprintf('%-5s  %28s  |  %28s  |  %6s\n', 'Pole', 'Model A (sphere)', 'Model B (free)', 'Shift');
fprintf('%s\n', repmat('-', 1, 80));
for i = 1:6
    pA = pos_A(:,i)*1e6;
    pB = best.pos(:,i)*1e6;
    shift = norm(pB - pA);
    fprintf('P%d   (%+7.1f,%+7.1f,%+7.1f)  |  (%+7.1f,%+7.1f,%+7.1f)  |  %6.1f\n', ...
        i, pA(1), pA(2), pA(3), pB(1), pB(2), pB(3), shift);
end


%% ===== Local functions =====

function [cost, C_opt] = ell_cost_sphere(ell, p_wp, b_fem, I_vec, K_I, c)
    R_a_unit = c.N_c / c.mu_0;
    [bx, by, bz] = point_charge_model(p_wp, ell, R_a_unit, I_vec, K_I, c);
    b_unit = [bx; by; bz];
    C_opt = (b_unit' * b_fem) / (b_unit' * b_unit);
    cost = sum((C_opt * b_unit - b_fem).^2);
end

function [cost, C_opt] = cost_free_positions(x, px, py, pz, b_fem, KI_w, k_m)
    % x: 18x1 vector [x1,y1,z1,...,x6,y6,z6]
    % KI_w: K_I * I_vec (6x1)
    % C solved analytically
    pos = reshape(x, 3, 6);
    N = length(px);

    bx_u = zeros(N,1); by_u = zeros(N,1); bz_u = zeros(N,1);
    for i = 1:6
        dx = px - pos(1,i);
        dy = py - pos(2,i);
        dz = pz - pos(3,i);
        r3 = (dx.^2 + dy.^2 + dz.^2).^(3/2);
        w = -KI_w(i);  % negative sign convention
        bx_u = bx_u + w * dx ./ r3;
        by_u = by_u + w * dy ./ r3;
        bz_u = bz_u + w * dz ./ r3;
    end
    b_unit = k_m * [bx_u; by_u; bz_u];

    C_opt = (b_unit' * b_fem) / (b_unit' * b_unit);
    cost = sum((C_opt * b_unit - b_fem).^2);
end

function [bx, by, bz] = eval_free_model(pos, C, KI_w, k_m, p_wp)
    N = size(p_wp, 1);
    bx = zeros(N,1); by = zeros(N,1); bz = zeros(N,1);
    for i = 1:6
        dx = p_wp(:,1) - pos(1,i);
        dy = p_wp(:,2) - pos(2,i);
        dz = p_wp(:,3) - pos(3,i);
        r3 = (dx.^2 + dy.^2 + dz.^2).^(3/2);
        w = -C * KI_w(i);
        bx = bx + w * dx ./ r3;
        by = by + w * dy ./ r3;
        bz = bz + w * dz ./ r3;
    end
    bx = k_m * bx; by = k_m * by; bz = k_m * bz;
end
