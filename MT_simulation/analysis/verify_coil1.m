%% verify_coil1.m — Verify Coil1 simulation results
% Reproduces Fig.2.3 from thesis for comparison:
%   (a) XY top view of B-field vector distribution
%   (b) B-field vectors in 100um cube at workspace center
%   (c) B-field vectors near pole 1 tip
%   (d) Physical verification curves (additional)
%
% Prerequisites: run post_extract_coil1.txt in ANSYS first.

clear; clc; close all;

%% ---- Geometry constants (must match APDL script) ----
R_norm    = 500e-6;                          % working radius [m]
R_norm_xy = R_norm * sqrt(2/3);
R_norm_z  = R_norm / sqrt(3);
PROT_H    = 7.0e-3;
PROT_R    = 10.0e-3 / 2;                    % protrusion radius 5mm
YOKE_IN_R  = 84e-3 / 2;
YOKE_OUT_R = 106e-3 / 2;
YOKE_MID_R = (YOKE_IN_R + YOKE_OUT_R) / 2;  % 47.5 mm
SPH_OFST   = -PROT_H - 6e-3 + R_norm_z;     % ~ -0.01271 m

% Pole naming: Paper convention (differs from APDL internal numbering)
%   APDL index:  1     2      3      4     5      6
%   APDL angle:  0deg  120deg 240deg 60deg 180deg 300deg
%   Paper name:  P1    P3     P6     P5    P2     P4
% Paper poles listed in order P1-P6:
pole_angles = [0, 180, 120, 300, 60, 240];    % degrees (paper convention)
pole_labels = {'P1','P2','P3','P4','P5','P6'};
% Lower: P1(0°), P3(120°), P6(240°)  |  Upper: P2(180°), P4(300°), P5(60°)
% Opposite pairs: P1-P2, P3-P4, P5-P6
% Mapping: APDL coil index -> paper pole name
%   Coil1 -> P1, Coil2 -> P3, Coil3 -> P6, Coil4 -> P5, Coil5 -> P2, Coil6 -> P4

% Coil1 pole tip approximate position
tip_x = R_norm_xy;                            % ~ 0.408 mm
tip_z = SPH_OFST - R_norm_z;                  % ~ -13.0 mm

%% ---- Load data ----
results_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'coil1');

fprintf('Loading full dataset...\n');
d = import_ansys_data(results_dir, 'all');
fprintf('  Nodes loaded: %d\n', length(d.node_id));

fprintf('Loading working-point dataset...\n');
wp = import_ansys_data(results_dir, 'wp');
fprintf('  WP nodes loaded: %d\n', length(wp.node_id));

%% ---- Physical reasonableness checks ----
fprintf('\n=== Physical Checks ===\n');
fprintf('NaN count in BSUM      : %d\n', sum(isnan(d.bsum)));
fprintf('Negative BSUM count    : %d\n', sum(d.bsum < 0));
[bmax, imax] = max(d.bsum);
fprintf('Max BSUM               : %.6e T  at node %d  (%.3f, %.3f, %.3f) mm\n', ...
    bmax, d.node_id(imax), d.x(imax)*1e3, d.y(imax)*1e3, d.z(imax)*1e3);

r_wp = sqrt(wp.x.^2 + wp.y.^2 + (wp.z - SPH_OFST).^2);
[~, iwp0] = min(r_wp);
fprintf('BSUM at WP center      : %.6e T  (node %d)\n', wp.bsum(iwp0), wp.node_id(iwp0));

r_cyl = sqrt(d.x.^2 + d.y.^2);
far_mask = r_cyl > 79e-3;
if any(far_mask)
    fprintf('Mean BSUM at boundary  : %.6e T  (%d nodes)\n', ...
        mean(d.bsum(far_mask)), sum(far_mask));
end

fprintf('WP region mean |BX|    : %.6e T\n', mean(abs(wp.bx)));
fprintf('WP region mean |BY|    : %.6e T\n', mean(abs(wp.by)));
fprintf('WP region mean |BZ|    : %.6e T\n', mean(abs(wp.bz)));
fprintf('================================\n\n');

%% ======== Fig (a): XY top view — vector plot (matches thesis Fig.2.3a) ========
figure('Name', 'Fig(a): XY top view', 'Position', [50 50 850 750]);

