# Magnetic Tweezers: Actuation, Measurement, and Control at Nanometer Scale

## Bibliographic Info

| Field       | Value |
|-------------|-------|
| Authors     | Zhipeng Zhang |
| Year        | 2009 |
| Type        | PhD Dissertation |
| Source      | The Ohio State University, Department of Mechanical Engineering |
| Advisor     | Professor Chia-Hsiang Menq |
| Committee   | K. Srinivasan, M. Dapino, J. Wang |
| PDF file    | pdfs/Zhipeng Zhang.pdf |
| Total pages | 165 (xxii + 143 numbered pages) |

## Relevance to This Project

This dissertation is the foundational work for the magnetic tweezers project. It presents the **magnetic monopole approximation** and **superposition-based force model** that underpin our ANSYS APDL simulation. Although this dissertation describes a **quadrupole** (4-pole, 2D) system, the theoretical framework (monopole model, magnetic circuit analysis, inverse force model) was later extended to the **hexapole** (6-pole, 3D) system in the Zhang and Menq 2011 journal paper. The FEM validation here uses **Ansoft Maxwell** (not ANSYS), but the modeling approach is the same.

**Tags:** geometry, materials, force-modeling, monopole-approximation, magnetic-circuit, fem-validation, calibration, feedback-control, superposition, quadrupole

## Key Contributions

- Developed magnetic monopole approximation for describing magnetic field of sharp-tipped poles
- Derived quadratic force model: **F = k_Q * Q^T * M * Q** (force is quadratic in magnetic charges, position-dependent via matrix M)
- Established magnetic circuit analysis relating coil currents I to magnetic charges Q via flux distribution matrix K_I
- Validated monopole model against Ansoft Maxwell FEM simulation; determined effective magnetic charge location at l_A = 490 um (vs. physical pole tip distance 405 um from center)
- Derived inverse force model for feedback linearization (both exact Newton-Raphson and simplified 1st-order Taylor approximation)
- Achieved stable trapping and 43 nm positioning resolution via minimum variance control
- Demonstrated biological applications on living cells (MCF-7, MCF-10A, MDA-MB 231)

## Detailed Notes by Section

### Front Matter (pp. i-xxii)

- **Abstract (pp. ii-iv):** Quadrupole magnetic tweezers for 2D force generation. Magnetic monopole approximation for field/force modeling. 3D particle tracking via off-focus images (subnanometer resolution, 400 Hz). Feedback control with minimum variance controller. Cell experiments.
- **Vita (p. vii):** Born 1982 in Shandong, China. B.S. Tsinghua University 2003, M.S. Ohio State 2005.
- **Publications:** 4 journal papers listed (particle tracking, laser interferometry, magnetic levitation). The 2011 hexapole paper was published after this dissertation.
- **List of Symbols (pp. xvii-xxii):** Comprehensive symbol definitions. Key symbols:
  - k_m = mu_0/(4*pi) = 1.0e-7 N/A^2 (magnetic field coefficient)
  - l_A = distance from working area center to magnetic charge location
  - K_I = magnetic flux distribution matrix
  - k_Q = coefficient related to bead properties and tweezers geometry

### Chapter 1: Introduction (pp. 1-10)

Overview of single-molecule manipulation techniques: AFM cantilevers, optical tweezers, dielectrophoretic traps, magnetic tweezers. Magnetic tweezers selected for biocompatibility and specificity.

**Four specific aims:**
1. Design, implementation, and force modeling of magnetic tweezers
2. Development of 3D bead tracking system (off-focus imaging)
3. Feedback control of magnetic tweezers
4. Manipulation of biological samples (living cells)

**Key context for our project:** This dissertation covers the quadrupole (4-pole) system. The hexapole (6-pole) system in the 2011 journal paper was developed later as "recommended future work" (see Section 6.2).

### Chapter 2: Design and Force Modeling of Quadrupole Magnetic Tweezers (pp. 11-33)

**THIS IS THE MOST IMPORTANT CHAPTER for our project -- it establishes the theoretical foundation.**

