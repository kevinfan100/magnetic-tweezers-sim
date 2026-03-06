# Three-Dimensional Motion Control and Dynamic Force Sensing of a Magnetically Propelled Micro Particle Using a Hexapole Magnetic Actuator

## Bibliographic Info

| Field       | Value |
|-------------|-------|
| Authors     | Fei Long |
| Advisor     | Chia-Hsiang Menq |
| Year        | 2016 |
| Type        | PhD Dissertation |
| Source      | The Ohio State University, Department of Mechanical Engineering |
| DOI/URL     | ProQuest 10145113 |
| PDF file    | `pdfs/Fei Long_dissertation.pdf` |
| Total pages | 167 (xxiv + 141 numbered) |
| Committee   | Chia-Hsiang Menq (advisor), Manoj Srinivasan, Rama Yedavalli, Vadim I. Utkin |

## Relevance to This Project

This is the **primary source** for the hexapole magnetic tweezers device we are simulating in ANSYS. It contains the complete device design (geometry, materials, coil specs), the FEM simulation methodology, the lumped-parameter magnetic force model, pole naming conventions, calibration procedures, and all key equations. Every aspect of our ANSYS simulation is based on this work.

**Tags:** geometry, materials, fem-simulation, calibration, force-model, inverse-model, pole-naming, coil-design, superposition, hall-sensor, dynamic-force-sensing

## Key Contributions

- Design and fabrication of a hexapole electromagnetic actuator using 1018 low-carbon steel (saturation >2T) with sharp-tipped poles (tip radius 40 um)
- Lumped-parameter magnetic force model: magnetic charge approximation validated by FEM, force is quadratic in current/flux
- Optimal inverse model minimizing 2-norm of currents (replaces constant-constraint approach), enabling real-time FPGA control at 1606 Hz
- Hall-sensor-based force model that bypasses hysteresis issues, achieving sub-pN accuracy
- Langevin-function model for nonlinear bead magnetization at high fields (>50 Gauss)
- Joint state-parameter estimator (Kalman filter) for simultaneous dynamic force sensing and drag coefficient estimation
- Calibrated flux distribution matrix K_I showing asymmetry between upper and lower poles
- Force generation capability: ~600 pN (optimal allocation) vs. ~100 pN (constant constraints) with 3A max current

## Detailed Notes by Section

### Abstract (pp. ii-iv, lines 82-196)

The dissertation develops a hexapole 3D magnetic actuator for use as a scanning probe system. Key capabilities: bead stabilization, trajectory tracking, accurate force modeling, and dynamic force sensing. The system is over-actuated (6 poles, 3 DOF force). Four main challenges: redundancy/coupling, instability, nonlinearity, position dependency. Hall sensors solve the hysteresis problem. Langevin function models nonlinear bead magnetization. Kalman filter enables dynamic force sensing.

### Chapter 1: Introduction (pp. 1-9, lines 973-1352)

