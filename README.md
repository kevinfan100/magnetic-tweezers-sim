# Magnetic Tweezers Simulation

ANSYS APDL magnetostatic finite element simulation of hexapole magnetic tweezers for biophysics research.

## Overview

This project implements FEM simulation of a 6-pole magnetic tweezers device, computing the magnetic field (B) under unit-excitation for each coil. Results feed into a point-charge model fitting pipeline for force calibration.

Based on: **Fei Long, "Design, Fabrication, and Calibration of a Hexapole Magnetic Tweezers," PhD Dissertation, Ohio State University, 2016.**

## Repository Structure

```
magnetic-tweezers-sim/
├── hexapole-long2016/       Long 2016 dissertation hexapole design
│   ├── apdl/                ANSYS APDL simulation & extraction scripts
│   ├── analysis/            MATLAB fitting & figure scripts
│   ├── data/                Fitting results (.mat)
│   ├── figures/             Publication figures (.png)
│   ├── docs/                Technical documentation
│   └── results/             ANSYS output (gitignored, ~10 GB/coil)
│
├── studies/                 Parametric & comparison studies
│   └── single-pole-yoke/   Yoke effect on single-pole B field
│
├── references/              Literature notes & paper management
│   ├── notes/               Structured Markdown notes (tracked)
│   ├── pdfs/                Original papers (gitignored)
│   └── texts/               pdftotext extracts (gitignored)
│
└── (future: hexapole-<name>/)  Additional hexapole designs
```

## Prerequisites

- **ANSYS MAPDL** 2025 R2 (or compatible version)
- **MATLAB** R2024b+ (Optimization Toolbox for fitting)
- ~60 GB disk space for full simulation results (6 coils)

## Quick Start

Run a single coil simulation (batch mode):
```bash
cd hexapole-long2016
"C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 \
  -dir "results/coil1" -j "coil1" \
  -i "$(pwd)/apdl/MT_Modeling_Geometry_Meshing_Solving_Coil1.txt" \
  -o "results/coil1/solve.out"
```

Process results in MATLAB:
```matlab
cd hexapole-long2016/analysis
fit_charge_model        % [A] baseline fit
fit_all6_with_bias      % [B-6x] final 19-parameter fit
```

## Key Results (hexapole-long2016)

| Method | Parameters | Error | R_a (A/Wb) |
|--------|-----------|-------|------------|
| [A] Baseline | ell=835 um | 4.94% | 9.21e8 |
| [J] Joint 6-coil | ell=766-818 um | 1.11% | ~1.01e9 |
| [B-6x] Final | 19 params | 0.07% | 1.03e9 |

## References

- Long, F. (2016). PhD Dissertation, Ohio State University.
- Zhang, Z. & Menq, C.H. (2011). IEEE/ASME Trans. Mechatronics.
- Long, F., Matsuura, T. & Bhatt, D. (2016). Actively Controlled Hexapole Electromagnetic Actuating System.