#### 2.1 Introduction (pp. 11-12)
Review of multipolar magnetic tweezers: single-pole [26-29], two-pole [31], three-pole [37], eight-pole/four-coil [35], six-pole [38], hexapole [40]. Force model is needed for meaningful experiments; challenge is that force is nonlinear in multiple variables.

#### 2.2 Design and Implementation (pp. 13-16)

**Physical specifications of the quadrupole system:**

| Parameter | Value |
|-----------|-------|
| Number of poles | 4 (quadrupole, 2D) |
| Pole material | MuShield nickel-iron-molybdenum alloy, 100 um thick foil |
| Pole saturation field | ~0.9 T |
| Pole tip shape | Round, radius ~30 um |
| Distance from center to pole tip vertex | 405 um |
| Fabrication method | Wire EDM, tolerance +/-5 um |
| Substrate | No. 1 coverslip (thickness 0.13-0.16 mm) |
| Yoke material | Cold rolled steel, ring shape with 4 protrusions |
| Coil wire | AWG #25 (diameter 0.455 mm) |
| Coil turns | 21 turns per coil |
| Coil resistance | ~0.2 ohm |
| Maximum continuous current | 5 A (no significant heating) |
| Setup thickness | 4 mm total (fits between objective and condenser) |
| Microscope | Nikon TE2000-U inverted microscope |

**Note:** These dimensions differ from the hexapole system in the 2011 journal paper, which has a different geometry (6 poles arranged in 3D, two layers of 3 poles each).

#### 2.3 Magnetic Force Modeling (pp. 17-27)

##### 2.3.1 Magnetic Field Analysis (pp. 17-21)

**Magnetic monopole approximation:**

Starting from Gauss law: closed-integral B . dA = 0

For a spherical surface centered at pole tip with radius r:
- Approximation assumes isotropic field in air
- **B_a = Phi / (4*pi*r^2)** -- eqn. (2.2)

Magnetic charge defined as:
- **q = Phi / mu_0** -- eqn. (2.3)

Field from single pole:
- **B_a = k_m * q / r^2 * u_hat** -- eqn. (2.4)
- where k_m = mu_0/(4*pi) = 1.0e-7 N/A^2

Total field from all poles (superposition):
- **B = sum_j k_m * (q_j / r_j^2) * u_hat_j** -- eqn. (2.5)

**FEM validation:** Ansoft Maxwell used. CAD model built with material properties assigned. Magnetic charge location fitted to l_A = 490 um (vs. physical tip distance 405 um). The charge location is farther from center than the physical tip because the field is not perfectly isotropic -- shifting the charge compensates for field distortion near pole boundaries.

##### 2.3.2 Magnetic Force Analysis (pp. 21-23)

For superparamagnetic bead (mu_R >> 1, no hysteresis):

Effective magnetization:
- **m_b = (3V/mu_0) * ((mu - mu_0)/(mu + 2*mu_0)) * B** -- eqn. (2.6)

Magnetic force:
- **F = (1/2)*grad(m_b . B) = k_Q * F_Q** -- eqn. (2.7)
- **k_Q = (3*V*k_m^2) / (2*mu_0*l_A^5) * ((mu - mu_0)/(mu + 2*mu_0))** -- coefficient
- **F_Q = (l_A^5 / k_m^2) * grad(B . B)** -- normalized force

Quadratic form:
- **F_Q = Q^T * M * Q** -- eqn. (2.8)
- M is a 4x4 matrix (for quadrupole), each element M(j,k) = grad[(u_j . u_k)/(r_hat_j^2 * r_hat_k^2)]
- Q = [q_1, q_2, q_3, q_4]^T, r_hat = r/l_A

Sum of charges always zero: q_1 + q_2 + q_3 + q_4 = 0 (from Gauss law)

