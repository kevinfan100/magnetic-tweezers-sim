# Hexapole Hung Design

6-pole magnetic tweezers simulation based on Hung Lab hexapole design, using Long 2016 geometric framework.

## Design Parameters

| Parameter | Value | Source |
|-----------|-------|--------|
| R_norm | 500 um | Hexapole constraint |
| Alpha | 54.74 deg | Hexapole constraint (fixed) |
| Yoke R_inner / R_outer | 40 / 52 mm | Hung CAD (Mag_Iron_Ring) |
| Yoke thickness | 2 mm | Hung CAD |
| Pole base R | 3.175 mm | Hung CAD (Mag_Pole_Bottom) |
| Pole cone semi-angle | 11.3 deg | Hung CAD |
| Pole tip R | 5 um (near-sharp) | Simplified (Hung has sharp tip) |
| Coil R_inner / R_outer | 10 / 12 mm | Hung CAD (Coil) |
| Coil height | 17 mm | Hung CAD |
| Coil turns | 70 | Same as Long 2016 |
| murx (steel) | 280 | Same as Long 2016 |

## Simplifications

- Protrusions: cylindrical (R=5mm), simplified from Hung's Pole_Blocks + Guide_Post
- Tip: near-sharp (5 um fillet) instead of perfectly sharp (for mesh compatibility)
- P-numbering: Long 2016 convention (P1=0 deg, etc.)

## Hung CAD Reference

Original CAD files in separate repo: `magnetic-tweezer-cad/hung/step_for_fem/`

Hung CAD parts mapped to APDL simplifications:
- Mag_Iron_Ring -> Yoke (CYL4)
- Mag_Guide_Post + Pole_Block_Bottom + Pole_Block_Bottom_Front -> Lower protrusion (CYL4)
- Pole_Block_Top + Pole_Block_Top_Front -> Upper protrusion (CYL4)
- Mag_Pole_Bottom -> Pole (VROTAT)
- Coil -> SOURC36

## Status

- [x] Coil 1 APDL script created (first version)
- [ ] ANSYS geometry verification (VPLOT)
- [ ] Coil 1 solve + B-field check
- [ ] Coils 2-6 scripts
- [ ] MATLAB post-processing
