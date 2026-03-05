# Magnetic Tweezers ANSYS APDL Simulation Project

## Commands
```bash
# Run single coil (batch mode, no GUI)
"C:\Program Files\ANSYS Inc\v252\ANSYS\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 -i "MT_Modeling_Geometry_Meshing_Solving_Coil1.txt" -o "results\coil1\solve.out"

# Run all 6 coils sequentially
for i in 1 2 3 4 5 6; do "C:\Program Files\ANSYS Inc\v252\ANSYS\bin\winx64\MAPDL.exe" -b -np 4 -m 24000 -i "MT_Modeling_Geometry_Meshing_Solving_Coil${i}.txt" -o "results\coil${i}\solve.out"; done
```

## Architecture
```
MT_..._Coil[1-6].txt    APDL scripts (one per coil, only CURR_ARRAY differs)
results/coil[1-6]/       ANSYS output files (gitignored, ~10GB total)
analysis/                MATLAB post-processing scripts (future)
data/                    Processed data: .mat, .csv (tracked)
figures/                 Publication figures: .png, .eps (tracked)
agent_docs/              Detailed documentation for Claude Code
.claude/rules/           Path-scoped editing rules
```

## Rules
- 6 Coil scripts are synchronized: only `CURR_ARRAY` values differ (one coil = 1, rest = 0)
- All code comments in English; explanations to user in Traditional Chinese
- Mark all APDL changes with `[ADDED]` or `[MODIFIED]` comments
- Always verify `D,ALL,MAG,0` boundary condition exists before `/SOLU`
- Preserve original commented-out code (prefixed `!****`) unless asked to remove
- Use tab indentation matching original style

## Prohibitions
- NEVER commit ANSYS output files (*.rst, *.db, *.full, etc.)
- NEVER change geometry parameters without explicit user approval
- NEVER modify element types or material properties without approval
- NEVER remove boundary condition section (`[ADDED]` block near line 500)

## Detailed Docs
- `agent_docs/ansys-environment.md` - ANSYS install, batch mode, hardware
- `agent_docs/simulation-parameters.md` - geometry, materials, mesh, solver
- `agent_docs/workflow.md` - 4-stage simulation-to-publication pipeline
- `agent_docs/troubleshooting.md` - known errors and fixes

## Compact Instructions
When context is compressed, preserve:
1. The 6 scripts differ ONLY in CURR_ARRAY (coil N has CURR_ARRAY(N)=1)
2. Boundary condition D,ALL,MAG,0 is mandatory for DSP solver
3. Results go to results/coilN/ directories
4. User prefers Traditional Chinese explanations
