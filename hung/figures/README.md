# Hung Hexapole — Figures

## Folder Structure

```
figures/
├── coil1/ ~ coil6/    Each coil excitation results (70 A-turns, one coil active)
├── geometry/           Model geometry visualization (not coil-specific)
└── README.md           This file
```

## Coil Folders (coil1 ~ coil6)

Each folder contains the same set of figures for a single-coil excitation:

| File | Description | Axes | Range |
|------|-------------|------|-------|
| `Bvector_topview.png` | Top-view B-field vector plot | XY, ±80 mm | 0–1 Tesla |
| `Bfield_xy.png` | \|B\| contour on XY plane (z=0) | XY, ±300 um | mT |
| `Bfield_xz.png` | \|B\| contour on XZ plane (y=0) | XZ, ±300 um | mT |
| `Bfield_3d.png` | 3D B-field arrows in iron only | XYZ, full model | Tesla |

Currently only **coil1** has results. Coil2–6 are pending simulation.

## Geometry Folder

| File | Description |
|------|-------------|
| `sphere_3D.png` | 3D view of 6 pole tips on R=0.5mm sphere, with P1–P6 labels |
| `topview.png` | Top view showing azimuth angles, pole pairing, measured coordinate system |

## Generating Figures

```bash
# Step 1: Run ANSYS simulation (if not already done)
cd hung/
"C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 4 -m 8000 \
  -dir "results/coil1" -j "coil1" \
  -i "apdl/variants/MT_Hung_Simulate_Coil1.txt" -o "results/coil1/solve.out"

# Step 2: Export B-field data
"C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 1 -m 8000 \
  -dir "results/coil1" -j "coil1" \
  -i "apdl/postproc/post_export_data.txt" -o "results/coil1/export_data.out"

# Step 3: Run MATLAB scripts
matlab -r "run('analysis/generate_figures.m')"
matlab -r "run('analysis/generate_fig_3d.m')"
```

Note: MATLAB scripts save to `figures/` root. Manually move to `coil1/` and rename.

## Simulation Parameters

| Parameter | Value |
|-----------|-------|
| Excitation | 70 A-turns (TURNS=70, I=1A) |
| Steel mu_r | 280 (linear, constant) |
| Mesh | 0.3mm tips, 1.5mm steel, 4mm air |
| Solver | magsolv,3 (DSP) |
