# Single-Pole Yoke Effect Study

Quantifies how the iron yoke affects the magnetic field of a single pole (P1).

## Comparison

| Metric | Case A (bare pole) | Case B (pole + yoke) | Ratio |
|--------|-------------------|---------------------|-------|
| B at WP center | 0.646 mT | 6.174 mT | 9.55x |
| Max B in WP | 18.3 mT | 213.8 mT | 11.7x |

## Key Findings

1. **Field Enhancement**: Yoke provides ~9.6x enhancement at workspace center
2. **Shape Preserved**: Normalized axial profile correlation = 0.9989 — yoke mainly affects magnitude, not spatial distribution
3. **Magnetic Circuit**: Simple series reluctance model underestimates the effect; yoke acts as a flux collector, not just a return path
4. **Effective R_a**: Bare pole R_a = 1.24e10, with yoke R_a = 1.29e9 (ratio matches field enhancement)

## Files

- `apdl/MT_SinglePole_Only.txt` — Case A: bare pole + coil, no yoke
- `apdl/MT_SinglePole_WithYoke.txt` — Case B: pole + coil + yoke
- `apdl/post_view_Bfield.txt` — POST1 visualization (GUI)
- `analysis/compare_yoke_effect.m` — V1 (enhancement) + V2 (distribution) + V3 (magnetic circuit)
- `data/yoke_comparison.mat` — Saved results
- `figures/` — B field contour and vector plots
