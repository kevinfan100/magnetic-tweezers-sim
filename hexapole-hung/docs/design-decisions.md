# Hung Hexapole: Design Decisions & CAD Analysis

> Record of foundation decisions made during 2026-03-30 discussion session.
> These decisions guide the APDL model construction.

---

## 1. Hung CAD Analysis Results

### Assembly (Hexapole_Assembly_FEM.STEP)

28 solids total: 1 yoke + 3 guide posts + 6 blocks (lower) + 6 blocks (upper) + 6 poles + 6 coils

### Parts List (after cleanup)

| Part | Qty | Role | Key Dimensions |
|------|-----|------|----------------|
| Mag_Iron_Ring | 1 | Yoke | R_inner=40, R_outer=52, H=2 mm |
| Mag_Guide_Post | 3 | Lower yoke-to-block bridge | R=4, H=29 mm |
| Pole_Block_Bottom | 3 | Lower pole mount | 18x27x10 mm, R=4 bore |
| Pole_Block_Bottom_Front | 3 | Lower pole front | 22x5x10 mm, R=3.175 bore |
| Pole_Block_Top | 3 | Upper pole mount | 47.5x22x25 mm |
| Pole_Block_Top_Front | 3 | Upper pole front | 22x10x10 mm, R=3.175 bore |
| Mag_Pole_Bottom | 6 | Poles | R=3.175, cone semi-angle=11.3 deg |
| Coil | 6 | Excitation | R_inner=10, R_outer=12, H=17 mm |

### Magnetic Circuit

Lower: Yoke → Guide_Post(R=4) → Block_Bottom → Block_Bottom_Front → Pole → WP
Upper: Yoke → (Coil connects here) → Block_Top → Block_Top_Front → Pole → WP

### Removed Parts (redundant)

- Lower_Mag_Ring: not in FEM assembly
- Upper_Mag_Ring: not in FEM assembly (R=43 not found)
- Upper_Angle_Mount: removed from design
- Hexapole_Assembly_filled.STEP: superseded by FEM version

---

## 2. CAD Constraint Verification (FEM Version)

| Constraint | Result | Status |
|-----------|--------|--------|
| Tip-to-tip = 1.0 mm | P1-P2: 1.000, P3-P4: 1.000, P5-P6: 1.000 | PASS |
| Tips on common sphere | 0.34~0.66 mm from centroid (33% variation) | FAIL |
| Pair axes orthogonal | dot products: 0.23, -0.19, -0.34 | FAIL |
| Alpha = 54.74 deg | Range: 38~59 deg | FAIL |

**Conclusion:** Hung CAD does NOT satisfy hexapole constraints. APDL model must be rebuilt from scratch using correct geometric framework.

---

## 3. Foundation Decisions

### 3.1 Modeling Strategy

**Strategy A: Pure APDL script** — use CYL4, BLOCK, keypoints + VROTAT. No CAD import.

Use Hung component DIMENSIONS (yoke size, pole R, coil R) but Long 2016 GEOMETRY FRAMEWORK (alpha=54.74 deg, R_norm=500 um, correct orthogonal configuration).

### 3.2 P-Numbering: Long 2016 Convention

```
Lower: P1=0 deg, P3=120 deg, P6=240 deg
Upper: P2=180 deg, P4=300 deg, P5=60 deg
Pairs: P1<->P2, P3<->P4, P5<->P6
```

Hung CAD uses different angles (P1=270 deg, etc.) but same geometric structure (120 deg spacing, 60 deg offset, 180 deg pairs). Long 2016 convention chosen for compatibility with existing simulation pipeline.

### 3.3 Coordinate System

- **APDL Origin**: Yoke bottom center = (0,0,0)
- **Discussion**: WP center as reference

### 3.4 Parameters from Long 2016 (unchanged)

- murx = 280 (1018 steel, linear approximation)
- TURNS = 70
- SmartSize = 5
- SPH_FINE_R = 7 mm
- AIR_CYL_R = 80 mm
- AIR_CYL_H = 70 mm

### 3.5 APDL Simplifications

| Hung CAD Parts | APDL Simplification |
|---------------|---------------------|
| Guide_Post + Block_Bottom + Block_Bottom_Front | Cylindrical protrusion (R=5mm) |
| Block_Top + Block_Top_Front | Cylindrical protrusion (R=5mm) |
| Mag_Pole_Bottom (sharp tip) | Cone with 5 um fillet (mesh compatible) |

---

## 4. Cone Axis vs Tip Direction (Key Finding)

The OCP cone axis direction reflects the **physical orientation of the pole body** (from tip toward yoke), NOT the tip direction from WP center. These are different because:

- Lower poles: body points upward toward yoke at ~55 deg from Z-axis
- Upper poles: body points nearly horizontally toward yoke (~84 deg from Z)

But the TIP POSITIONS can still satisfy hexapole constraints — the pole body path is a design choice independent of tip placement.

---

## 5. Known Issues for V1 APDL Script

1. **VOVLAP volume IDs**: Hardcoded after boolean overlap. May need adjustment — verify with VPLOT in ANSYS GUI.
2. **Protrusion simplification**: Cylindrical protrusion replaces complex block geometry. Magnetic reluctance is approximate.
3. **/CWD path**: Hardcoded to specific machine path. Must be updated for lab computer.
