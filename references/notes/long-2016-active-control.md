# Actively Controlled Hexapole Electromagnetic Actuating System Enabling 3-D Force Manipulation in Aqueous Solutions

## Bibliographic Info

| Field       | Value |
|-------------|-------|
| Authors     | Fei Long, Daisuke Matsuura, Chia-Hsiang Menq |
| Year        | 2016 (published online Nov 25, 2015; print June 2016) |
| Type        | Journal paper |
| Source      | IEEE/ASME Transactions on Mechatronics, Vol. 21, No. 3, pp. 1540-1551 |
| DOI         | 10.1109/TMECH.2015.2503274 |
| Funding     | NSF CMMI Grant 1067962 and 1200017 |
| PDF file    | `pdfs/Actively_Controlled_Hexapole_Electromagnetic_Actuating_System_Enabling_3-D_Force_Manipulation_in_Aqueous_Solutions.pdf` |
| Total pages | 12 |

## Relevance to This Project

This is the **journal paper version** of the hexapole actuator described in Fei Long's dissertation (Ch. 2-3). It presents the same device we simulate in ANSYS: 1018 steel poles, 40 um tip radius, 70-turn coils, 500 um workspace. It contains the FEM-calibrated K_I matrix (K^FEM_I), the experimentally calibrated K_hat_I, force calibration results, and optimal inverse model. The ANSYS FEM mesh shown in Fig. 2(b) is the direct reference for our simulation.

**Tags:** geometry, materials, fem-simulation, calibration, force-model, inverse-model, superposition, coil-design, optimal-control

## Key Contributions

- New hexapole design using 1018 steel (>2T saturation) replacing thin permalloy film (0.9T), yielding 4x force gain increase
- FEM validation of magnetic charge model: workspace radius rho = 900 um, air reluctance R_a = 6.3e8 A/Wb, error <1%
- FEM-calibrated K_I^FEM matrix showing upper/lower pole asymmetry (diag: 0.83 lower vs 1.04 upper)
- Experimentally calibrated K_hat_I from measurement coils (diag: 0.60-0.63 lower vs 0.90-0.93 upper)
- Optimal inverse model minimizing ||I||^2, orientation-dependent constraints replace constant constraints
- Force generation: ~600 pN (optimal) vs ~100 pN (constant constraints) with 3A max current
- Linear range confirmed up to 3A (no saturation for P2 or P3)

## Detailed Notes by Section

### I. Introduction (pp. 1540-1541, lines 1-75)

Compares AFM, optical tweezers, and magnetic tweezers. Previous magnetic actuators used thin permalloy film poles (100 um thick, 0.9T saturation). Limitations: required custom sample chambers, small cross-section yielded low flux, constant-constraint inverse model limited force. This paper addresses all three with new design and optimal inverse.

Key references: [1] = quadrupole tweezers (Zhang, Huang, Menq 2010), [2] = hexapole actuator design (Zhang and Menq 2011), [40] = 3D visual servo (Zhang, Long, Menq 2013).

### II-A. Design, Synthesis, and Fabrication (pp. 1541-1542, lines 103-161)

Three pairs of poles on three orthogonal axes (actuation coordinate), rigid body rotation applied so tips lie on two horizontal planes.

- Lower poles: P1, P3, P6 — fixed under culture dish, milled flat
- Upper poles: P2, P4, P5 — tips sink into medium above dish
- Opposite pairs: P2<->P1 (+x), P4<->P3 (+y), P6<->P5 (+z) in actuation coordinate
- Each pole has actuation coil (flux generation) + measurement coil (flux measurement)

**Fig. 2(a):** Fabricated prototype on inverted microscope — shows pole labeling and coordinate system.
**Fig. 2(b):** CAD model and meshing of hexapole actuator — **our ANSYS FEM mesh reference**.

### II-B. Finite Element Analysis (pp. 1542-1543, lines 157-207)

- CAD model built and meshed using **ANSYS environment** for FEM calculation (Fig. 2b)
- 1A current applied to coil 1
- Fig. 3(a): Top view vector plot — field forms closed loop guided by poles + yoke
- Fig. 3(b): B vectors in 100 um cube at workspace center — all point to pole 1 tip
- Fig. 3(c): Near pole 1 tip — vectors strongly converge, validates point charge assumption
- Flux density at workspace center is **2x** that of previous thin-foil design
- Fig. 4: Contour plot of |B| in horizontal and vertical planes (in Gauss)

### II-C. Hexapole Magnetic Field Model (pp. 1543, lines 209-263)

**Eq. (1): Superposition field model**
B(p) = sum_{i=1}^{6} k_m * (q_i / r_i^2) * u_i(p)