Simplified M(j,k) formula -- eqn. (2.10) -- avoids expensive gradient computation:

    M(j,k) = 1/(r_hat_j^3 * r_hat_k^3) * [(1 - 3*(r_hat_j . r_hat_k)/r_hat_k^2) * r_hat_k
                                           + (1 - 3*(r_hat_j . r_hat_k)/r_hat_j^2) * r_hat_j]

At working area center (0,0):
- **F_Qx(0,0) = 6*(q_1^2 - q_3^2)** -- eqn. (2.11)
- **F_Qy(0,0) = 6*(q_2^2 - q_4^2)**

##### 2.3.3 Magnetic Circuit Analysis (pp. 23-27)

Magnetic circuit with reluctances:

| Component | Length (mm) | mu_R | Cross-section (mm^2) | Reluctance (AT/Wb) |
|-----------|-------------|------|----------------------|-------------------|
| Yoke (quarter) | 25 | 5000 | 25 | R_y = 1.6e5 |
| Pole | 17 | 36000 | 0.5 | R_p = 7.5e5 |
| Air (tip to center) | 0.405 | 1 | 0.18 | R_a = 1.8e9 |

Since R_a >> R_p, R_y, the flux distribution simplifies to:

**Phi = (N_c / R_a) * K_I * I** -- eqn. (2.13)

where K_I is the 4x4 distribution matrix:

    K_I = [ 3/4  -1/4  -1/4  -1/4]
          [-1/4   3/4  -1/4  -1/4]
          [-1/4  -1/4   3/4  -1/4]
          [-1/4  -1/4  -1/4   3/4]

**Complete force model:**
- **F = k_I * I^T * N * I** -- eqn. (2.15)
- where k_I = k_Q * (N_c/(mu_0*R_a))^2, N = K_I^T * M * K_I

Normalized by I_max:
- **F = k_I_hat * I_hat^T * N * I_hat** -- eqn. (2.16)
- **k_I_hat = (3*V*k_m^2)/(2*mu_0*l_A^5) * ((mu-mu_0)/(mu+2*mu_0)) * (N_c/(mu_0*R_a))^2 * I_max^2** -- eqn. (2.18)

Current constraint: I_1 + I_2 + I_3 + I_4 = 0 (since sum of charges = 0)

At center with constraint:
- **F_hat_x(0,0) = 6*(I_hat_1^2 - I_hat_3^2)** -- eqn. (2.20)
- **F_hat_y(0,0) = 6*(I_hat_2^2 - I_hat_4^2)**

#### 2.4 Actuation Bandwidth Analysis (pp. 28-29)

- Drive electronics: Linear power amplifiers (BTA-28V-6A, Precision Micro Dynamics), compensate coil inductance up to 10 kHz
- At several kHz, mu_R drops to ~hundreds, but R_y, R_p still << R_a
- Skin depth: d_s = sqrt(rho_m / (pi*f*mu))
- For 100 um pole foil, skin effect limit: f = rho_m / (pi*d_s^2*mu) = **1469 Hz**
- **Practical bandwidth limit: ~1.5 kHz** for maximum force

#### 2.5 Magnetic Force Directionality Analysis (pp. 29-32)

- Force envelope computed numerically for all current combinations at each position
- At center [0,0]: envelope is a square, Gamma = 0.7 (ratio of min to max force magnitude on envelope)
- Near poles: envelope stretches toward closest pole, Gamma decreases
- **Gamma > 0.1 region** recommended for best manipulation performance
- Gamma decreases almost logarithmically approaching the poles

#### 2.6 Conclusions and Remarks (pp. 32-33)

- Force model does NOT include saturation or hysteresis effects
- Low-hysteresis materials preferred for yoke and poles
- Current must be limited to prevent saturation
- Approach extends to other multipolar designs with sharp tips and closed magnetic circuits

### Chapter 3: Three-Dimensional Particle Tracking (pp. 34-85)

**Less directly relevant to FEM simulation; summarized briefly.**