#### 1.1 Background and Motivation (pp. 1-5)
- Magnetic tweezers advantages over optical tweezers: biocompatible, no heating, specific to magnetic particles
- Magnetic force field is inherently unstable (Earnshaw's theorem) -- feedback control required
- Previous designs used thin (~100 um) permalloy film poles -- limited flux and saturation (0.9T)
- Previous inverse model used constant constraints, resulting in excessive current and limited force

#### 1.2 Objectives and Specific Aims (pp. 5-8)
Four aims:
1. Hardware development, magnetic force modeling and calibration
2. Optimal inverse model and control (stabilization, Brownian motion control, trajectory tracking)
3. Hall sensor based 3D magnetic force modeling and feedback control
4. Dynamic force sensing and parameter estimation

#### 1.3 Dissertation Overview (pp. 8-9)
Chapter-by-chapter summary of the dissertation structure.

### Chapter 2: Design, Force Modeling and Inverse Modeling (pp. 10-42, lines 1353-2656)

**This is the most critical chapter for our simulation work.**

#### 2.2.1 Design, Synthesis, and Fabrication (pp. 12-15)

**Pole arrangement:**
- Three pairs of poles aligned on three orthogonal axes (actuation coordinate)
- Rigid body rotation applied so all tips lie on two parallel horizontal planes (upper and lower)
- Upper poles: P2, P4, P5; Lower poles: P1, P3, P6
- Opposite pairs: P2<->P1 (+x), P4<->P3 (+y), P6<->P5 (+z) in actuation coordinate

**Physical dimensions:**
- Pole material: **1018 steel** (low-carbon, 0.18% C), saturation limit **>2T**
- Pole diameter: **~6 mm**
- Upper poles length: **~45 mm**
- Lower poles length: **~42 mm** (milled flat to support culture dish)
- Pole tip radius: **40 um** (included in FEM model)
- Workspace radius (tip-to-center distance): **500 um** nominal (adjustable)
- Cover glass thickness between upper and lower planes: **~100 um**

**Coil specifications:**
- Actuation coils: **70 turns** each, wound around yoke protrusions
- Maximum current: **3 A** (linear range verified, no saturation at 3A)
- Power amplifiers: Micro Dynamics BTA-28V-6A, current mode, 10 kHz bandwidth
- DA converters: Measurement Computing PCI-DAS6032

**Magnetic bead:**
- Dynabead M-450 Epoxy, diameter **4.5 um**
- Superparamagnetic (aggregated gamma-Fe2O3 nanoparticles)
- Magnetic saturation: ms = 1.50e-12 Am^2 (nominal, recalculated as 1.40e-12)
- Linear magnetization range: up to ~50 Gauss

**Experimental setup:**
- Inverted microscope: Olympus IX 81, 60x dry objective
- CMOS camera: Mikrotron MC3010
- Image grabbing: Matrix Odyssey XCL
- Piezo positioner: PI P-721 PIFOC (lens driving for z calibration)
- Vibration isolation: Newport Smart Table + Herzan TS-150

#### 2.2.2 Finite Element Analysis of the Magnetic Field (pp. 15-17)

- CAD model built in **ANSYS** imitating real setup
- FEM analysis with 1A current applied to coil 1
- Magnetic field forms closed loop guided by poles + yoke
- Field vectors within 100 um cube at workspace center all point toward pole 1 tip
- Field vectors near tip strongly converge -- validates point charge assumption
- Flux density near workspace center is **2x** that of previous thin-foil design
- Fig.2.2(b): CAD model and meshing shown (important figure for our simulation)
- Fig.2.3: Vector plot of B field distribution, workspace center vectors, tip convergence
- Fig.2.4: Contour plot of |B| in horizontal and vertical planes (units: Gauss)

#### 2.2.3 Hexapole Magnetic Field Model (pp. 17-21)

**Coordinate systems:**
- Measurement coordinate: {O; x_m, y_m, z_m} -- aligned with microscope/camera
- Actuation coordinate: {O; x_a, y_a, z_a} -- aligned with pole pair axes
- Rotation matrix R_ma between the two frames needed for control

**Pole-current assignment (actuation coordinate):**
- Lower poles/charges: I1 (P1), I3 (P3), I6 (P6)
- Upper poles/charges: I2 (P2), I4 (P4), I5 (P5)

**Magnetic charge model (Eq. 2.1-2.3):**
- Each sharp tip behaves as a point magnetic charge: q_i = Phi_i / mu_0
- Field from charge i: B_i(p, b_i) = k_m * (q_i / r_i^2) * u_i, where k_m = mu_0/(4*pi) = 1.0e-7 N/A^2
- Total field: B(p, b) = (k_m / rho^2) * R_hat(p_hat, b) * Q (Eq. 2.3)
  - R_hat: 3x6 Charge-Bead Distribution Matrix
  - Q: 6x1 Charge Vector
  - rho: workspace radius (distance from charge to center)
  - b: 18-dimensional Bias Vector (charge locations may differ from tip locations)

**Flux distribution (Eq. 2.4):**
- Phi = K_I * [F1...F6]^T / R_a, where F_i = N_c * I_i (magnetomotive force)
- N_c = 70 (coil turns)
- R_a = lumped air reluctance from pole tip to workspace center
- K_I: 6x6 flux distribution matrix describing magnetic coupling among 6 poles
- Q = Phi/mu_0 = (N_c / (mu_0 * R_a)) * K_I * I

**Best-fit parameters from FEM:**
- Workspace radius rho = **900 um** (effective magnetic charge location, NOT the physical tip distance of 500 um)
- Air reluctance R_a = **6.3e8 A/Wb**
- Fitting error: mostly <1% of flux density norm (Fig. 2.6)

#### 2.3.1 General Magnetic Force Model (pp. 21-22)

**Gradient force on superparamagnetic particle (Eq. 2.5-2.6):**
- F = (1/2) * grad(m . B), where m = (3V/mu_0) * [(mu - mu_0)/(mu + 2*mu_0)] * B
- Force model in quadratic form: F_i(p_hat, Phi) = f_Phi * (1/mu_0^2) * Phi^T * L_i(p_hat) * Phi, i = x,y,z
- f_Q = magnetic charge force gain (depends on bead properties and geometry)
- f_Phi = f_Q * mu_0^2 = magnetic flux force gain
- L_x, L_y, L_z: 6x6 Charge-Bead Gradient Matrices (position-dependent)

#### 2.3.2 Current-Based Magnetic Force Model (pp. 22-24)

**Force model (Eq. 2.7):**
- F_i(p_hat, I) = g_I * I^T * K_I^T * L_i(p_hat) * K_I * I, i = x,y,z
- g_I = 3V*(mu - mu_0)*k_m^2 / (2*mu_0*(mu + 2*mu_0)*rho^5) * (N_c/(mu_0*R_a))^2

**Nominal flux distribution matrix K_I (Eq. 2.8):**

    K_I = [ 5/6  -1/6  -1/6  -1/6  -1/6  -1/6 ]
          [-1/6   5/6  -1/6  -1/6  -1/6  -1/6 ]
          [-1/6  -1/6   5/6  -1/6  -1/6  -1/6 ]
          [-1/6  -1/6  -1/6   5/6  -1/6  -1/6 ]
          [-1/6  -1/6  -1/6  -1/6   5/6  -1/6 ]
          [-1/6  -1/6  -1/6  -1/6  -1/6   5/6 ]

**Normalized force (Eq. 2.9-2.10):**
- F_N = g_I * I_max^2 (force generation capability metric)
- F_hat_i = I_hat^T * K_I^T * L_i * K_I * I_hat (dimensionless force field)

#### 2.3.3 Inverse Model Based on Constant Constraints (pp. 24-25)

- Constraints: I_hat_1 + I_hat_2 = c_x, I_hat_3 + I_hat_4 = c_y, I_hat_5 + I_hat_6 = c_z
- Effective input currents: delta_I_hat = [I_hat_1 - I_hat_2, I_hat_3 - I_hat_4, I_hat_5 - I_hat_6]
- At center: F_hat_c = 2*A * delta_I_hat, where A = diag[(2c_x+c_y+c_z), (c_x+2c_y+c_z), (c_x+c_y+2c_z)]
- Result: force increases linearly (not quadratically) with current -- severely limits force generation

#### 2.3.4 Optimal Inverse Model at Center (pp. 25-28)

- Express desired force in spherical coordinates: F_hat_d = |F_hat_d| * r_hat(theta, phi)
- Optimal solution: I_hat_opt = |F_hat_d|^(1/2) * I_opt_unit(theta, phi, p_hat) (Eq. 2.15)
- Minimize ||I_hat||^2 subject to force model constraint
- Orientation-dependent optimal constraints c_x(theta,phi), c_y(theta,phi), c_z(theta,phi) replace constant constraints
- Optimal currents are significantly smaller in absolute value (Fig. 2.9)

#### 2.4 Experimental Verification (pp. 28-31)

- Feedback control with constant-gain PI controller
- Total delay: tau_D = tau_a + tau_m + tau_ZOH
- Bead dynamics (Langevin equation): gamma * P_dot = F_MT + F_T (inertia negligible)
- Brownian motion with optimal allocation shows improved stabilization (Fig. 2.12)
- Optimal current allocation yields significantly smaller currents (Fig. 2.11)

#### 2.5 Calibration and Validation (pp. 31-38)

**Calibrated flux distribution matrix K_I_hat (Eq. 2.19):**

    K_I_hat = [ 0.6022  -0.0124  -0.0285  -0.1507  -0.1668  -0.0229 ]
              [-0.0103   0.9322  -0.1740  -0.0787  -0.0680  -0.1780 ]
              [-0.0294  -0.1655   0.6291  -0.0121  -0.1458  -0.0319 ]
              [-0.1540  -0.0712  -0.0112   0.9040  -0.0746  -0.1501 ]
              [-0.1805  -0.0712  -0.1521  -0.0769   0.9026  -0.0095 ]
              [-0.0235  -0.1726  -0.0331  -0.1506  -0.0123   0.6122 ]

**Key observation:** Diagonal entries for lower poles (P1: 0.60, P3: 0.63, P6: 0.61) are significantly smaller than upper poles (P2: 0.93, P4: 0.90, P5: 0.90). This is because material was removed from lower poles to form flat platform for culture dish.

**Force calibration procedure:**
- Steer bead along 12 linear trajectories in horizontal plane at constant speed in glycerol
- Viscous force = gamma * v_p serves as reference force (gamma calibrated as 8.5e-6 N.s/m)
- Speed: 6.5 um/s, yielding 55 pN viscous force
- Minimize: J(g_I, c) = sum |F_v(j) - F(p(j), I(j); g_I, K_I(c))|^2, N = 14412 samples

**Three calibration options and results:**
1. Nominal K_I: g_I = [5.37, 6.82, 6.93] pN, average error = 12.42 pN
2. Measured K_I_hat: g_I = [9.08, 9.64, 8.39] pN, average error = 10.04 pN
3. Modified K_I_hat (lower poles scaled by c=1.2): g_I = [7.56, 8.55, 7.62] pN, average error = 8.25 pN

Thermal force contributes ~4 pN to the average error. Actual modeling error is much smaller than the 110 pN calibration range.

#### 2.6 Force Generation Capability (pp. 38-41)

- Linear range verified up to 3A (no saturation observed for P2 or P3)
- New design: 4x increase in force gain over previous thin-foil design
- With optimal current allocation, force envelope is dramatically larger than constant constraints
- Force envelopes are spatially symmetric with nominal model; calibrated model shows asymmetry due to upper/lower pole differences

#### 2.7 Conclusion (pp. 41-42)

Summary and future directions: extend optimal inverse to entire workspace, shorten feedback delay, address hysteresis.

### Chapter 3: Optimal Inverse Model and Control (pp. 43-64, lines 2657-3486)

#### 3.2 Hardware: High Speed Control (pp. 44-46)

- FPGA-based system (DE2-115, Terasic) for real-time control
- Two TR4-230 FPGA boards for image processing
- SLD illumination (QPhotonics) for improved image sensitivity
- Visual sensing resolution: ~0.13 nm (x,y with 60x lens), sub-nm (z)
- CMOS camera: 8 um pixel size
- Sampling rate: **1606 Hz** (max for 512x512 image), higher possible with smaller images
- DA converters: DAC8814 EVM (Texas Instruments)
- Reference bead on coverslip for drift compensation

#### 3.3.1 Position-Dependent Inverse (Constant Constraints) (pp. 46-47)

- Taylor expansion around center: F_hat(p_hat, delta_I_hat) = J_deltaI * delta_I_hat + J_phat * p_hat (Eq. 3.1)
- Approximate inverse: delta_I_hat = J_deltaI^(-1) * F_hat_d - J_deltaI^(-1) * J_phat * p_hat (Eq. 3.2)
- Must apply rotation matrix R_ma between measurement and actuation coordinates

#### 3.3.2 Optimal Inverse Model in Entire Workspace (pp. 47-53)

- Lagrange multiplier optimization (Eq. 3.4): minimize ||I_hat||^2 subject to force model
- Nine parameters (6 currents + 3 multipliers), solved using MATLAB optimization toolbox
- Center solution serves as initial guess for positions away from center
- Computed in first octant (45x45x45 um cube), extends to 90x90x90 um full workspace
- **Least-square fitting** of inverse model (Eq. 3.6) outperforms Taylor expansion:
  - I_hat_opt_unit(theta, phi, P_hat)_i = P^T * C_LS(theta, phi)_i * P
  - P = [x, y, z, 1]^T augmented position vector
  - C_LS: 4x4 matrix from least-square fitting (different from Taylor coefficients)
  - Force error with LS fitting: almost always **<5%** across entire workspace
  - Interpolation used between discrete orientations where solutions are computed

#### 3.4 Active Feedback Control (pp. 53-60)

**Stabilization (3.4.1):**
- P controller: gamma * P_dot(t) = K_p * [P_d(t-tau_A) - P(t-tau_D)] + Delta_F(t) + F_T(t)
- Bead stabilized at 75 points (3 layers x 25 points), 10 um spacing
- Optimal inverse: smaller current, smaller Brownian motion std dev, smaller positioning error
- Steady-state error e|_DeltaF = 1/K_p (type 1 system)
- Nyquist stability: K_p < pi/(2*tau_D)

**Trajectory tracking (3.4.2):**
- Circular trajectories in xy, yz, xz planes at 5 um/s
- Optimal tracking error std: (57.82, 43.81, 42.01) nm vs. constant constraints: (123.10, 63.08, 109.83) nm

#### 3.5 High Speed vs. Low Speed Control (pp. 60-63)

- PSD analysis to calibrate K_p, gamma, tau_D
- 200 Hz (PC): tau_D = 12 ms (2.4 sampling intervals), gamma_x = 5.51e-8 N.s/m
- 1606 Hz (FPGA): tau_D = 2.9 ms, gamma_x = 3.71e-8, gamma_z = 6.43e-8 N.s/m
- Minimum Brownian std dev at 1606 Hz: (31.68, 30.65, 27.34) nm vs. 200 Hz: (51.97, 51.55, 36.32) nm
- Structure vibration peak at 71.37 Hz visible in PSD

#### 3.6 Conclusion (pp. 63-64)

Optimal inverse model solves redundancy + nonlinearity + position-dependency. FPGA high-speed control greatly reduces delay and Brownian fluctuation.

### Chapter 4: Hall Sensor Based Force Modeling (pp. 65-110, lines 3487-5207)

#### 4.2.1 Hall-Sensor-Based Force Model (pp. 66-68)

**Key idea:** Replace current-to-flux relationship (which suffers from hysteresis) with direct Hall sensor measurement.

**Equations:**
- Phi_i = d_Hi * v_Hi (Eq. 4.1) -- flux proportional to Hall voltage
- Phi = D_H * V_H (Eq. 4.2) -- D_H = diag(d_H1,...,d_H6) is Flux-Gain Matrix
- Force model: F(p, b, V_H) = f_Phi * V_H^T * D_H^T * L(p,b) * D_H * V_H (Eq. 4.3)
- Normalized: F = f_hat_H * V_H^T * D_hat_H^T * L(p,b) * D_hat_H * V_H (Eq. 4.4)
  - D_hat_H = D_H / d_H1 = diag(1, d_hat_H2,..., d_hat_H6)
  - f_hat_H is lumped force gain

#### 4.2.2 Current-Based Model with Coupling Structure (pp. 68-69)

- K_I structure (Eq. 4.5): diagonal k1-k6, coupling terms: m (neighboring), s (separated-by-one), epsilon (opposite)
- k1-k6 > m > s > epsilon

#### 4.3 Hall Sensor Hardware (pp. 70-73)

- Hall sensors: **Asahi Kasei EQ-730L**
  - Bandwidth: 100 kHz
  - Sensitivity: 130 mV/mT (typical)
  - Package: 4.1 mm x 3.0 mm x 1.15 mm
  - Hall element: 0.3 mm diameter plate, 0.41 mm from surface
- Cannot place at tip (workspace radius 500 um < sensor size)
- **Surface-mounted** on each pole instead
- **Validated:** Vsurface proportional to Vtip for both self-actuation and coupled actuation (1-3 kHz)
- Time delay between surface and tip measurements is negligible (us scale vs. ms system bandwidth)

#### 4.4 Force Model Calibration (pp. 73-82)

**Hysteresis observed:**
- Current vs. Hall voltage plots show remanent magnetization (bias) in most poles
- Reversing current sign produces different hysteresis loops -- very complicated to model

**Calibration procedure:**
- Steer bead in water along circular trajectories (50 um diameter) in xy, yz, xz planes at 10 um/s
- Two experiments: normal currents and reversed-sign currents (explores different hysteresis loops)
- Low-pass filter applied to remove thermal force and measurement noise effects
- LPF time constant tau = 0.05

**Results:**
- Hall-sensor model: J_H = 2434.42, error per point = 0.087 pN
- Current-based model: J_I = 10279.1, error per point = 0.179 pN
- Hall-sensor model error follows Gaussian distribution (captures physics correctly)

#### 4.5 Applications (pp. 82-90)

**Force prediction (4.5.1):**
- Calibrated Hall-sensor model accurately predicts forces along different trajectories (25 um circles, straight lines)
- Current-based model has obvious errors

**Hall-sensor inner loop control (4.5.2):**
- Secondary control loop directly controls Hall sensor voltage V_m to match desired V_d
- Rise time: ~0.32 ms
- Removes remanent magnetization problem
- AD converter at 200 kHz, Hall feedback at 100 kHz, DA at 640 kHz
- Stabilization error much smaller than current-based control

#### 4.6 Accurate Model with Langevin Function (pp. 90-109)

**Bead magnetization (Eq. 4.12):**
- m(ms, a, B) = ms * [coth(a*|B|) - 1/(a*|B|)] * B_hat
- ms: saturation limit of bead
- a: shape parameter of Langevin function
- Linear approximation (Eq. 4.13): m approx ms * (a/3) * B when |B| -> 0
- Nominal values: ms = 1.50e-12 Am^2, a = 227.8125

**Accurate force model (Eq. 4.17):**
- F_i = f_hat * f_hat_L(a*|B|) * V_H^T * D_hat_H^T * L_i(p,b) * D_hat_H * V_H
- f_hat_L = Langevin Force Gain
- f_hat = ms * k_m^2 * d_H1^2 * a / (4 * rho^5 * mu_0^2)

**Calibration results (Eq. 4.18):**
- Glycerol experiments (larger forces), bead steered at 2 um/s (xy) and 1.5 um/s (yz, xz)
- With Langevin: J_H = 4.3063e5, error per point = 1.58 pN
- Without Langevin: J_H = 1.3859e6, error per point = 2.83 pN
- Calibrated parameters: f_hat = 24.939 pN, a_hat = 3.232
- External field reaches ~260 Gauss in experiment; linear range only up to ~50 Gauss
- Recalculated: ms = 1.40e-12, a = 244.234, b_H = 1.323e-2, d_Hi = 5.99e-8

**Optimal inverse model with Langevin (Eq. 4.19-4.20):**
- Same Lagrange multiplier approach for unit force direction
- f_hat_L(a|B|) * |V|^2 is monotonically increasing -- can be inverted to find |V|
- At small |V|: approximately quadratic; at large |V|: approximately linear (saturated bead)

#### 4.7 Conclusion (pp. 109-110)

Hall sensors solve complicated hysteresis. Sub-pN accuracy demonstrated. Inner loop control removes remanent magnetization. Langevin function needed for large fields (>50 Gauss).

### Chapter 5: Dynamic Force Sensing and Parameter Estimation (pp. 111-130, lines 5208-5957)

#### 5.1 Introduction (pp. 111-112)

Dynamic force sensing transforms the actuator from force applier to active scanning probe. Requires accurate force model + estimation algorithm. Joint state-parameter estimator simultaneously estimates bead-sample interaction force and drag coefficient.

#### 5.2 Estimator Algorithm (pp. 113-119)

**Bead dynamics (Eq. 5.1):** gamma * x_dot(t) = F_MT(t) + F_E(t) + F_T(t)

**State-space model (Eq. 5.7):**
- State: X[k] = [x_E[k], x_E[k-1], (1/gamma)[k]]^T
- 2nd order AR model for disturbance x_E (Eq. 5.5)
- 1st order AR model for 1/gamma (Eq. 5.6)
- Observation: O_m[k] = x_m[k] - x_m[k-1] (position increment)

**Kalman filter (Eqs. 5.9-5.10):**
- Time update: predict state and covariance
- Measurement update: compute innovation, Kalman gain, correct state
- Persistent excitation naturally satisfied (thermal force constantly perturbs bead)

**Two methods for drag estimation:**
1. Based on magnetic force model (Eq. 5.8): 1/gamma as state variable
2. Based on thermal variance (Eq. 5.11-5.12): gamma = 2*k_B*T*tau_s / sigma_T^2

#### 5.3 Simulation Results (pp. 120-125)

- **Water:** Both methods converge to nominal drag coefficient
- **Glycerol:** Magnetic force model method converges; thermal variance method fails (measurement noise comparable to thermal motion)
- **Simultaneous estimation:** Drag coefficient and external force can both converge even when changing simultaneously
- Force estimation bandwidth: ~4.42 Hz; drag estimation bandwidth: ~1 Hz

#### 5.4 Experimental Results (pp. 125-129)

- Hall-sensor model: gamma[k] closely matches PSD-calibrated nominal value; F_E < 0.2 pN (sub-pN dynamic force sensing)
- Current-based model: large discrepancy in drag coefficient, especially in y and z directions; inconsistent across experiments due to hysteresis history

#### 5.5 Conclusion (pp. 129-130)

Joint state-parameter estimator validated. Hall-sensor model greatly outperforms current-based model for force sensing. Sub-pN force sensing demonstrated.

### Chapter 6: Conclusion and Future Works (pp. 131-135, lines 5958-6167)

**Summary of achievements:**
1. Hardware design with 1018 steel, >2T saturation, 40 um tip radius
2. Lumped-parameter force model (quadratic in current/flux)
3. Optimal inverse model (minimal 2-norm currents, <5% error in workspace)
4. FPGA control at 1606 Hz, Brownian std dev ~30 nm
5. Hall-sensor model: sub-pN accuracy, bypasses hysteresis
6. Langevin function for nonlinear bead magnetization
7. Kalman filter joint state-parameter estimator

**Future work:**
1. Implement estimator in FPGA for real-time force monitoring
2. Biological experiments (intracellular scanning, cytoplasm property sensing)
3. Optimal inverse model based on calibrated force model (for high-bandwidth tracking)

### Bibliography (pp. 136-141, lines 6168-6432)

83 references. Key references for our work:
- [1] Zhang, Long and Menq 2013 -- 3D visual servo control
- [2] Zhang and Menq 2011 -- Design and modeling of 3D actuator (previous thin-foil design)
- [52] Zhang, Huang and Menq 2010 -- Quadrupole magnetic tweezers (force model origin)
- [53] Zhang, Huang and Menq 2010 -- Design and force modeling of quadrupole
- [63] Chen et al. 2015 -- Competing MT design (FEM look-up table, no analytical model)
- [67] Chikazumi 1964 -- Physics of magnetism (gradient force formula)
- [77] Fonnum et al. 2005 -- Dynabead characterization (ms = 1.50e-12)

## Equations and Parameters We Use

### Device Parameters

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| Pole material | 1018 steel (0.18% C) | Low-carbon steel, high saturation | p.14 |
| Saturation limit | >2T | Material property | p.14 |
| Pole diameter | ~6 mm | Pole cross-section | p.14 |
| Upper pole length | ~45 mm | Physical dimension | p.14 |
| Lower pole length | ~42 mm | Milled flat for dish | p.14 |
| Pole tip radius | 40 um | Included in FEM | p.14 |
| Workspace radius (physical) | 500 um | Tip-to-center distance | p.14 |
| Workspace radius (charge model) | 900 um | Best-fit parameter from FEM | p.20 |
| Air reluctance | 6.3e8 A/Wb | Best-fit parameter from FEM | p.20 |
| Coil turns | 70 | Per coil | p.14 |
| Max current | 3 A | Linear range verified | p.39 |
| Bead diameter | 4.5 um | Dynabead M-450 Epoxy | p.14 |
| Bead saturation | 1.50e-12 Am^2 (nominal) | Magnetic moment | p.93 |
| Bead saturation (recalculated) | 1.40e-12 Am^2 | From calibration | p.105 |
| Langevin shape parameter a | 227.8 (nominal), 244.2 (recal.) | Magnetization curve | p.93, 105 |
| Linear magnetization range | up to ~50 Gauss | Beyond this, Langevin needed | p.91, 105 |
| k_m = mu_0/(4*pi) | 1.0e-7 N/A^2 | Permeability constant | p.18 |
| Cover glass thickness | ~100 um | Between upper/lower planes | p.13 |

### Calibrated Parameters

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| K_I (calibrated, Eq. 2.19) | See matrix in Ch.2.5 | Flux distribution (asymmetric) | p.33 |
| Lower pole scaling factor c | 1.2 | To account for material removal | p.38 |
| Force gain g_I (option 3) | [7.56, 8.55, 7.62] pN | With modified K_I | p.38 |
| Drag coeff (glycerol, 4.5um bead) | 8.5e-6 N.s/m | Calibration fluid | p.34 |
| Drag coeff (water, 200Hz) | 5.51e-8 N.s/m (xy), 1.31e-7 (z) | PSD calibration | p.61 |
| Drag coeff (water, 1606Hz) | 3.71e-8 (xy), 6.43e-8 (z) N.s/m | PSD calibration | p.62 |
| Hall sensor coefficient d_Hi | 5.99e-8 | From Langevin calibration | p.105 |
| Hall force gain f_hat | 24.939 pN | With Langevin | p.105 |
| Langevin a_hat | 3.232 | Lumped parameter | p.105 |
| b_H (flux density coefficient) | 1.323e-2 | Hall-sensor-based | p.105 |
| Control delay (200Hz PC) | 12 ms | PSD calibrated | p.61 |
| Control delay (1606Hz FPGA) | 2.9 ms | PSD calibrated | p.62 |

### Key Equations

| Equation | Expression | Context | Eq. # |
|----------|-----------|---------|-------|
| Magnetic charge | q_i = Phi_i / mu_0 | Point charge from pole tip | 2.1 |
| Field from single charge | B_i = k_m * q_i / r_i^2 * u_i | Coulomb-like magnetic field | 2.2 |
| Total field (matrix) | B = (k_m/rho^2) * R_hat * Q | Superposition of 6 charges | 2.3 |
| Flux-current relation | Q = (N_c/(mu_0*R_a)) * K_I * I | Via Hopkinson's law | 2.4 |
| General force model | F_i = f_Phi * (1/mu_0^2) * Phi^T * L_i * Phi | Quadratic in flux | 2.6 |
| Current-based force | F_i = g_I * I^T * K_I^T * L_i * K_I * I | Quadratic in current | 2.7 |
| Nominal K_I | diag=5/6, off-diag=-1/6 | Theoretical (symmetric) | 2.8 |
| Normalized force | F_hat_i = I_hat^T * K_I^T * L_i * K_I * I_hat | Dimensionless | 2.10 |
| Center force (const constr) | F_hat_c = 2 * A * delta_I_hat | Linear in effective current | 2.11 |
| Optimal inverse (center) | I_hat_opt = abs(F_d)^(1/2) * I_unit_opt(theta,phi) | Scalable | 2.15 |
| Bead dynamics | gamma * P_dot = F_MT + F_T | Langevin equation (no inertia) | 2.18 |
| Hall-sensor force model | F = f_hat_H * V_H^T * D_hat_H^T * L * D_hat_H * V_H | Bypasses hysteresis | 4.4 |
| Langevin magnetization | m = ms * [coth(a*abs(B)) - 1/(a*abs(B))] * B_hat | Nonlinear bead magnetization | 4.12 |
| Accurate Hall force | F_i = f_hat * f_hat_L * V_H^T * D_hat_H^T * L_i * D_hat_H * V_H | With saturation | 4.17 |
| Workspace inverse (LS) | I_unit(theta,phi,P)_i = P^T * C_LS(theta,phi)_i * P | Position-dependent optimal | 3.6 |
| Kalman state-space | X[k] = Phi * X[k-1] + W[k] | Joint estimator dynamics | 5.7 |
| Kalman observation | O_m[k] = H[k] * X[k] + x_T[k] | Observation model | 5.8 |

## Pole Naming Convention

**Paper convention (used throughout dissertation):**
- Lower layer: P1, P3, P6 (physically below the culture dish)
- Upper layer: P2, P4, P5 (tips sink into medium above dish)
- Opposite pairs in actuation coordinate: P2<->P1 (+x), P4<->P3 (+y), P6<->P5 (+z)
- Each pole has: actuation coil (flux generation) + measurement coil (flux measurement)

**APDL-to-Paper mapping (from our MEMORY.md):**
- APDL coil 1 (0 deg) = Paper P1
- APDL coil 2 (120 deg) = Paper P3
- APDL coil 3 (240 deg) = Paper P6
- APDL coil 4 (60 deg) = Paper P5
- APDL coil 5 (180 deg) = Paper P2
- APDL coil 6 (300 deg) = Paper P4
- Lower poles (APDL 1,2,3) = Paper P1, P3, P6
- Upper poles (APDL 4,5,6) = Paper P5, P2, P4

## Figures Worth Revisiting

| Figure | Page | Description | Why revisit |
|--------|------|-------------|-------------|
| Fig. 2.1 | p.12 | CAD model of motion stage and lower poles; yoke ring assembly | Geometry reference for ANSYS model |
| Fig. 2.2 | p.12 | (a) Fabricated prototype on microscope; (b) CAD model with FEM mesh | **Critical** -- FEM mesh reference for our simulation |
| Fig. 2.3 | p.16 | Vector plot of B field: (a) top view, (b) workspace center, (c) near tip | Validate our ANSYS results against these |
| Fig. 2.4 | p.17 | Contour plot of abs(B) in horizontal and vertical planes | Compare with our contour plots |
| Fig. 2.5 | p.17 | (a-b) Coordinate systems; (c) FEM charge model validation; (d) bead + 6 charges | **Critical** -- coordinate system and charge model |
| Fig. 2.6 | p.21 | Validation of hexapole field model: vector comparison and error norms | Benchmark: <1% error validates charge model |
| Fig. 2.8 | p.27 | Optimal vs. constant constraints | Understand constraint optimization |
| Fig. 2.9 | p.28 | Optimal vs. constant current allocation | Quantitative comparison |
| Fig. 2.13 | p.32 | Actuation current and measurement coil voltages | Flux distribution measurement |
| Fig. 2.20 | p.39 | Linear range test for P2 and P3 up to 3A | Confirms no saturation at 3A |
| Fig. 2.21-22 | p.40-41 | Force envelope comparison (nominal and calibrated) | Force generation capability |
| Fig. 3.4 | p.50 | Locations where optimal inverse model is computed (first octant) | Workspace grid for inverse model |
| Fig. 4.2 | p.70 | Hall sensors integrated with actuator | Physical sensor placement |
| Fig. 4.5 | p.74 | Current vs. Hall voltage (hysteresis visible) | Hysteresis evidence |
| Fig. 4.7 | p.76 | Six-pole input-output with reversed currents | Complex hysteresis loops |
| Fig. 4.29 | p.91 | Bead magnetization diagram | Superparamagnetic model |
| Fig. 4.30 | p.92 | Langevin function plots for different a values | Magnetization curve shape |
| Fig. 4.45 | p.106 | abs(B) vs. abs(m) showing nonlinear saturation | Linear range ~50 Gauss |

## Cross-References

- **Zhang and Menq, 2011** -- Reference [2]. Previous 3D actuator design with thin permalloy film. Contains original magnetic circuit analysis, K_I derivation, and quadrupole-to-hexapole extension.
- **Zhang, Long and Menq, 2013** -- Reference [1]. Visual servo control of magnetically propelled bead. Original constant-constraint inverse model.
- **Long, Matsuura and Menq (accepted)** -- The "Actively Controlled" paper -- likely corresponds to the 12-page paper in our pdfs/ folder. Overlaps heavily with Ch. 2.
- **Zhipeng Zhang dissertation** -- Earlier dissertation from same lab. Contains background on quadrupole design and earlier hexapole work.
- **Chen et al., 2015** -- Reference [63]. Competing magnetic tweezers design, no analytical force model (uses FEM look-up table instead).
- **Fonnum et al., 2005** -- Reference [77]. Characterization of Dynabeads: magnetization measurements showing ms = 1.50e-12 Am^2.
- **Chikazumi, 1964** -- Reference [67]. Source of gradient force formula for superparamagnetic particles.

## Page Ranges for Claude

| Pages   | Main Topic |
|---------|------------|
| 1-10    | Title, abstract, table of contents |
| 10-15   | List of Figures (all figure captions for quick reference) |
| 16-20   | Ch.1: Introduction, background, motivation, objectives |
| 21-25   | Ch.1 continued: dissertation overview; Ch.2 begins: introduction, design |
| 25-30   | Ch.2: Design details, FEM analysis, hexapole field model, charge model |
| 30-35   | Ch.2: Field model validation, general force model, current-based force model |
| 35-40   | Ch.2: Inverse model (constant constraints), optimal inverse at center |
| 40-45   | Ch.2: Experimental verification, calibration procedure |
| 45-50   | Ch.2: Calibrated K_I matrix, force calibration results, force capability |
| 50-55   | Ch.2: Force generation; Ch.3 begins: intro, FPGA hardware |
| 55-60   | Ch.3: Position-dependent inverse, optimal inverse in workspace, LS fitting |
| 60-65   | Ch.3: Stabilization, Brownian control, trajectory tracking results |
| 65-70   | Ch.3: High-speed vs. low-speed control, PSD analysis; Ch.3 conclusion |
| 70-75   | Ch.4 begins: Hall-sensor-based force model derivation, current-based with coupling |
| 75-80   | Ch.4: Hall sensor hardware, validation of surface-mount approach |
| 80-85   | Ch.4: Bead trapping with Hall sensors, hysteresis observed, force calibration |
| 85-90   | Ch.4: Calibration results, Hall vs. current model comparison |
| 90-95   | Ch.4: Force prediction, Hall-sensor inner loop control |
| 95-100  | Ch.4: Langevin function for bead magnetization, accurate force model derivation |
| 100-105 | Ch.4: Accurate model calibration in glycerol, with/without Langevin comparison |
| 105-110 | Ch.4: Force prediction with Langevin, parameter calibration, magnetization study |
| 110-115 | Ch.4: Accurate inverse model; Ch.4 conclusion |
| 115-120 | Ch.5: Dynamic force sensing intro, joint state-parameter estimator, Kalman filter |
| 120-125 | Ch.5: Drag coefficient estimation (two methods), thermal variance approach |
| 125-130 | Ch.5: Simulation results (water, glycerol), simultaneous estimation |
| 130-135 | Ch.5: Experimental results, Hall vs. current model in estimator; Ch.5 conclusion |
| 135-141 | Ch.6: Conclusion and future works; Bibliography begins |
| 141-167 | Bibliography (references [1]-[83]) |
