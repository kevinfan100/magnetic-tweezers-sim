# Magnetic Tweezers Simulation Project

## Commands
```bash
# Run single coil (batch mode, no GUI) — run from hexapole-long2016/
cd hexapole-long2016
"C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 \
  -dir "results/coil1" -j "coil1" \
  -i "$(pwd)/apdl/MT_Modeling_Geometry_Meshing_Solving_Coil1.txt" \
  -o "results/coil1/solve.out"

# Run all 6 coils sequentially
for i in 1 2 3 4 5 6; do
  "C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 \
    -dir "results/coil${i}" -j "coil${i}" \
    -i "$(pwd)/apdl/MT_Modeling_Geometry_Meshing_Solving_Coil${i}.txt" \
    -o "results/coil${i}/solve.out"
done
```

## Architecture
```
magnetic-tweezers-sim/                   Git root
├── README.md                            Project overview
├── CLAUDE.md                            This file
├── .gitignore                           Excludes ANSYS outputs
├── .claude/rules/                       Path-scoped editing rules
├── hexapole-long2016/                   Long 2016 dissertation design
│   ├── apdl/                            APDL scripts (6 coils + variants)
│   │   ├── MT_..._Coil[1-6].txt        Simulation (only CURR_ARRAY differs)
│   │   └── post_extract_coil[1-6].txt  POST1 data extraction
│   ├── analysis/                        MATLAB fitting & figure scripts
│   │   ├── fit_charge_model.m           [A] baseline (ell, R_a)
│   │   ├── test_joint_6coil_fit.m       [J] 6-coil joint free-3D
│   │   └── fit_all6_with_bias.m         [B-6x] all-excitation ★ final
│   ├── data/                            Fitting results: .mat (tracked)
│   ├── figures/                         Publication figures: .png (tracked)
│   ├── docs/                            Technical documentation
│   └── results/coil[1-6]/              ANSYS output (gitignored, ~10GB)
├── studies/                             Parametric & comparison studies
│   └── single-pole-yoke/               Yoke effect study (9.6x enhancement)
├── references/                          Paper notes & PDFs (cross-design)
│   ├── README.md                        Paper index & usage guide
│   ├── notes/                           Structured Markdown notes (tracked)
│   ├── pdfs/                            Original PDFs (gitignored)
│   └── texts/                           pdftotext extracts (gitignored)
└── (future: hexapole-<name>/)           Additional hexapole designs
```

## Hexapole Design Constraints (Mandatory)

These constraints apply to ALL hexapole designs in this repo. They are non-negotiable.

1. **Orthogonal pair axes**: 3 opposing pole pairs (P1-P2, P3-P4, P5-P6) must have mutually perpendicular connecting lines
2. **Tips on common sphere**: All 6 pole tips at distance R_norm from WP center (R_norm is adjustable)
3. **60-degree azimuthal offset**: Upper layer rotated 60 deg relative to Lower layer
4. **alpha = arctan(sqrt(2)) = 54.74 deg is FIXED**: derived from constraints 1-3, not a free parameter
   - `R_norm_xy = R_norm * sqrt(2/3)` and `R_norm_z = R_norm / sqrt(3)` — these formulas are locked
   - Lower poles at 0, 120, 240 deg; Upper poles at 60, 180, 300 deg

Full derivation and modeling reference: `docs/hexapole-simulation-reference.md`

## Rules
- 6 Coil scripts are synchronized: only `CURR_ARRAY` values differ (one coil = 1, rest = 0)
- All code comments in English; explanations to user in Traditional Chinese
- Mark all APDL changes with `[ADDED]` or `[MODIFIED]` comments
- Always verify `D,ALL,MAG,0` boundary condition exists before `/SOLU`
- Preserve original commented-out code (prefixed `!****`) unless asked to remove
- Use tab indentation matching original style
- Use dissertation notation (B, Phi, q, K_I, rho, R_a, g_I, etc.) in all discussion and code comments
- Always refer to poles by paper name (P1-P6); mention APDL index only when editing APDL code

## Figure Production
- **Never generate figures without discussion first.** Before producing any figure:
  1. **Content**: Discuss what to show — which data, axes, normalization, range
  2. **Style**: Discuss visual details — font, title, legend, colors, line thickness
  3. **Preview**: Use MATLAB MCP to render a draft, review together, iterate
  4. **Finalize**: Only save to `figures/` after user confirmation
- Apply consistent figure style across the project

## Prohibitions
- NEVER commit ANSYS output files (*.rst, *.db, *.full, etc.)
- NEVER change geometry parameters without explicit user approval
- NEVER modify element types or material properties without approval
- NEVER remove boundary condition section (`[ADDED]` block near line 500)
- NEVER change alpha (54.74 deg) or the R_norm_xy / R_norm_z formulas
- NEVER produce a pole configuration that violates pair-axis orthogonality

## Notation Standard
All symbols and terms follow Fei Long's 2016 dissertation. See the full glossary:
- `hexapole-long2016/docs/notation-glossary.md` - **canonical** symbol/term mapping

Key conventions:
- Use **paper pole names** (P1-P6) in all user-facing text, figures, and discussion
- APDL coil indices (1-6) only in APDL code and raw data context
- Mapping: APDL {1,2,3,4,5,6} = Paper {P1,P3,P6,P5,P2,P4}
- Physical quantities use dissertation symbols: B, Phi, q, K_I, R_hat, L_i, rho, R_a, g_I, N_c
- Two meanings of rho: physical (500 um) vs fitted (900 um) — always clarify which
- Units: ANSYS outputs Tesla; figures use mT for WP region; dissertation Fig. 2.4 uses Gauss

## Detailed Docs
- `hexapole-long2016/docs/fitting-methods.md` - **[A]→[J]→[B-6x] fitting methods, [B-6x] is final**
- `hexapole-long2016/docs/model-validation.md` - APDL vs dissertation comparison
- `hexapole-long2016/docs/notation-glossary.md` - unified notation, dissertation alignment
- `hexapole-long2016/docs/coil-winding-sign-convention.md` - pole polarity & coil_sign correction
- `hexapole-long2016/docs/charge-model-fitting.md` - point-charge model derivation
- `hexapole-long2016/docs/ansys-environment.md` - ANSYS install, batch mode, hardware
- `hexapole-long2016/docs/simulation-parameters.md` - geometry, materials, mesh, solver
- `hexapole-long2016/docs/workflow.md` - 4-stage simulation-to-publication pipeline
- `hexapole-long2016/docs/troubleshooting.md` - known errors and fixes
- `docs/hexapole-simulation-reference.md` - **mandatory constraints + modeling procedure for all hexapole designs**
- `references/README.md` - paper index, notes-first reading strategy

## Compact Instructions
When context is compressed, preserve:
1. The 6 scripts differ ONLY in CURR_ARRAY (coil N has CURR_ARRAY(N)=1)
2. Boundary condition D,ALL,MAG,0 is mandatory for DSP solver
3. Results go to hexapole-long2016/results/coilN/ directories
4. User prefers Traditional Chinese explanations
5. Use paper pole names P1-P6 (not APDL indices) in all discussion
6. Notation follows Long 2016 dissertation — see `hexapole-long2016/docs/notation-glossary.md`
7. alpha = 54.74 deg is FIXED for all hexapole designs — see `docs/hexapole-simulation-reference.md`