#### 3.2 Experimental Setup (pp. 35-36)
- Microscope: Nikon TE2000-U with 60x water immersion objective (NA 1.20)
- Bright-field camera: Mikrotron MC1310 CMOS, 500 fps at 1280x1024, 12x12 um^2 pixel
- Fluorescent camera: CoolSNAPEZ CCD (Photometrics), 10-20 Hz, 6.45x6.45 um^2 pixel
- Piezo stage: Physik Instrumente P-517.3CL, 100x100x20 um^3 range, subnanometer precision

#### 3.3-3.4 Algorithm Overview (pp. 37-45)
- Lateral position: centroid method -- (x_c, y_c) = (sum(I_i*x_i)/sum(I_i), sum(I_i*y_i)/sum(I_i))
- Axial position: radius vector (RV) method -- converts 2D off-focus image to 1D radius vector via angular averaging, then matches against pre-calibrated object-specific model

#### 3.5-3.6 Error Analysis and Bright-Field Results (pp. 46-57)
- Subnanometer resolution in all three axes at 400 Hz
- Nano-stepping down to 10 nm demonstrated
- K curve and S curve characterize estimation sensitivity and variance

#### 3.7-3.10 Extension to Fluorescence and Resolution Enhancement (pp. 58-76)
- Normalized matching: invariant to intensity changes (photobleaching)
- Variance equalization: weights pixels by inverse noise variance
- Best Linear Unbiased Estimation (BLUE) of axial position
- Correlation-weighted optimization
- Normalized Best Linear Unbiased Estimator (NBLUE) combines normalization and VE

#### 3.11-3.12 Fluorescent Results and Conclusions (pp. 76-85)
- 0.75 um fluorescent beads tracked with subnanometer resolution
- Robust to photobleaching
- Algorithm applicable to any spherical particle

### Chapter 4: Feedback Motion Control of a Magnetic Microbead (pp. 86-115)

#### 4.1 Introduction (pp. 86-88)
- System: 60x dry objective (CFI Super Plan Fluor ELWD 60XC)
- Analog output: NI PCI 6733 (16-bit) driving 4 linear power amplifiers (BTA-28V-6A, gain 0.3 A/V)
- Bead: 2.8 um Dynal magnetic bead in water
- Capillary tube: 30 um x 300 um rectangular inner cross-section
- Sampling rate: 200 Hz (real-time video display reduces from 1000 Hz max)

#### 4.2 Control Block Diagram (pp. 89-91)

**Bead dynamics (Langevin equation):**
- M*x_ddot + gamma*x_dot = F_T(t) + F_x(t) -- eqn. (4.1)
- Inertia negligible below ~200 kHz
- Transfer function: G(s) = 1/(gamma*s), discrete: G(z) = t_s*z^-1 / (gamma*(1-z^-1))
- Thermal force PSD: S_FT(f) = 4*gamma*k_B*T (white noise)

**Measurement system:**
- Camera integration acts as low-pass filter with 0.5-step delay
- Image transfer + processing: 1.5-step delay
- Total measurement delay: 2 steps at 200 Hz --> H(z) = z^-2

#### 4.3 Inverse Force Model (pp. 92-96)

**Key insight:** 4 unknowns (I_hat_1..I_hat_4) but only 2 equations (F_hat_x, F_hat_y). Need 2 constraints:
1. I_hat_1 + I_hat_2 + I_hat_3 + I_hat_4 = 0 (from charge conservation)
2. Linear constraint: solution is 1st-order polynomial in F_hat_cx, F_hat_cy

**Linear solution at center (eqn. 4.7):**

    I_hat_1 = (1/2)*(F_hat_cx/sqrt(6) + 1)
    I_hat_2 = (1/2)*(-F_hat_cy/sqrt(6) - 1)
    I_hat_3 = (1/2)*(-F_hat_cx/sqrt(6) + 1)
    I_hat_4 = (1/2)*(F_hat_cy/sqrt(6) - 1)

In matrix form: I_hat = D * F_hat_c + E -- eqn. (4.8)

