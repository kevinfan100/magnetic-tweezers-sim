# IGES Part Exports

## Description
Individual part IGES files exported from ANSYS with SolidWorks-compatible units (MM=1/25.4).
SolidWorks reads values as inches x 25.4 = correct mm dimensions.

## Files

| File | Part | Key Dimensions |
|------|------|---------------|
| `Mag_Pole_Bottom.iges` | Magnetic pole (D-shape + cone) | R=3.175mm, cone=15.875mm, total=43mm, flat=28mm |
| `Pole_Block_Top.iges` | Upper block (L-shape) | 25x22x10mm, penetration=7mm |
| `Pole_Block_Bottom.iges` | Lower block (L-shape) | 22x22x10mm, penetration=4.5mm |
| `Mag_Guide_Post.iges` | Guide post cylinder | R=4mm, H=46mm |
| `Coil.iges` | Excitation coil ring | R_in=10mm, R_out=12mm, H=15mm |
| `Upper_Ring.iges` | Yoke (iron ring) | R_in=38mm, R_out=62.5mm, T=2mm |
| `Full_Assembly.iges` | Complete hexapole assembly | All parts assembled, unit flag=1 (inches) |

## STEP Conversion
To convert to STEP for other CAD software:
1. Open IGES in SolidWorks (dimensions will be correct mm)
2. File → Save As → .STEP

`Full_Assembly.iges` has unit flag fixed to 1 (inches) for reliable STEP conversion.

## Regenerating
When part dimensions change:
1. Update values in `hung/apdl/export_parts.txt`
2. Run: `MAPDL -b -np 1 -m 2000 -dir "IGES" -j "parts" -i "apdl/export_parts.txt"`
3. For full assembly: run `apdl/MT_Hung_SphereModel.txt`, copy output to `Full_Assembly.iges`, fix unit flag with `sed -i "s/,1.0,6,,/,1.0,1,,/" Full_Assembly.iges`
