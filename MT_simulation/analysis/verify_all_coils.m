%% verify_all_coils.m — Verify all 6 coil simulation results
% Physical checks and cross-coil comparison for all ANSYS unit-excitation solves.
%
% Prerequisites: run all 6 post_extract_coilN.txt scripts in ANSYS first.
% Results: prints summary table, saves comparison figure.

clear; clc; close all;

%% ---- Constants (from shared mt_constants) ----
c = mt_constants();
SPH_OFST  = c.SPH_OFST;
apdl_to_paper = c.apdl_to_paper;

results_base = fullfile(fileparts(mfilename('fullpath')), '..', 'results');

%% ---- Verify each coil ----
fprintf('============================================================\n');
fprintf('  VERIFICATION OF ALL 6 COILS\n');
fprintf('============================================================\n\n');

nodes_all = zeros(1,6);
nodes_wp  = zeros(1,6);
bmax_all  = zeros(1,6);
bwp_all   = zeros(1,6);
bbnd_all  = zeros(1,6);
pass_all  = true(1,6);

for N = 1:6
    coil_name = sprintf('coil%d', N);
    coil_dir = fullfile(results_base, coil_name);

    fprintf('--- %s (excites %s) ---\n', upper(coil_name), apdl_to_paper{N});

    d  = import_ansys_data(coil_dir, 'all', coil_name);
    wp = import_ansys_data(coil_dir, 'wp',  coil_name);

    % Physical checks
    nan_count = sum(isnan(d.bsum));
    neg_count = sum(d.bsum < 0);
    [bmax, imax] = max(d.bsum);

    r_wp = sqrt(wp.x.^2 + wp.y.^2 + (wp.z - SPH_OFST).^2);
    [~, iwp0] = min(r_wp);
    bsum_wp = wp.bsum(iwp0);

    r_cyl = sqrt(d.x.^2 + d.y.^2);
    bsum_bnd = mean(d.bsum(r_cyl > 79e-3));

    fprintf('  Nodes: %d (all), %d (wp)\n', length(d.node_id), length(wp.node_id));
    fprintf('  NaN: %d, Neg: %d\n', nan_count, neg_count);
    fprintf('  Max BSUM: %.4e T  at (%.3f, %.3f, %.3f) mm\n', ...
        bmax, d.x(imax)*1e3, d.y(imax)*1e3, d.z(imax)*1e3);
    fprintf('  WP center: %.4e T, Boundary: %.4e T\n', bsum_wp, bsum_bnd);

    nodes_all(N) = length(d.node_id);
    nodes_wp(N)  = length(wp.node_id);
    bmax_all(N)  = bmax;
    bwp_all(N)   = bsum_wp;
    bbnd_all(N)  = bsum_bnd;

    pass = (nan_count == 0) && (neg_count == 0) && ...
           (bmax > 0.3 && bmax < 2.0) && ...
           (bsum_wp > 1e-3 && bsum_wp < 50e-3) && ...
           (bsum_bnd < 1e-3);
    pass_all(N) = pass;

    if pass, fprintf('  PASS\n\n');
    else,    fprintf('  FAIL ***\n\n');
    end
end

%% ---- Summary table ----
fprintf('============================================================\n');
fprintf('%-8s %-6s %10s %12s %12s %6s\n', ...
    'Coil', 'Paper', 'Nodes', 'Max BSUM(T)', 'WP BSUM(T)', 'OK');
fprintf('%-8s %-6s %10s %12s %12s %6s\n', ...
    '------', '----', '--------', '----------', '----------', '----');
for N = 1:6
    st = 'PASS'; if ~pass_all(N), st = 'FAIL'; end
    fprintf('%-8s %-6s %10d %12.4e %12.4e %6s\n', ...
        sprintf('coil%d',N), apdl_to_paper{N}, nodes_all(N), ...
        bmax_all(N), bwp_all(N), st);
end
fprintf('\nMax BSUM ratio (upper/lower): %.2f\n', ...
    max(bmax_all)/min(bmax_all));
fprintf('WP BSUM consistency ratio:    %.2f\n', ...
    max(bwp_all)/min(bwp_all));

if all(pass_all)
    fprintf('\nALL 6 COILS PASS\n');
else
    fprintf('\nSOME COILS FAILED\n');
end
fprintf('============================================================\n');

%% ---- Bar chart comparison ----
figure('Name', 'Cross-coil comparison', 'Position', [100 100 900 400]);

subplot(1,2,1);
bar(bmax_all);
set(gca, 'XTickLabel', apdl_to_paper);
ylabel('Max |B| [T]');
title('Peak B-field per coil');
grid on;

subplot(1,2,2);
bar(bwp_all * 1e3);
set(gca, 'XTickLabel', apdl_to_paper);
ylabel('|B| at WP center [mT]');
title('Working-point field per coil');
grid on;

sgtitle('6-Coil Comparison (unit excitation)', 'FontWeight', 'bold');

fig_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
exportgraphics(gcf, fullfile(fig_dir, 'verify_all_coils_comparison.png'), ...
               'Resolution', 200);
fprintf('Figure saved to %s\n', fig_dir);
