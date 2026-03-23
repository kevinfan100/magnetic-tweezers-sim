%% compare_yoke_effect.m
% [ADDED] Compare single pole (bare) vs single pole with yoke
% Implements V1 (field enhancement), V2 (distribution), V3 (magnetic circuit)
%
% Case A: bare pole (no yoke)    → results/singlepole_only/
% Case B: pole + yoke            → results/singlepole_yoke/

clear; close all; clc;
script_dir = fileparts(mfilename('fullpath'));
addpath(script_dir);  % ensure analysis/ is on path
base_dir = fullfile(script_dir, '..');  % studies/single-pole-yoke/

c = mt_constants();

%% Section 1: Load data
fprintf('=== Loading simulation data ===\n');

% Case A: bare pole
dA_all = import_ansys_data(fullfile(base_dir, 'results', 'singlepole_only'), 'all', 'sp_only');
dA_wp  = import_ansys_data(fullfile(base_dir, 'results', 'singlepole_only'), 'wp',  'sp_only');

% Case B: pole + yoke
dB_all = import_ansys_data(fullfile(base_dir, 'results', 'singlepole_yoke'), 'all', 'sp_yoke');
dB_wp  = import_ansys_data(fullfile(base_dir, 'results', 'singlepole_yoke'), 'wp',  'sp_yoke');

fprintf('\nCase A (bare pole):   %d all nodes, %d WP nodes\n', ...
    length(dA_all.node_id), length(dA_wp.node_id));
fprintf('Case B (pole+yoke):  %d all nodes, %d WP nodes\n', ...
    length(dB_all.node_id), length(dB_wp.node_id));

%% Section 2 [V1]: Field enhancement — does yoke increase B?
fprintf('\n=== V1: Field Enhancement ===\n');

% Convert to WP-centered coordinates
zA_wp = dA_wp.z - c.SPH_OFST;
zB_wp = dB_wp.z - c.SPH_OFST;

% Filter iron nodes (only P1 exists, but function checks all 6 — the other 5 find 0)
fprintf('\nIron exclusion (Case A):\n');
[airA, ~] = filter_iron_nodes(dA_wp.x, dA_wp.y, dA_wp.z, c);
fprintf('Iron exclusion (Case B):\n');
[airB, ~] = filter_iron_nodes(dB_wp.x, dB_wp.y, dB_wp.z, c);

% Find node nearest to WP center (0, 0, SPH_OFST) for each case
rA = sqrt(dA_wp.x.^2 + dA_wp.y.^2 + zA_wp.^2);
rB = sqrt(dB_wp.x.^2 + dB_wp.y.^2 + zB_wp.^2);

[rA_min, iA_ctr] = min(rA(airA));
[rB_min, iB_ctr] = min(rB(airB));

% Convert air-indexed to full-indexed
air_idxA = find(airA);
air_idxB = find(airB);
iA_ctr = air_idxA(iA_ctr);
iB_ctr = air_idxB(iB_ctr);

B_center_A = dA_wp.bsum(iA_ctr);
B_center_B = dB_wp.bsum(iB_ctr);
ratio_center = B_center_B / B_center_A;

fprintf('\nWP center field:\n');
fprintf('  Case A (bare):      |B| = %.4f mT  (nearest node r = %.1f um)\n', ...
    B_center_A*1e3, rA_min*1e6);
fprintf('  Case B (pole+yoke): |B| = %.4f mT  (nearest node r = %.1f um)\n', ...
    B_center_B*1e3, rB_min*1e6);
fprintf('  Enhancement ratio:  %.3f x\n', ratio_center);

% Max |B| in WP region (air nodes only)
B_max_A = max(dA_wp.bsum(airA));
B_max_B = max(dB_wp.bsum(airB));
fprintf('\nMax |B| in WP region (air nodes, r < 2mm):\n');
fprintf('  Case A: %.4f mT\n', B_max_A*1e3);
fprintf('  Case B: %.4f mT\n', B_max_B*1e3);
fprintf('  Ratio:  %.3f x\n', B_max_B / B_max_A);

% B direction at WP center (should point toward P1 tip, i.e. +x direction)
fprintf('\nB direction at WP center:\n');
fprintf('  Case A: Bx=%.3e, By=%.3e, Bz=%.3e\n', ...
    dA_wp.bx(iA_ctr), dA_wp.by(iA_ctr), dA_wp.bz(iA_ctr));
fprintf('  Case B: Bx=%.3e, By=%.3e, Bz=%.3e\n', ...
    dB_wp.bx(iB_ctr), dB_wp.by(iB_ctr), dB_wp.bz(iB_ctr));