**Simplified inverse force model (1st-order Taylor, eqn. 4.11-4.13):**
- F_hat_x = F_hat_cx + 18*x
- F_hat_y = F_hat_cy + 18*y
- Accuracy: within +/-3.3% for |x|,|y| < 0.15 (normalized by l_A)

**Note for our hexapole project:** The same inverse force model approach was extended to 6 poles in the 2011 paper. The key difference is 6 unknowns and 3 force equations (3D), needing 3 constraints.

#### 4.4 Controllability Analysis (pp. 97-98)
- With constraints applied, Gamma > 0.1 region shrinks to radius ~0.2 (normalized)
- No stable feedback possible near poles (uncontrollable regions)

#### 4.5 System Calibration (pp. 99-106)

**4.5.1 Proportional control calibration (pp. 99-101):**
- PSD fitting: S_x(f) = 4*k_B*T*gamma / |i*gamma*2*pi*f + K_p*exp(-i*2*pi*f*t_d)|^2
- Calibrated parameters:
  - Time delay: t_d = 2.5*t_s = 12.5 ms
  - Damping coefficient: gamma = 5.28e-8 N*s/m (Faxen law: beta = 2.33, h = 1.5 um)
  - Force gain: k_I_hat = 0.34 pN (for 2.8 um bead at I_max = 0.9 A)
  - Optimal proportional gain: K_p = 3.3e-6 N/m --> sigma_x = 54.5 nm

**4.5.2 Saturation calibration (pp. 102-103):**
- sqrt(k_I_hat) increases linearly with I_max up to **I_max = 0.9 A** (21-turn coils)
- Above 0.9 A: poles saturate, force gain plateaus
- **Critical for our project:** Saturation current depends on pole geometry and material

**4.5.3 Inverse model validation (pp. 104-106):**
- Grid scan: 12x12 positions, 12 um steps
- Measured F_hat_cx = -18.3*(x - 0.028), F_hat_cy = -17.4*(y + 0.030)
- Agrees well with simplified model F_hat_cx = F_hat_x - 18*x (expected coefficient 18)
- Small offset and gain mismatch due to assembly errors

#### 4.6 Minimum Variance Control (pp. 107-112)

- Controller: C(z) = gamma / (t_s*(1 + z^-1 + z^-2))
- Closed-loop: W(z) = z^-3 (three-step delay)
- Minimum variance: var(x) = 6*k_B*T*t_s/gamma --> sigma_x = 48 nm (theoretical)
- Experimental: sigma_x = **43 nm** at K_mv = 4.0e-6 N/m
- Better than theory due to camera low-pass filtering effect (verified by Simulink simulation)

#### 4.7 More Control Results (pp. 112-114)
- Nanostepping: 20 nm steps visible after 400-point moving average
- Large motion: bead follows "OSU" trajectory at 10 um/s

#### 4.8 Conclusions (pp. 114-115)
- Minimum variance control reduces Brownian motion by >20% vs. best proportional control
- To further reduce: increase sampling rate (20 kHz would give sigma = 4.3 nm, but beyond camera capability)

### Chapter 5: Application to Living Cells (pp. 116-131)

#### 5.2.1 Modified Setup (pp. 117-120)

**Two-layer design for cell accommodation:**

| Parameter | Original Setup | Modified Setup |
|-----------|---------------|----------------|
| Pole layers | 1 | 2 (top and bottom) |
| Pole thickness | 100 um | 150 um |
| Air gap | N/A | 600 um (for cell chamber) |
| l_A | 490 um | 700 um |
| Coil turns | 21 | 40 |
| Saturation current | 0.9 A | 1.2 A |
| Max force (4.5 um bead) | 0.34 pN (2.8 um bead) | +/-43 pN |
| Bead | 2.8 um Dynal | 4.5 um Dynabeads M450 Epoxy |

- Cell chamber: two No. 1 coverslips + seal ring (~120 um), total ~420 um thick
- Two coinciding poles (top + bottom) act as one pole when lateral distance >> axial gap

