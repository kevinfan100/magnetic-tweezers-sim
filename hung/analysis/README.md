# MATLAB Analysis Scripts

## Prerequisites
- Run ANSYS simulation first (`MT_Hung_Simulate_CoilN.txt`)
- Run data export (`post_export_data.txt`) to produce `.dat` files in `results/coilN/`

## Scripts

| File | Description |
|------|-------------|
| `import_ansys_data.m` | Read ANSYS-exported coordinate + B-field `.dat` files. Handles MAPDL banner headers and concatenated negative numbers. Returns struct with node_id, x, y, z, bx, by, bz, bsum |
| `mt_constants.m` | Hung hexapole design constants: R_norm, tip positions, yoke dimensions, pole angles |
| `generate_figures.m` | Generate fig2_3a (vector), fig2_4a (XY contour), fig2_4b (XZ contour) matching Long 2016 dissertation style |
| `generate_fig_3d.m` | Generate 3D B-field arrow plot showing flux flow inside iron structure |

## Usage

```matlab
% Generate all figures for coil1
run('generate_figures.m')    % produces Bvector_topview, Bfield_xy, Bfield_xz
run('generate_fig_3d.m')     % produces Bfield_3d
```

Output goes to `hung/figures/`. Manually move to the appropriate `coilN/` subfolder.

## Data Format
The `.dat` files produced by `post_export_data.txt`:
- `coil1_coord_all.dat` / `coil1_coord_wp.dat` — node coordinates (NODE, X, Y, Z)
- `coil1_bfield_all.dat` / `coil1_bfield_wp.dat` — B-field (NODE, BX, BY, BZ, BSUM)
- WP region = nodes within 2mm of origin
- Units: SI (meters, Tesla)

## Style Parameters (matching Long2016)
- Font: Helvetica, 12pt labels, 13pt titles
- Colormap: turbo(256)
- DPI: 300 (figures), 400 (3D)
- Contour: 20 levels, no line edges