%% Section 3 [V2]: Field distribution comparison
fprintf('\n=== V2: Field Distribution ===\n');

% ---- Axial profile: |B| along P1 axis (x-axis, y=0, z=SPH_OFST) ----
% Define query points along P1 axis
x_query = linspace(0, 5e-3, 200)';  % 0 to 5mm from WP center
y_query = zeros(size(x_query));
z_query_apdl = ones(size(x_query)) * c.SPH_OFST;  % APDL z coordinate

% Interpolate Case A along P1 axis (use air nodes from WP dataset)
FA = scatteredInterpolant(dA_wp.x(airA), dA_wp.y(airA), dA_wp.z(airA), ...
    dA_wp.bsum(airA), 'natural', 'none');
FB = scatteredInterpolant(dB_wp.x(airB), dB_wp.y(airB), dB_wp.z(airB), ...
    dB_wp.bsum(airB), 'natural', 'none');

B_axial_A = FA(x_query, y_query, z_query_apdl);
B_axial_B = FB(x_query, y_query, z_query_apdl);

% Remove NaN (extrapolation beyond data range)
valid = ~isnan(B_axial_A) & ~isnan(B_axial_B);
x_valid = x_query(valid);
B_axial_A_valid = B_axial_A(valid);
B_axial_B_valid = B_axial_B(valid);

% Normalized profiles
B_axial_A_norm = B_axial_A_valid / B_axial_A_valid(1);  % normalize by center value
B_axial_B_norm = B_axial_B_valid / B_axial_B_valid(1);

% Shape similarity metric
corr_val = corrcoef(B_axial_A_norm, B_axial_B_norm);
shape_corr = corr_val(1,2);
rms_shape_diff = rms(B_axial_A_norm - B_axial_B_norm);

fprintf('Axial profile shape comparison:\n');
fprintf('  Correlation (normalized):  %.6f\n', shape_corr);
fprintf('  RMS shape difference:      %.4f\n', rms_shape_diff);

if shape_corr > 0.999
    fprintf('  → Shapes nearly identical: yoke mainly affects MAGNITUDE, not shape\n');
elseif shape_corr > 0.99
    fprintf('  → Shapes very similar with minor differences\n');
else
    fprintf('  → Shapes differ: yoke changes field spatial distribution\n');
end

% ---- Enhancement ratio vs distance ----
ratio_vs_dist = B_axial_B_valid ./ B_axial_A_valid;
fprintf('\nEnhancement ratio along P1 axis:\n');
fprintf('  At center (x=0):   %.3f x\n', ratio_vs_dist(1));
idx_250 = find(x_valid >= 250e-6, 1, 'first');
idx_500 = find(x_valid >= 500e-6, 1, 'first');
idx_1mm = find(x_valid >= 1e-3, 1, 'first');
if ~isempty(idx_250)
    fprintf('  At x=250um:        %.3f x\n', ratio_vs_dist(idx_250));
end
if ~isempty(idx_500)
    fprintf('  At x=500um:        %.3f x\n', ratio_vs_dist(idx_500));
end
if ~isempty(idx_1mm)
    fprintf('  At x=1mm:          %.3f x\n', ratio_vs_dist(idx_1mm));
end

%% Section 4 [V3]: Magnetic circuit analysis
fprintf('\n=== V3: Magnetic Circuit Analysis ===\n');

% --- Analytical reluctance estimates ---
mu_0 = c.mu_0;
mu_r = 280;       % relative permeability (1018 steel, linear)
N_c  = c.N_c;     % 70 turns
I    = 1;          % 1 A excitation

fprintf('Analytical magnetic circuit estimates:\n');
fprintf('  N*I = %d A-turns, mu_r = %d\n', N_c*I, mu_r);

% Pole cone: approximate as truncated cone
% R_cone = l / (mu_0 * mu_r * A_avg)
% A_avg = pi * (r_tip + r_base)/2 * (r_base - r_tip) ... not standard
% Better: R_cone = integral dl / (mu * A(l))
%   A(l) = pi * r(l)^2 where r(l) = r_tip + l*(r_base-r_tip)/L
%   R = (1/(mu_0*mu_r*pi)) * integral_0^L dl/r(l)^2
%     = (1/(mu_0*mu_r*pi)) * L/(r_tip * r_base)
r_tip  = c.POLE_TIP_R;    % 40 um
r_base = c.POLE_R;        % 3 mm
L_cone = c.POLE_CONE_LEN; % 15 mm
R_cone = L_cone / (mu_0 * mu_r * pi * r_tip * r_base);
fprintf('\n  R_cone (truncated cone): %.3e A/Wb\n', R_cone);