#### 5.2.2 Sample Preparation (pp. 121-123)
- Bead coating: fibronectin via epoxy surface chemistry (protocol optimized from 8 variants)
- BSA blocking reduces nonspecific binding
- Cells: HEK 293, MCF-10A, MCF-7, MDA-MB 231
- Cell preparation: seeded on No. 1 coverslips, incubated 37 deg C, 5% CO2, 24 hours

#### 5.3 Experiments (pp. 124-130)

**5.3.1 Creep and relaxation (pp. 124-126):**
- 43 pN step force on MCF-7 cell
- Kelvin-Voigt model fit: k_cell = 1.0e-3 N/m, gamma_cell = 0.85e-3 N*s/m

**5.3.2 Anisotropy (pp. 126-128):**
- Rotating force vectors (43 pN, 0.5 Hz rotation) on MDA-MB 231 cell
- Trajectory not circular --> anisotropic response
- Principal axes: long axis 12+/-1.6 nm, short axis 6.4+/-0.98 nm

**5.3.3 Cell adaptation (pp. 129-130):**
- MDA-MB 231 (metastatic cancer) cells most adaptive to applied force
- Response amplitude varies during first application; stabilizes after ~10 minutes

#### 5.4 Conclusions (pp. 130-131)
- MCF-10A (normal) cells probably stiffer than cancer cells (consistent with AFM results)
- Mechanical properties could be a marker of malignancy
- Large variation between cells of same type limits conclusions

### Chapter 6: Conclusions and Future Work (pp. 132-135)

#### 6.1 Conclusions (pp. 132-134)
Summarizes all contributions. Key achievement: integrated actuation + measurement + control system for nanometer-scale biological manipulation.

#### 6.2 Recommended Future Work (pp. 134-135)

**Directly relevant to our project:**
1. **Development of 3D magnetic tweezers** -- extend quadrupole to hexapole for 3D force generation. Force modeling and control approaches "can be extended." This is exactly what the 2011 journal paper (Zhang and Menq) accomplished.
2. **Intracellular experiments** -- smaller beads needed; force proportional to V (bead volume) and proportional to 1/l_A^5, so smaller l_A is critical. Alternative fabrication methods may be required.

### Bibliography (pp. 136-148)
82 references. Key references for our project:
- [38] Gosse and Croquette (2002) -- six-pole magnetic tweezers, position feedback
- [40] Fisher et al. (2006) -- hexapole design, thin-foil magnetic force system
- [53] MuShield -- magnetic shielding alloy (pole material)
- [54] Magnetic monopole approximation reference
- [55] Spherical bead magnetization in external field
- [56] Bowler -- frequency dependence of relative permeability in steel

## Equations and Parameters We Use

