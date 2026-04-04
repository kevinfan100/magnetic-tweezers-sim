# Hung Hexapole Magnetic Tweezers — FEM Simulation

## Overview
ANSYS APDL magnetostatic simulation of the Hung hexapole magnetic tweezers design.
6 tilted poles on a R=0.5mm sphere at magic angle (54.74°), with 1018 steel (mu_r=280).

## Folder Structure

```
hung/
├── apdl/        APDL scripts: geometry export + 6 coil simulations + post-processing
├── analysis/    MATLAB scripts: data import, figure generation
├── comsol/      COMSOL Multiphysics models (alternative FEM, independent from APDL)
├── docs/        Technical documentation: workflow, geometry, troubleshooting
├── figures/          Output figures organized by coil (coil1~6) + geometry
├── IGES/             IGES exports: raw ANSYS output (unit flag=6)
├── IGES_converted/   IGES exports: unit flag fixed (flag=1), safe for STEP conversion
├── results/          ANSYS simulation outputs: coil1~6 (gitignored, ~10GB each)
└── README.md    This file
```

## Quick Start

```bash
# 1. Build model and export IGES (for SolidWorks verification)
MAPDL -b -np 1 -m 8000 -dir "results/coil1" -j "coil1" -i "apdl/MT_Hung_SphereModel.txt"

# 2. Run simulation (coil 1)
MAPDL -b -np 4 -m 8000 -dir "results/coil1" -j "coil1" -i "apdl/MT_Hung_Simulate_Coil1.txt"

# 3. Extract B-field data
MAPDL -b -np 1 -m 8000 -dir "results/coil1" -j "coil1" -i "apdl/post_export_data.txt"

# 4. Generate figures (MATLAB)
run('analysis/generate_figures.m')
```

## Design Parameters

| Parameter | Value |
|-----------|-------|
| R_sphere | 0.5 mm |
| TILT_UP (P2,P4,P5) | 35° |
| TILT_DN (P1,P3,P6) | 5.71° |
| Pole total length | 43.0 mm |
| Pole shaft radius | 3.175 mm |
| Coil R_in / R_out | 10 / 12 mm |
| Coil height | 15 mm |
| Turns | 70 |
| Steel mu_r | 280 |

## Key Results (Coil1 Excitation, 70 A-turns)

| Location | Hung | Long2016 |
|----------|------|----------|
| P1 tip (R=0.5mm) | 333 mT | 350 mT |
| WP geometric center | 9.3 mT | 8.7 mT |

Both designs produce equivalent B-field at the working point.
