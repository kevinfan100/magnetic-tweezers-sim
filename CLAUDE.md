# Magnetic Tweezers ANSYS APDL Simulation Project

## Commands
```bash
# Run single coil (batch mode, no GUI) — run from MT_simulation/
cd MT_simulation
"C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 \
  -dir "results/coil1" -j "coil1" \
  -i "$(pwd)/MT_Modeling_Geometry_Meshing_Solving_Coil1.txt" \
  -o "results/coil1/solve.out"

# Run all 6 coils sequentially
for i in 1 2 3 4 5 6; do
  "C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 \
    -dir "results/coil${i}" -j "coil${i}" \
    -i "$(pwd)/MT_Modeling_Geometry_Meshing_Solving_Coil${i}.txt" \
    -o "results/coil${i}/solve.out"
done
```
- `-dir`: directs MAPDL process temp files (`.err`, `.log`) into `results/coilN/` (gitignored)
- `-j`: sets jobname prefix (e.g. `coil1.err` instead of `file.err`)

## Architecture
```
KevinFan/                            Git root
├── CLAUDE.md                        This file
├── .gitignore                       Excludes ANSYS outputs
├── .claude/rules/                   Path-scoped editing rules
├── references/                      Paper notes & PDFs (cross-project)
│   ├── README.md                    Paper index & usage guide
│   ├── pdfs/                        Original PDFs (gitignored)
│   ├── texts/                       pdftotext extracts + page indexes (gitignored)
│   └── notes/                       Structured Markdown notes (tracked)
└── MT_simulation/                   Magnetic tweezers simulation project
    ├── MT_..._Coil[1-6].txt        APDL scripts (only CURR_ARRAY differs)
    ├── results/coil[1-6]/           ANSYS output files (gitignored, ~10GB)
    ├── agent_docs/                  Detailed documentation for Claude Code
    ├── analysis/                    MATLAB post-processing scripts (future)
    ├── data/                        Processed data: .mat, .csv (tracked)
    └── figures/                     Publication figures: .png, .eps (tracked)
```

## Rules
- 6 Coil scripts are synchronized: only `CURR_ARRAY` values differ (one coil = 1, rest = 0)
- All code comments in English; explanations to user in Traditional Chinese
- Mark all APDL changes with `[ADDED]` or `[MODIFIED]` comments
- Always verify `D,ALL,MAG,0` boundary condition exists before `/SOLU`
- Preserve original commented-out code (prefixed `!****`) unless asked to remove
- Use tab indentation matching original style
- Use dissertation notation (B, Phi, q, K_I, rho, R_a, g_I, etc.) in all discussion and code comments
- Always refer to poles by paper name (P1-P6); mention APDL index only when editing APDL code

## Prohibitions
- NEVER commit ANSYS output files (*.rst, *.db, *.full, etc.)
- NEVER change geometry parameters without explicit user approval
- NEVER modify element types or material properties without approval
- NEVER remove boundary condition section (`[ADDED]` block near line 500)

## Notation Standard
All symbols and terms follow Fei Long's 2016 dissertation. See the full glossary:
- `MT_simulation/agent_docs/notation-glossary.md` - **canonical** symbol/term mapping

Key conventions:
- Use **paper pole names** (P1-P6) in all user-facing text, figures, and discussion
- APDL coil indices (1-6) only in APDL code and raw data context
- Mapping: APDL {1,2,3,4,5,6} = Paper {P1,P3,P6,P5,P2,P4}
- Physical quantities use dissertation symbols: B (flux density), Phi (flux), q (charge), K_I, R_hat, L_i, rho, R_a, g_I, N_c
- Two meanings of rho: physical (500 um) vs fitted (900 um) — always clarify which
- Units: ANSYS outputs Tesla; figures use mT for WP region; dissertation Fig. 2.4 uses Gauss (1 mT = 10 Gauss)

## Detailed Docs
- `MT_simulation/agent_docs/model-validation.md` - **APDL vs dissertation comparison, all issues documented**
- `MT_simulation/agent_docs/notation-glossary.md` - unified notation, dissertation alignment
- `MT_simulation/agent_docs/ansys-environment.md` - ANSYS install, batch mode, hardware
- `MT_simulation/agent_docs/simulation-parameters.md` - geometry, materials, mesh, solver
- `MT_simulation/agent_docs/workflow.md` - 4-stage simulation-to-publication pipeline
- `MT_simulation/agent_docs/troubleshooting.md` - known errors and fixes
- `references/README.md` - paper index, notes-first reading strategy

## Compact Instructions
When context is compressed, preserve:
1. The 6 scripts differ ONLY in CURR_ARRAY (coil N has CURR_ARRAY(N)=1)
2. Boundary condition D,ALL,MAG,0 is mandatory for DSP solver
3. Results go to MT_simulation/results/coilN/ directories
4. User prefers Traditional Chinese explanations
5. Use paper pole names P1-P6 (not APDL indices) in all discussion
6. Notation follows Long 2016 dissertation — see `agent_docs/notation-glossary.md`