| Parameter/Equation | Value/Expression | Context | Page |
|--------------------|------------------|---------|------|
| B_a (single pole field) | Phi/(4*pi*r^2) | Magnetic monopole approximation | 18 |
| q (magnetic charge) | Phi/mu_0 | Definition | 19 |
| k_m | mu_0/(4*pi) = 1.0e-7 N/A^2 | Magnetic field coefficient | 19 |
| B (total field) | sum(k_m * q_j/r_j^2 * u_hat_j) | Superposition of all poles | 20 |
| m_b (bead magnetization) | (3V/mu_0)*((mu-mu_0)/(mu+2*mu_0))*B | Spherical superparamagnetic bead | 21 |
| F (magnetic force) | k_Q * Q^T * M * Q | Quadratic form in charges | 22 |
| k_Q | (3*V*k_m^2)/(2*mu_0*l_A^5) * ((mu-mu_0)/(mu+2*mu_0)) | Lumped coefficient | 22 |
| M(j,k) simplified | See eqn. (2.10) text above | Avoids gradient computation | 23 |
| F_Qx(0,0) | 6*(q_1^2 - q_3^2) | Force at center (quadrupole) | 23 |
| K_I (flux distribution) | [3/4, -1/4, -1/4, -1/4; ...] | 4x4 matrix for quadrupole | 25 |
| R_a (air reluctance) | 1.8e9 AT/Wb | Dominates circuit | 25 |
| R_p (pole reluctance) | 7.5e5 AT/Wb | << R_a | 25 |
| R_y (yoke reluctance) | 1.6e5 AT/Wb | << R_a | 25 |
| Complete force model | F = k_I * I^T * N * I | N = K_I^T * M * K_I | 26 |
| k_I_hat (lumped force gain) | k_Q*(N_c/(mu_0*R_a))^2 * I_max^2 | Calibrated experimentally | 27 |
| Current constraint | sum(I_j) = 0 | Analogous to sum(q_j) = 0 | 27 |
| Skin depth limit | f = 1469 Hz | For 100 um pole foil | 29 |
| Inverse force (simplified) | F_hat_x = F_hat_cx + 18*x | 1st-order Taylor at center | 95 |
| Bead dynamics | G(s) = 1/(gamma*s) | Overdamped integrator | 90 |
| Min variance controller | C(z) = gamma/(t_s*(1+z^-1+z^-2)) | Optimal for Brownian reduction | 107 |
| Min position variance | var(x) = 6*k_B*T*t_s/gamma | Limited by time delay | 108 |
| Pole material | MuShield Ni-Fe-Mo alloy | mu_R = 36000 (pole), saturation ~0.9 T | 13, 25 |
| Yoke material | Cold rolled steel | mu_R = 5000 | 15, 25 |
| l_A (quadrupole) | 490 um (fitted) | Physical tip distance = 405 um | 21 |
| l_A (modified setup) | 700 um | Two-layer design for cells | 118 |
| Saturation current (original) | 0.9 A | 21-turn coils, 100 um poles | 103 |
| Saturation current (modified) | 1.2 A | 40-turn coils, 150 um poles | 120 |
| Damping coefficient | gamma = 5.28e-8 N*s/m | 2.8 um bead, Faxen beta = 2.33 | 101 |
| Calibrated force gain | k_I_hat = 0.34 pN | 2.8 um bead, I_max = 0.9 A | 101 |
| Max force (modified) | +/-43 pN | 4.5 um bead, I_max = 1.2 A | 120 |
| Cell stiffness (MCF-7) | k_cell = 1.0e-3 N/m | Kelvin-Voigt model | 125 |
| Cell viscosity (MCF-7) | gamma_cell = 0.85e-3 N*s/m | Kelvin-Voigt model | 125 |

## Comparison: Quadrupole (This Dissertation) vs. Hexapole (2011 Paper)

| Feature | Quadrupole (2009) | Hexapole (2011) |
|---------|-------------------|-----------------|
| Poles | 4 (in-plane) | 6 (two layers of 3) |
| Force dimensions | 2D (x, y) | 3D (x, y, z) |
| FEM software | Ansoft Maxwell | ANSYS (our APDL scripts) |
| Pole arrangement | 0, 90, 180, 270 deg | 0, 60, 120, 180, 240, 300 deg |
| Force model form | F = Q^T M Q (4x4) | F = Q^T M Q (6x6) |
| K_I matrix | 4x4 | 6x6 |
| Inverse model constraints | 2 (sum=0, linear) | 3 (for 6 unknowns, 3 eqns) |
| l_A | 490 um | ~500 um (from 2011 paper) |

## Figures Worth Revisiting

| Figure | Page | Description | Why revisit |
|--------|------|-------------|-------------|
| Fig. 2.1 | 14 | Design concept schematic | Quadrupole pole arrangement |
| Fig. 2.2 | 15 | Pole tips photograph (5x) | Physical pole tip geometry |
| Fig. 2.3 | 16 | CAD model and photo | Yoke design |
| Fig. 2.5 | 19 | Monopole approximation diagram | Field analysis geometry |
| Fig. 2.6 | 21 | FEM vs. monopole comparison | Validation of theoretical model |
| Fig. 2.7 | 25 | Magnetic circuit diagram | Reluctance network |
| Fig. 2.8 | 31 | Force envelopes at positions | Force directionality |
| Fig. 2.9 | 32 | Force anisotropy contour (Gamma) | Working area limits |
| Fig. 4.3 | 96 | Inverse model solution surfaces | Accuracy of Taylor approx |
| Fig. 4.5 | 101 | PSD calibration curves | System identification |
| Fig. 4.7 | 103 | Force gain vs. I_max | Saturation characterization |
| Fig. 5.1 | 119 | Modified two-layer design | Cell experiment setup |