% Protrusion: cylinder R=5mm, L=7mm
r_prot = c.PROT_R;   % 5 mm
L_prot = c.PROT_H;   % 7 mm
A_prot = pi * r_prot^2;
R_prot = L_prot / (mu_0 * mu_r * A_prot);
fprintf('  R_protrusion:            %.3e A/Wb\n', R_prot);

% Yoke ring: approximate path length = pi * R_mid (half circumference for return)
R_yoke_mid = c.YOKE_MID_R;  % 47.5 mm
YOKE_H = 2e-3;
L_yoke = pi * R_yoke_mid;   % ~149 mm
A_yoke = (c.YOKE_OUT_R - c.YOKE_IN_R) * YOKE_H;  % 11mm * 2mm = 22 mm^2
R_yoke = L_yoke / (mu_0 * mu_r * A_yoke);
fprintf('  R_yoke (half-ring):      %.3e A/Wb\n', R_yoke);

% Air gap reluctance (from yoke back to WP region)
% Very rough: treat as air sphere of radius ~50mm
R_air_gap = 1 / (mu_0 * 4 * pi * 50e-3);
fprintf('  R_air_gap (rough):       %.3e A/Wb\n', R_air_gap);

% Case A total: R_cone + R_air_return (no yoke, air return dominates)
R_air_return_bare = 1 / (mu_0 * 4 * pi * 20e-3);  % rough estimate
R_total_A = R_cone + R_air_return_bare;
fprintf('\n  Case A total R_est:      %.3e A/Wb  (R_cone + R_air_return)\n', R_total_A);

% Case B total: R_cone + R_prot + R_yoke + R_air_gap_return
R_total_B = R_cone + R_prot + R_yoke + R_air_gap;
fprintf('  Case B total R_est:      %.3e A/Wb  (R_cone + R_prot + R_yoke + R_air)\n', R_total_B);

% Predicted flux and B
% Phi = N*I / R_total
% B_center ~ mu_0 * Q / (4*pi*ell^2) where Q = Phi/mu_0 = N*I/(mu_0*R_total)
% Simplified: B_center proportional to 1/R_total
fprintf('\n  Predicted ratio B_yoke/B_bare ≈ R_total_A/R_total_B = %.3f\n', ...
    R_total_A / R_total_B);

% --- FEM-based effective R_a ---
% From point-charge model: B_center = k_m * Q / ell^2
%   Q = N_c * I / (mu_0 * R_a)
%   B_center = k_m * N_c * I / (mu_0 * R_a * ell^2)
%   R_a = k_m * N_c * I / (mu_0 * B_center * ell^2)
ell_ref = 835e-6;  % from [A] fitting result
R_a_FEM_A = c.k_m * N_c * I / (mu_0 * B_center_A * ell_ref^2);
R_a_FEM_B = c.k_m * N_c * I / (mu_0 * B_center_B * ell_ref^2);

fprintf('\nEffective R_a from FEM (using ell = %d um from [A] fit):\n', round(ell_ref*1e6));
fprintf('  Case A (bare):      R_a = %.3e A/Wb\n', R_a_FEM_A);
fprintf('  Case B (pole+yoke): R_a = %.3e A/Wb\n', R_a_FEM_B);
fprintf('  Full model [A] fit: R_a = 9.21e8 A/Wb (reference)\n');

%% Section 5: Save results
results.B_center_A = B_center_A;
results.B_center_B = B_center_B;
results.ratio_center = ratio_center;
results.B_max_A = B_max_A;
results.B_max_B = B_max_B;
results.x_axial = x_valid;
results.B_axial_A = B_axial_A_valid;
results.B_axial_B = B_axial_B_valid;
results.B_axial_A_norm = B_axial_A_norm;
results.B_axial_B_norm = B_axial_B_norm;
results.shape_corr = shape_corr;
results.rms_shape_diff = rms_shape_diff;
results.R_a_FEM_A = R_a_FEM_A;
results.R_a_FEM_B = R_a_FEM_B;
results.R_total_A_est = R_total_A;
results.R_total_B_est = R_total_B;

save(fullfile(base_dir, 'data', 'yoke_comparison.mat'), 'results');
fprintf('\nResults saved to data/yoke_comparison.mat\n');

fprintf('\n=== Summary ===\n');
fprintf('Yoke enhancement:  %.3f x at WP center\n', ratio_center);
fprintf('Shape correlation:  %.6f (1.0 = identical shape)\n', shape_corr);
fprintf('FEM R_a ratio:      %.3f (Case A / Case B)\n', R_a_FEM_A / R_a_FEM_B);
fprintf('Done.\n');