**Eq. (2): Charge-current relation (Hopkinson's law)**
Q = Phi/mu_0 = (N_c / (mu_0 * R_a)) * K_I * I

Best-fit parameters from FEM:
- Workspace radius (charge location): **rho = 900 um**
- Air reluctance: **R_a = 6.3 x 10^8 A/Wb**
- Fitting error: mostly <1% of flux density norm (Fig. 5b)

**K_I^FEM matrix (Eq. 3) — from FEM fitting, normalized so K_I(1,1) = 5/6:**

| | P1 | P2 | P3 | P4 | P5 | P6 |
|---|---|---|---|---|---|---|
| P1 | **0.8333** | -0.2312 | -0.1935 | -0.1375 | -0.1375 | -0.1935 |
| P2 | -0.4042 | **1.0388** | -0.2481 | -0.1012 | -0.1012 | -0.2481 |
| P3 | -0.1935 | -0.1375 | **0.8333** | -0.2312 | -0.1375 | -0.1935 |
| P4 | -0.2481 | -0.1012 | -0.4042 | **1.0388** | -0.1012 | -0.2481 |
| P5 | -0.2481 | -0.1012 | -0.2481 | -0.1012 | **1.0388** | -0.4042 |
| P6 | -0.1935 | -0.1375 | -0.1935 | -0.1375 | -0.2312 | **0.8333** |

Key: Lower poles (P1, P3, P6) diag = 0.83; Upper poles (P2, P4, P5) diag = 1.04.

### III-A. Hexapole Magnetic Force Model (pp. 1544, lines 269-314)

**Eq. (4): Quadratic force model**
F_i(p_hat, I) = g_I * I^T * K_I^T * L_i(p_hat) * K_I * I, i = x, y, z

**Eq. (5): Maximum force (force generation capability)**
F_max = g_I * I_max^2 = 3V * k_m^2 * [(mu - mu_0) / (2*mu_0*rho^5*(mu + 2*mu_0))] * (N_c / (mu_0 * R_a))^2 * I_max^2

**Eq. (6): Dimensionless force**
F_hat_i = I_hat^T * K_I^T * L_i * K_I * I_hat

### III-B. Inverse Model — Constant Constraints (pp. 1544, lines 316-334)

Constraints: I_hat_1 + I_hat_2 = c_x, I_hat_3 + I_hat_4 = c_y, I_hat_5 + I_hat_6 = c_z

**Eq. (7): Force at center (linear in effective current)**
F_hat_c = 2 * A * delta_I_hat

**Eq. (8): Actuation matrix**
A = diag[(2c_x + c_y + c_z), (c_x + 2c_y + c_z), (c_x + c_y + 2c_z)]

**Eqs. (9-10): Inverse model at center**
[I_hat_1, I_hat_3, I_hat_5] = (1/2)*b + (1/4)*A^{-1}*F_hat_c
[I_hat_2, I_hat_4, I_hat_6] = (1/2)*b - (1/4)*A^{-1}*F_hat_c

Problem: constant bias b causes unnecessarily large currents; force scales linearly (not quadratically) with current.

### III-C. Optimal Inverse Model (pp. 1544-1545, lines 336-396)

**Eq. (11): Optimal current allocation**
I_hat_opt(F_hat_d, p_hat) = ||F_hat_d||^{1/2} * I_opt(r_hat(phi, theta), p_hat)

**Eq. (12): Norm decomposition**
||I_hat||^2 = (1/2)*||delta_I_hat||^2 + c_x^2 + c_y^2 + c_z^2

**Eq. (13): Objective function**
J(c_x, c_y, c_z; phi, theta) = (1/2)*(c_x^2 + c_y^2 + c_z^2) + (1/8)*||A^{-1}*r_hat||^2

Minimizing J yields orientation-dependent optimal constraints c_x(phi,theta), c_y(phi,theta), c_z(phi,theta).

Fig. 7: Optimal constraints vs constant constraints — optimal are much smaller.
Fig. 8: Optimal currents vs constant — each of 6 inputs significantly smaller.

### IV. Stabilization (pp. 1545-1546, lines 397-438)

**Eq. (14): Bead dynamics (Langevin equation)**
m*P_ddot + gamma*P_dot = F_MT(t) + F_T(t)

Inertia negligible -> first-order system.

Fig. 9: Feedback control block diagram (P controller + inverse model).
Fig. 10: Six input currents — optimal allocation yields smaller currents.
Fig. 11: Stabilization results:
- Optimal: std dev = (52.36, 64.51, 28.62) nm
- Constant constraints: std dev = (107.32, 69.95, 28.62) nm

### V. Calibration and Validation (pp. 1546-1548, lines 441-588)

**Flux distribution matrix calibration:**
- Method: electromagnetic induction (Faraday's law) using measurement coils
- E(t) = -N_m * dPhi(t)/dt
- Sinusoidal current to each actuation coil, measure 6 induction voltages (Fig. 12)

**Calibrated K_hat_I matrix (Eq. 15):**

| | P1 | P2 | P3 | P4 | P5 | P6 |
|---|---|---|---|---|---|---|
| P1 | **0.6022** | -0.0124 | -0.0285 | -0.1507 | -0.1668 | -0.0229 |
| P2 | -0.0103 | **0.9322** | -0.1740 | -0.0787 | -0.0680 | -0.1780 |
| P3 | -0.0294 | -0.1655 | **0.6291** | -0.0121 | -0.1458 | -0.0319 |
| P4 | -0.1540 | -0.0712 | -0.0112 | **0.9040** | -0.0746 | -0.1501 |
| P5 | -0.1805 | -0.0712 | -0.1521 | -0.0769 | **0.9026** | -0.0095 |
| P6 | -0.0235 | -0.1726 | -0.0331 | -0.1506 | -0.0123 | **0.6122** |

Lower poles (P1, P3, P6) diag = 0.60-0.63; Upper poles (P2, P4, P5) diag = 0.90-0.93.
Cause: lower poles milled flat -> material removed -> reduced actuation gain.

**Force calibration (Eq. 16):**
- Bead steered along 12 linear trajectories in glycerol at 6.5 um/s
- Viscous force = gamma * v_p = 55 pN (gamma = 8.5e-6 N.s/m)
- N = 14,412 samples, minimize J(g_I, c) = sum ||F_v - F_model||^2
- Degaussed between trajectories

**Three calibration options:**

| Option | K_I used | g_I (pN) | Avg error (pN) |
|--------|----------|----------|----------------|
| 1. Nominal K_I | Theoretical (5/6, -1/6) | [5.37, 6.82, 6.93] | 12.42 |
| 2. Measured K_hat_I | From induction (Eq. 15) | [9.08, 9.64, 8.39] | 10.04 |
| 3. Modified K_tilde_I | Lower rows x 1.2 | [7.56, 8.55, 7.62] | 8.25 |

Thermal force contributes ~4 pN to avg error. Actual modeling error much smaller than 110 pN calibration range.

**K_tilde_I^n matrix (Eq. 17) — best model, normalized so (1,1) = 5/6:**

| | P1 | P2 | P3 | P4 | P5 | P6 |
|---|---|---|---|---|---|---|
| P1 | **0.8333** | -0.0171 | -0.0394 | -0.2085 | -0.2308 | -0.0317 |
| P2 | -0.0119 | **1.0749** | -0.2006 | -0.0908 | -0.0784 | -0.2052 |
| P3 | -0.0407 | -0.2291 | **0.8704** | -0.0167 | -0.2018 | -0.0442 |
| P4 | -0.1775 | -0.0913 | -0.0130 | **1.0423** | -0.0860 | -0.1730 |
| P5 | -0.2081 | -0.0821 | -0.1754 | -0.0887 | **1.0407** | -0.0109 |
| P6 | -0.0326 | -0.2388 | -0.0458 | -0.2085 | -0.0171 | **0.8471** |

Diagonal terms agree well with K_I^FEM; off-diagonal terms differ (FEM uses flux density directly; force calibration uses force; nominal material properties in FEM).

### VI. Force Generation Capability (pp. 1548-1549, lines 591-642)

- Linear range test: P2 and P3 tested up to 3A with Hall sensor — no saturation (Fig. 19)
- F_max = k_I * I_max^2 — new design yields **4x force gain** over previous thin-foil design
- Fig. 20: Force envelopes (nominal models, spatially symmetric):
  - Old design + constant constraints (blue): smallest
  - New design + constant constraints (red): ~4x larger
  - New design + optimal allocation (gray): ~6x larger than old
- Fig. 21: Force envelopes (calibrated models):
  - Lower pole material removal causes asymmetry
  - Significant improvement remains evident

### VII. Conclusion (pp. 1549, lines 616-642)

Future work identified:
1. Extend optimal inverse to entire workspace (not just center)
2. Shorten feedback delay (high-speed vision tracking)
3. Address hysteresis through modeling or real-time sensing

## Equations and Parameters We Use

### Device Parameters

| Parameter | Value | Page |
|-----------|-------|------|
| Pole material | 1018 steel (0.18% C) | p.1542 |
| Saturation limit | >2T | p.1542 |
| Pole diameter | ~6 mm | p.1542 |
| Upper pole length | ~45 mm | p.1542 |
| Lower pole length | ~42 mm (milled flat) | p.1542 |
| Pole tip radius | 40 um | p.1542 |
| Workspace radius (nominal) | 500 um | p.1542 |
| Workspace radius (charge model, FEM fit) | 900 um | p.1543 |
| Air reluctance (FEM fit) | 6.3e8 A/Wb | p.1543 |
| Coil turns | 70 | p.1542 |
| Max current (linear range) | 3 A | p.1549 |
| Bead | Dynabead M-450 Epoxy, 4.5 um | p.1542 |
| Drag coeff (glycerol) | 8.5e-6 N.s/m | p.1547 |
| Cover glass thickness | ~100 um | p.1541 |
| k_m = mu_0/(4*pi) | 1.0e-7 N/A^2 | p.1543 |

### Key Equations

| Eq. | Expression | Description |
|-----|-----------|-------------|
| (1) | B = sum k_m*q_i/r_i^2 * u_i | Hexapole field (superposition) |
| (2) | Q = (N_c/(mu_0*R_a)) * K_I * I | Charge-current relation |
| (3) | K_I^FEM (6x6 matrix) | FEM-calibrated flux distribution |
| (4) | F_i = g_I * I^T * K_I^T * L_i * K_I * I | Quadratic force model |
| (5) | F_max = g_I * I_max^2 | Force generation capability |
| (6) | F_hat_i = I_hat^T * K_I^T * L_i * K_I * I_hat | Dimensionless force |
| (7) | F_hat_c = 2*A*delta_I_hat | Center force (constant constraints) |
| (11) | I_opt = ||F_d||^{1/2} * I_unit(phi,theta) | Optimal inverse model |
| (15) | K_hat_I (6x6 matrix) | Experimentally calibrated K_I |
| (17) | K_tilde_I^n (6x6 matrix) | Best-fit K_I (lower x 1.2) |

## Figures Worth Revisiting

| Figure | Page | Description | Why revisit |
|--------|------|-------------|-------------|
| Fig. 1 | p.1541 | (a) CAD of motion stage + lower poles; (b) yoke ring + upper poles | Geometry reference |
| Fig. 2 | p.1542 | (a) Prototype with pole labels; (b) **CAD model + FEM mesh** | **Critical** — our ANSYS mesh reference |
| Fig. 3 | p.1543 | (a) Top view B vectors; (b) workspace center; (c) near pole 1 tip | Validate our FEM results |
| Fig. 4 | p.1543 | Contour |B| horizontal + vertical planes (Gauss) | Compare with our contour plots |
| Fig. 5 | p.1543 | (a) FEM vs model vectors; (b) error norms <1% | Charge model validation |
| Fig. 19 | p.1549 | Linear range test P2 and P3 to 3A | **Critical** — no saturation at 3A |
| Fig. 20-21 | p.1549 | Force envelopes (nominal + calibrated) | Force capability comparison |

## Cross-References

- **[zhang-2011-actuator-design](zhang-2011-actuator-design.md)** (Ref. [2]): Previous hexapole design with thin permalloy film poles. This paper's new 1018 steel design replaces it.
- **[zhang-dissertation](zhang-dissertation.md)**: Quadrupole predecessor. Theoretical framework extended here to hexapole.
- **[long-2016-dissertation](long-2016-dissertation.md)**: This paper = Ch. 2-3 of the dissertation. Dissertation adds Hall sensors (Ch. 4) and dynamic force sensing (Ch. 5).

## Page Ranges for Claude

| Pages   | Main Topic |
|---------|------------|
| 1-2 (lines 1-75) | Title, abstract, introduction |
| 2-3 (lines 76-161) | Design concept, fabrication, prototype |
| 3-4 (lines 157-263) | FEM analysis, field model, K_I^FEM matrix |
| 4-5 (lines 265-396) | Force model, constant/optimal inverse |
| 6-7 (lines 397-461) | Stabilization, control results |
| 7-9 (lines 441-588) | K_hat_I calibration, force calibration |
| 9-10 (lines 591-642) | Linear range, force capability |
| 10-12 (lines 642-773) | Conclusion, references, author bios |

## Relationship to Our ANSYS Simulation

**What we reproduce:** The exact CAD geometry (1018 steel, 40 um tip, 6 mm poles), FEM mesh (Fig. 2b), unit excitation (1A per coil), magnetic field distribution (Figs. 3-4).

**What our simulation adds:** Full 3D field data export, systematic verification of all 6 coils, potential re-fitting of K_I and rho.

**FEM details NOT specified in paper:** Element types, mesh size, boundary conditions, solver settings. Our APDL scripts use SOLID96 elements, SmartSize 5, DSP solver, MAG=0 BC.