## Cross-References

- **Zhang and Menq 2011 (journal paper):** Direct extension of this work to hexapole (6-pole, 3D). The force model, monopole approximation, and inverse model framework are all generalized from 4-pole to 6-pole.
- **Fei Long dissertation (2016):** Likely continues this research line at OSU/PMCL lab. Should cover the hexapole implementation in detail and ANSYS FEM simulation.
- **Actively Controlled paper:** Another paper in the series, likely bridging this dissertation and the 2011 paper.

## Page Ranges for Claude

| Pages   | Main Topic |
|---------|------------|
| 1-10    | Title, abstract, table of contents, list of figures/tables |
| 11-17   | List of symbols (complete definitions) |
| 18-22   | **Ch.2 (2.1-2.2): Quadrupole design, physical dimensions, materials** |
| 23-27   | **Ch.2 (2.3.1): Magnetic monopole approximation, field analysis** |
| 28-32   | **Ch.2 (2.3.2-2.3.3): Force analysis, magnetic circuit, reluctances** |
| 33-37   | **Ch.2 (2.4-2.6): Bandwidth, directionality, conclusions** |
| 38-42   | Ch.3 (3.1-3.2): Particle tracking intro, experimental setup |
| 43-47   | Ch.3 (3.3-3.4): Lateral/axial estimation algorithms |
| 48-57   | Ch.3 (3.5-3.6): Error analysis, bright-field results |
| 58-67   | Ch.3 (3.7-3.8): Fluorescent extension, intensity normalization |
| 68-77   | Ch.3 (3.9-3.10): Resolution enhancement, BLUE estimation |
| 78-85   | Ch.3 (3.11-3.12): Fluorescent results, conclusions |
| 86-91   | **Ch.4 (4.1-4.2): Control intro, block diagram, bead dynamics** |
| 92-98   | **Ch.4 (4.3-4.4): Inverse force model, controllability** |
| 99-106  | **Ch.4 (4.5): System calibration (PSD, saturation, validation)** |
| 107-115 | Ch.4 (4.6-4.8): Minimum variance control, stepping, conclusions |
| 116-123 | **Ch.5 (5.1-5.2): Modified two-layer setup, sample preparation** |
| 124-131 | Ch.5 (5.3-5.4): Cell experiments, creep, anisotropy, adaptation |
| 132-135 | **Ch.6: Conclusions, future work (hexapole recommended)** |
| 136-148 | Bibliography (82 references) |

## Notes on FEM Usage in This Dissertation

**Important:** This dissertation does **NOT** contain detailed ANSYS FEM simulation methodology. The FEM validation is done using **Ansoft Maxwell** (a commercial electromagnetics FEM package, now part of ANSYS Electronics Desktop), and it is used only for validation of the monopole model -- not as the primary simulation tool. The FEM details are minimal:

- CAD model "similar to the one shown in Fig. 2.3" was built in Maxwell (p. 20)
- "Magnetic and electric properties are assigned to each component" (p. 20)
- Currents assigned to coils, field computed (p. 20)
- Result: contour comparison showing good agreement with monopole theory (Fig. 2.6)
- The effective charge location l_A = 490 um was determined by fitting monopole model to FEM field (p. 21)

**For detailed ANSYS APDL simulation methodology, look to:**
1. The Fei Long dissertation (2016) -- likely contains the actual ANSYS implementation
2. The Zhang and Menq 2011 journal paper -- may reference ANSYS for hexapole validation
3. The "Actively Controlled" paper -- may bridge Maxwell to ANSYS transition
