%% generate_contour_figures.m — |B| contour plots for paper comparison
% Generates Figures C and D matching Long & Menq (2016) Fig. 4:
%   C: Horizontal contour (XY plane at z_wp = 0)
%   D: Vertical contour   (XZ plane at y_wp = 0)
%
% Prerequisites: run post_extract_coil1.txt in ANSYS first.

clear; clc; close all;

%% ---- Load constants and data ----
c = mt_constants();
results_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'coil1');
fig_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

fprintf('Loading working-point dataset...\n');
wp = import_ansys_data(results_dir, 'wp');

% WP-centered coordinates
x_wp = wp.x;                    % [m] — WP is on Z-axis, no XY shift
y_wp = wp.y;
z_wp = wp.z - c.SPH_OFST;       % [m] — shift so WP center = 0

fprintf('WP nodes: %d\n', length(wp.node_id));

%% ---- Common parameters ----
slice_tol = 50e-6;    % slice thickness [m] (50 um half-width)
grid_n    = 200;      % interpolation grid resolution
range_um  = 2000;     % plot range [um] (±2000 um = ±2 mm)
n_levels  = 20;       % number of contour levels

%% ======== Figure C: Horizontal contour — XY at z_wp = 0 ========
mask_xy = abs(z_wp) < slice_tol;
fprintf('Fig C: %d nodes in XY slice (|z_wp| < %.0f um)\n', sum(mask_xy), slice_tol*1e6);

if sum(mask_xy) < 50
    slice_tol_xy = 100e-6;
    mask_xy = abs(z_wp) < slice_tol_xy;
    fprintf('  Expanded to %.0f um: %d nodes\n', slice_tol_xy*1e6, sum(mask_xy));
end

xq = linspace(-range_um, range_um, grid_n) * 1e-6;  % [m]
yq = linspace(-range_um, range_um, grid_n) * 1e-6;
[Xg, Yg] = meshgrid(xq, yq);

F_xy = scatteredInterpolant(x_wp(mask_xy), y_wp(mask_xy), wp.bsum(mask_xy), ...
                            'natural', 'none');
Bg_xy = F_xy(Xg, Yg) * 1e3;  % convert to mT

figure('Name', 'Fig C: |B| contour XY', 'Position', [50 50 800 700]);
contourf(Xg*1e6, Yg*1e6, Bg_xy, n_levels, 'LineColor', 'none');
colormap(jet);
cb = colorbar;
ylabel(cb, '|B| [mT]');
hold on;

% Mark pole tip positions (only lower poles visible at z_wp ~ 0 plane)
for k = 1:6
    px = c.pole_tip_x(k) * 1e6;
    py = c.pole_tip_y(k) * 1e6;
    if abs(px) <= range_um && abs(py) <= range_um
        plot(px, py, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
        text(px, py + 120, c.pole_labels{k}, ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
end

% WP center marker
plot(0, 0, 'k+', 'MarkerSize', 12, 'LineWidth', 2);
hold off;

axis equal; grid on;
xlim([-range_um range_um]); ylim([-range_um range_um]);
xlabel('x [\mum]'); ylabel('y [\mum]');
title('|B| in horizontal plane (z_{wp} = 0), Coil 1 excited');

exportgraphics(gcf, fullfile(fig_dir, 'contour_xy_coil1.png'), 'Resolution', 300);
fprintf('Saved contour_xy_coil1.png\n');

%% ---- Record Figure C color limits for consistent scaling ----
clim_xy = clim;  % save [cmin cmax] from Figure C

%% ======== Figure D: Vertical contour — XZ at y_wp = 0 ========
mask_xz = abs(y_wp) < slice_tol;
fprintf('Fig D: %d nodes in XZ slice (|y_wp| < %.0f um)\n', sum(mask_xz), slice_tol*1e6);

if sum(mask_xz) < 50
    slice_tol_xz = 100e-6;
    mask_xz = abs(y_wp) < slice_tol_xz;
    fprintf('  Expanded to %.0f um: %d nodes\n', slice_tol_xz*1e6, sum(mask_xz));
end

zq = linspace(-range_um, range_um, grid_n) * 1e-6;
[Xg2, Zg2] = meshgrid(xq, zq);

F_xz = scatteredInterpolant(x_wp(mask_xz), z_wp(mask_xz), wp.bsum(mask_xz), ...
                            'natural', 'none');
Bg_xz = F_xz(Xg2, Zg2) * 1e3;  % convert to mT

% Clamp to same color range as horizontal plot for consistent comparison
Bg_xz_clamped = min(Bg_xz, clim_xy(2));

figure('Name', 'Fig D: |B| contour XZ', 'Position', [100 100 800 700]);
contourf(Xg2*1e6, Zg2*1e6, Bg_xz_clamped, n_levels, 'LineColor', 'none');
colormap(jet);
clim(clim_xy);
cb2 = colorbar;
ylabel(cb2, '|B| [mT]');
hold on;

% Mark pole tip positions in XZ plane (P1 at +x lower, P2 at -x upper)
for k = 1:6
    px = c.pole_tip_x(k) * 1e6;
    pz = c.pole_tip_z_wp(k) * 1e6;
    if abs(px) <= range_um && abs(pz) <= range_um
        plot(px, pz, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5);
        text(px, pz + 120, c.pole_labels{k}, ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
end

% WP center marker
plot(0, 0, 'k+', 'MarkerSize', 12, 'LineWidth', 2);
hold off;

axis equal; grid on;
xlim([-range_um range_um]); ylim([-range_um range_um]);
xlabel('x [\mum]'); ylabel('z [\mum]');
title('|B| in vertical plane (y_{wp} = 0), Coil 1 excited');

exportgraphics(gcf, fullfile(fig_dir, 'contour_xz_coil1.png'), 'Resolution', 300);
fprintf('Saved contour_xz_coil1.png\n');

fprintf('\nDone. Figures saved to %s\n', fig_dir);
