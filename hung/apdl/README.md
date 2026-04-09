# APDL Scripts

## Geometry Export
| File | Description |
|------|-------------|
| `MT_Hung_SphereModel.txt` | Build full hexapole geometry and export as IGES (MM=1/25.4, SolidWorks compatible) |
| `MT_Hung_SphereModel_filleted.txt` | Same as above, but with 40 um diameter spherical fillet on all 6 pole tips. Method A: smooth tangent fillet, cone semi-angle preserved (11.31°), junction shifted from 15.875 -> 15.793 mm. Output: `Full_Assembly_filleted.iges` |
| `export_parts.txt` | Export individual parts as separate IGES files to `hung/IGES/`. Dimensions are hardcoded — update values when part sizes change, then re-run |
| `export_pole_filleted.txt` | Export single pole with 40 um diameter tip fillet. Output: `Mag_Pole_Bottom_filleted.iges` |

## Simulation (6 Coils)
| File | Active Coil | CURR_ARRAY |
|------|------------|------------|
| `MT_Hung_Simulate_Coil1.txt` | P1 | [1,0,0,0,0,0] |
| `MT_Hung_Simulate_Coil2.txt` | P2 | [0,1,0,0,0,0] |
| `MT_Hung_Simulate_Coil3.txt` | P3 | [0,0,1,0,0,0] |
| `MT_Hung_Simulate_Coil4.txt` | P4 | [0,0,0,1,0,0] |
| `MT_Hung_Simulate_Coil5.txt` | P5 | [0,0,0,0,1,0] |
| `MT_Hung_Simulate_Coil6.txt` | P6 | [0,0,0,0,0,1] |

All 6 files share identical geometry, materials, mesh, and BC. Only `CURR_ARRAY` and `/CWD` differ.

### Coil Settings
- Position: block top + COIL_DZ/2 (touching block upper face)
- Winding: clockwise (N1/N2 swapped, flux toward block)
- R_mean=11mm, DY=2mm, DZ=15mm, TURNS=70

## Post-Processing
| File | Description |
|------|-------------|
| `post_extract_wp.txt` | Extract BX/BY/BZ/BSUM at WP (origin) |
| `post_export_data.txt` | Export full-model + WP-region coordinate and B-field data for MATLAB |
| `post_plot_model.txt` | Generate PNG model views (isometric, top, front) |
| `post_trace_tips.txt` | Extract BSUM at all 6 pole tips + WP center |
| `post_trace_circuit.txt` | Extract BSUM at 8 points along P1 magnetic circuit |

## Running

```bash
# From hung/ directory:
MAPDL="C:\Program Files\ANSYS2025R2\v252\ansys\bin\winx64\MAPDL.exe"

# Simulation
"$MAPDL" -b -np 4 -m 8000 -dir "results/coil1" -j "coil1" -i "apdl/MT_Hung_Simulate_Coil1.txt" -o "results/coil1/solve.out"

# Post-processing (must use -j "coil1" to match result files)
"$MAPDL" -b -np 1 -m 8000 -dir "results/coil1" -j "coil1" -i "apdl/post_extract_wp.txt" -o "results/coil1/wp_extract.out"
```