% Project all nodes onto XY plane, subsample for performance
stride = 5;
idx = 1:stride:length(d.x);

% Scatter colored by BSUM (linear scale, matching paper colorbar in Tesla)
scatter(d.x(idx)*1e3, d.y(idx)*1e3, 1, d.bsum(idx), 'filled');
colormap(jet);
cb = colorbar;
ylabel(cb, 'Tesla');
clim([0 max(d.bsum)]);

% Overlay quiver arrows for field direction (heavily subsampled)
hold on;
qs = 150;
qi = 1:qs:length(d.x);
% Normalize arrows to unit length for direction-only display
bmag_qi = max(d.bsum(qi), 1e-12);
quiver(d.x(qi)*1e3, d.y(qi)*1e3, ...
       d.bx(qi)./bmag_qi, d.by(qi)./bmag_qi, ...
       3, 'b', 'LineWidth', 0.3);

% Draw 6 coil/protrusion circles on yoke
theta_c = linspace(0, 2*pi, 100);
for k = 1:6
    ang = pole_angles(k) * pi/180;
    cx = YOKE_MID_R * cos(ang) * 1e3;
    cy = YOKE_MID_R * sin(ang) * 1e3;
    plot(cx + PROT_R*1e3*cos(theta_c), cy + PROT_R*1e3*sin(theta_c), ...
         'k-', 'LineWidth', 1.5);
    text(cx*1.15, cy*1.15, pole_labels{k}, ...
         'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end

% Draw yoke outline (dashed)
plot(YOKE_IN_R*1e3*cos(theta_c), YOKE_IN_R*1e3*sin(theta_c), ...
     'r--', 'LineWidth', 0.8);
plot(YOKE_OUT_R*1e3*cos(theta_c), YOKE_OUT_R*1e3*sin(theta_c), ...
     'r--', 'LineWidth', 0.8);
hold off;

axis equal; grid on;
xlabel('x [mm]'); ylabel('y [mm]');
title('(a) Top view: B-field vector distribution (unit: Tesla)');

%% ======== Fig (b): 100um cube at WP center (matches thesis Fig.2.3b) ========
figure('Name', 'Fig(b): WP 3D quiver', 'Position', [100 100 700 650]);

% Select nodes within 100um cube (+-50um) centered at workspace origin
half_cube = 50e-6;
mask_b = abs(wp.x) < half_cube & ...
         abs(wp.y) < half_cube & ...
         abs(wp.z - SPH_OFST) < half_cube;

fprintf('Fig(b): %d nodes in 100um cube\n', sum(mask_b));
if sum(mask_b) < 5
    half_cube = 100e-6;
    mask_b = abs(wp.x) < half_cube & ...
             abs(wp.y) < half_cube & ...
             abs(wp.z - SPH_OFST) < half_cube;
    fprintf('  Expanded to 200um cube: %d nodes\n', sum(mask_b));
end

qx = wp.x(mask_b)*1e6;
qy = wp.y(mask_b)*1e6;
qz = (wp.z(mask_b) - SPH_OFST)*1e6;
quiver3(qx, qy, qz, wp.bx(mask_b), wp.by(mask_b), wp.bz(mask_b), ...
        'b', 'LineWidth', 1);
axis equal; grid on; box on;
xlabel('x (\mum)'); ylabel('y (\mum)'); zlabel('z (\mum)');
title('(b) B-field vectors near workspace center');
view([-37.5, 30]);
xlim([-60 60]); ylim([-60 60]); zlim([-60 60]);

%% ======== Fig (c): Pole tip vectors (matches thesis Fig.2.3c) ========
figure('Name', 'Fig(c): Pole tip vectors', 'Position', [150 150 800 500]);

% Wider view around Coil1 pole tip in XZ plane (Y ~ 0)
y_tol_c = 0.5e-3;
xrange_c = [-1e-3, 3e-3];
zrange_c = [tip_z - 1.5e-3, tip_z + 1.5e-3];
mask_c = abs(d.y) < y_tol_c & ...
         d.x > xrange_c(1) & d.x < xrange_c(2) & ...
         d.z > zrange_c(1) & d.z < zrange_c(2);

fprintf('Fig(c): %d nodes near pole tip\n', sum(mask_c));
if sum(mask_c) < 50
    y_tol_c = 2e-3;
    xrange_c = [-3e-3, 5e-3];
    zrange_c = [tip_z - 3e-3, tip_z + 3e-3];
    mask_c = abs(d.y) < y_tol_c & ...
             d.x > xrange_c(1) & d.x < xrange_c(2) & ...
             d.z > zrange_c(1) & d.z < zrange_c(2);
    fprintf('  Expanded: %d nodes\n', sum(mask_c));
end

x_c = d.x(mask_c)*1e6;
z_c = d.z(mask_c)*1e6;
bx_c = d.bx(mask_c);
bz_c = d.bz(mask_c);
bsum_c = d.bsum(mask_c);

% Background: scatter colored by BSUM (linear scale)
scatter(x_c, z_c, 2, bsum_c, 'filled');
colormap(jet);
cb3 = colorbar;
ylabel(cb3, 'Tesla');

% Overlay: quiver arrows, colored by field strength
%   Red arrows = high field (in pole), blue arrows = low field (in air)
hold on;
qs_c = max(1, floor(sum(mask_c) / 800));
qi_c = 1:qs_c:sum(mask_c);
bsum_qi = bsum_c(qi_c);
high = bsum_qi > 0.3;
low  = bsum_qi > 0.01 & ~high;   % skip very low field for clarity

if any(high)
    quiver(x_c(qi_c(high)), z_c(qi_c(high)), ...
           bx_c(qi_c(high)), bz_c(qi_c(high)), 1.5, 'r', 'LineWidth', 1.2);
end
if any(low)
    quiver(x_c(qi_c(low)), z_c(qi_c(low)), ...
           bx_c(qi_c(low)), bz_c(qi_c(low)), 1.5, 'Color', [0.5 0.5 1], 'LineWidth', 0.5);
end

% Mark pole tip position
plot(tip_x*1e6, tip_z*1e6, 'kv', 'MarkerSize', 10, 'MarkerFaceColor', 'y');
hold off;

axis equal; grid on;
xlabel('x [\mum]'); ylabel('z [\mum]');
title('(c) B-field vectors near pole 1 tip');

%% ======== Fig (d): Physical verification curves ========
figure('Name', 'Fig(d): Verification', 'Position', [200 200 700 600]);

% Subplot 1: Radial BSUM decay from pole tip (log-log)
subplot(2,1,1);
radial_mask = abs(d.y) < 0.5e-3 & abs(d.z - tip_z) < 0.5e-3 & d.x < tip_x;
r_rad = abs(d.x(radial_mask) - tip_x);
b_rad = d.bsum(radial_mask);
[r_rad, isort] = sort(r_rad);
b_rad = b_rad(isort);
valid = r_rad > 0;
loglog(r_rad(valid)*1e3, b_rad(valid), 'b.-', 'MarkerSize', 4);
grid on;
xlabel('Distance from pole tip [mm]');
ylabel('|B| [T]');
title('BSUM radial decay from Coil 1 pole tip');

% Subplot 2: BSUM along X through working point
subplot(2,1,2);
xline_mask = abs(d.y) < 0.5e-3 & abs(d.z - SPH_OFST) < 0.5e-3;
x_line = d.x(xline_mask) * 1e3;
b_line = d.bsum(xline_mask);
[x_line, isort2] = sort(x_line);
b_line = b_line(isort2);
semilogy(x_line, b_line, 'b.-', 'MarkerSize', 4);
grid on;
xlabel('x [mm]');
ylabel('|B| [T]');
title('BSUM along x-axis through working point');
xline(0, 'r--', 'WP center');
xline(tip_x*1e3, 'k--', 'Pole tip');

sgtitle('Coil 1 — Physical Verification', 'FontWeight', 'bold');

%% ---- Save figures ----
fig_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

fig_names = {'verify_coil1_a', 'verify_coil1_b', ...
             'verify_coil1_c', 'verify_coil1_d'};
for k = 1:4
    exportgraphics(figure(k), fullfile(fig_dir, [fig_names{k} '.png']), ...
                   'Resolution', 200);
end
fprintf('Figures saved to %s\n', fig_dir);
