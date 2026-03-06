# Design and Modeling of a 3-D Magnetic Actuator for Magnetic Microbead Manipulation

## Bibliographic Info

| Field       | Value |
|-------------|-------|
| Authors     | Zhipeng Zhang (Member, IEEE) and Chia-Hsiang Menq (Senior Member, IEEE) |
| Year        | 2011 |
| Type        | journal |
| Source      | IEEE/ASME Transactions on Mechatronics, Vol. 16, No. 3, June 2011, pp. 421-430 |
| DOI/URL     | 10.1109/TMECH.2011.2105500 |
| PDF file    | `pdfs/Design_and_Modeling_of_a_3-D_Magnetic_Actuator_for_Magnetic_Microbead_Manipulation.pdf` |
| Total pages | 10 (pp. 421-430) |
| Received    | July 14, 2010; revised October 29, 2010; accepted December 10, 2010; published February 10, 2011 |
| Affiliation | Department of Mechanical and Aerospace Engineering, The Ohio State University, Columbus, OH 43210 |
| Funding     | NIH Grant R21RR024435 |

## Relevance to This Project

This is the **primary reference** for our ANSYS magnetic tweezers simulation. It describes the exact hexapole magnetic actuator we are modeling: the geometry, pole configuration, materials, coil specifications, magnetic circuit analysis, and force model. Every geometric parameter, material choice, and pole naming convention in our APDL scripts originates from this paper.

**Tags:** geometry, materials, fem-simulation, force-model, superposition, coil-design, pole-configuration, magnetic-circuit, inverse-model, calibration

## Key Contributions

- Design and implementation of a hexapole magnetic actuator capable of 3-D manipulation of magnetic microbeads
- Derivation of a lumped-parameter magnetic force model based on "magnetic charge" assumption, yielding quadratic form F_hat = I_hat^T * N * I_hat
- Analysis of force generation capability using force envelopes and quantitative measures (anisotropy Gamma, minimum envelope force F_min)
- Derivation of a simplified inverse force model (linear) for real-time feedback control: I_hat = D*(F_hat - U*P) + E
- Experimental validation via feedback-controlled Brownian motion analysis of a 2.8 um bead
- Force gain k_I_hat calibrated to 0.53 pN at I_max = 1.2 A
- Hexapole configuration obtained by rotating three orthogonal pole pairs to free the optical path

## Detailed Notes by Section

### I. Introduction (pp. 1-2, lines 1-134)

Context: Magnetic microbeads used in biophysics for DNA manipulation, cell mechanics, intracellular probing. Magnetic actuators categorized by number of poles:
- 1-pole: attractive force only toward tip [2, 10, 16, 17]
- 2-pole: forward/backward along one axis [1, 11]
- 3-pole (120 deg apart) or 4-pole (quadrupole): 2-D force [3, 18, 19]
- 6-pole: 3-D force [9, 20] -- this paper

Challenge: Force model for multipolar actuators is difficult because (1) mutual magnetization between poles, (2) force depends on field gradient. Previous work: quadrupole model [18] and feedback control [19] for 2-D. This paper extends to 3-D hexapole.

Paper organization: Section II = design and implementation, Section III = force model and capability, Section IV = inverse force model, Section V = experimental validation, Section VI = conclusion.

### II. Actuator Design and Implementation (pp. 2-3, lines 121-197)

#### A. Design Concept (pp. 2-3, lines 123-168)

The actuator consists of:
1. Six sharp-tipped magnetic poles concentrating flux into workspace
2. Six individual actuating coils (one per pole)
3. A magnetic yoke connecting all coils and poles (completes magnetic circuit)

**Hexapole configuration:** Six poles are NOT in the same plane, but in two layers [Fig. 1(b)]:
- Three dark-colored poles on a plane BELOW the specimen
- Three light-colored poles on a plane ABOVE the specimen
- The specimen (in a cell chamber between two coverslips) is in the workspace between the two layers

**Coordinate rotation:** Starting from 3 orthogonal pairs [Fig. 2(a)] where two poles along z-axis would block the optical path, a coordinate rotation yields the hexapole configuration [Fig. 2(b)] with all poles on two horizontal planes, leaving the optical path clear.

**Two coordinate frames defined [Fig. 2]:**
- Actuation coordinate frame: {O; x_a, y_a, z_a} -- aligned with pole pair axes
- Measurement coordinate frame: {O; x_m, y_m, z_m} -- aligned with microscope axes

**Rotation matrix** (left-multiply transforms measurement frame to actuation frame):

```
        [ 1/sqrt(6)   -1/sqrt(2)   -1/sqrt(3) ]
a_m R = [ 1/sqrt(6)    1/sqrt(2)   -1/sqrt(3) ]
        [ 2/sqrt(6)       0         1/sqrt(3) ]
```

**Pole locations in actuation frame:** The six poles are at [+/-rho, 0, 0], [0, +/-rho, 0], [0, 0, +/-rho], where rho = distance from workspace center to each pole tip.

**Pole numbering [Fig. 2(b)]:** P1 through P6 labeled in the figure. This is the paper pole convention. The pole indices and their positions in the measurement frame are critical for our simulation (see MEMORY.md for APDL-to-paper mapping).

#### B. Implementation (pp. 3-4, lines 170-196)

**Pole material:**
- High-permeability magnetic foils, 178 um thick (p. 3)
- Material: nickel-iron-molybdenum alloy (p. 3)
- Properties: high permeability, minimum hysteresis loss (p. 3)
- Saturation induction: ~2.1 T (p. 3, line 177)
- Machined by wire electrical discharge machining (wire EDM) (p. 3)
- Pole tip radius: ~40 um (p. 3, line 180)

**Pole assembly:**
- Three poles glued onto a No. 1 coverslip (thickness 0.13-0.15 mm) with low-viscosity epoxy [Fig. 3(a)]
- Pole tips form an equilateral triangle, side length ~840 um (p. 3, line 183)
- Other three poles fixed on a 1.2 mm thick glass slide [Fig. 3(b)]
- Two layers fixed face-to-face [Fig. 3(c)]
- Distance between two layers controlled by spacers: 508 um (p. 3, line 190)
- Resulting distance from workspace center to each pole: rho = 594 um (p. 3, line 193)

**Cell chamber:**
- Formed by stacking: No. 1 coverslip + seal ring (120 um thick) + No. 1 coverslip (p. 3, lines 194-195)
- Sealed with water solution containing suspended magnetic microbeads

**Magnetic yoke:**
- Shape: square loop with six protrusions for coil assembly (p. 3, line 175)
- Material: cold-rolled steel (p. 3, line 177)

**Coils:**
- Wire: AWG #24 magnetic wire, diameter = 0.51 mm (p. 3, line 178-179)
- Turns: 50 turns per coil (p. 3, line 180)
- Wound by hand (p. 3, line 178)

**Power amplifiers:**
- Model: BTA-18V-6A (Precision Micro Dynamics) (p. 3, line 182)
- Configuration: current mode (p. 3)
- Proportional gain: 0.3 A/V (p. 3, line 183)

**Microscope integration:**
- Inverted microscope: Nikon TE2000-U (p. 3, line 187)
- Setup thickness < 10 mm, fits between high-NA objective and high-NA condenser (p. 3, lines 188-189)

### III. Magnetic Force Model (pp. 3-6, lines 198-348)

#### A. Theoretical Derivation (pp. 4-5, lines 212-286)

**Magnetic charge assumption:** Each sharp-tipped pole generates a field that appears (from the workspace) as though from a point source. Total field = superposition of six point magnetic charges. Sum of all charges = 0 (no net charge). This is an extension of the magnetic dipole model -- a "magnetic hexapole model."

**Equation (1) -- Magnetic field from point charges (p. 4):**
```
B = sum_{j=1}^{6} k_m * (q_j / r_j^2) * u_j
```
where:
- k_m = mu_0 / (4*pi) = 1.0e-7 N/A^2
- mu_0 = permeability of vacuum
- q_j = magnetic charge = Phi_j / mu_0 (Phi = magnetic flux)
- r_j = distance from charge j to magnetic particle
- u_j = unit vector from charge j to particle

**Magnetic circuit [Fig. 5] (p. 4):**
- F_mmf = N_c * I = magnetomotive force (N_c turns, current I)
- R_p = lumped reluctance of a magnetic pole
- R_y = lumped reluctance of 1/6 of the yoke
- R_a = lumped reluctance from pole tip to workspace center in air
- Since yoke and poles are much more permeable than air: R_a >> R_p, R_y
- Simplification: neglect R_p and R_y

**Equation (2) -- Charges from currents (p. 4):**
```
Q = (N_c / (mu_0 * R_a)) * K_I * I
```
where:
- Q = [q1, q2, ..., q6]^T
- I = [I1, I2, ..., I6]^T
- K_I = 6x6 magnetic flux distribution matrix
- K_I diagonal terms = 5/6, off-diagonal terms = 1/6

**Reluctance value:** R_a = 2.8e9 A/Wb, determined by comparing analytical field (Eq. 1) with FEM results [18] (p. 4, line 247). Alternatively, R_a is lumped into k_I_hat for experimental calibration (approach adopted in this paper).

**Calculated magnetic field [Fig. 6]:** Field plotted in x_m-y_m and x_m-z_m planes when 1 A applied to coil of pole #5 (P5). Six poles drawn in scale. Dark poles above specimen, light poles below.

**Equation (3) -- Gradient force on superparamagnetic bead (p. 5):**
```
F = (1/2) * grad(m . B)
```
where m = (3V/mu_0) * ((mu - mu_0)/(mu + 2*mu_0)) * B is the effective magnetization.

**Equation (4) -- Normalized force model (quadratic form) (p. 5):**
```
F_hat = F / k_I_hat = I_hat^T * N * I_hat
```
where:
- F_hat = normalized 3x1 force vector (dimensionless)
- k_I_hat = lumped force gain (unit: Newton) -- contains bead properties, magnetic circuit properties, and I_max
- I_hat = I / I_max = normalized 6x1 current vector, each element in [-1, 1]
- N = 6x6 position-dependent matrix, each element is a 3x1 dimensionless vector
- Details of N computation in reference [18]

**Key insight:** The force is QUADRATIC (nonlinear) in the currents, even though the magnetic field is LINEAR in currents.

#### B. Magnetic Force Generation Capability (pp. 5-6, lines 337-348)

**Force envelopes [Fig. 7]:** At any location, all possible force vectors from all current combinations are computed. The end points fill a closed volume (force envelope).
- At workspace center [0,0,0]: symmetric envelope, zero force at center of volume
- Away from center: envelope deforms, stretched toward nearest pole
- Zero force point always inside envelope => can generate force in ANY direction

**Quantitative measures:**
1. **Force generation anisotropy Gamma:** ratio of smallest to largest force magnitude
   - Maximum Gamma = 0.58 at workspace center (p. 5, line 338)
   - Decreases moving away from center toward any pole
   - Contour surfaces [Fig. 8]: Gamma = 0.25 (innermost), 0.10 (middle), 0.04 (outermost)
   - For accurate force application, constrain Gamma > 0.1 => workspace within sphere of radius ~0.3 (normalized) (p. 6, line 403)

2. **Minimum envelope force F_hat_min:** magnitude of smallest force vector
   - Contour surface for F_hat_min = 3 shown in [Fig. 9]
   - Value 3 chosen because it is half the maximum force with inverse model (p. 6, line 412)

### IV. Inverse Force Model (pp. 6-8, lines 349-487)

#### A. Theoretical Derivation (pp. 6-7, lines 365-472)

**Problem:** Given desired force, find 6 currents. Underdetermined: 6 unknowns, 3 equations. Need 3 constraints.

**Constraint (5) -- Zero-sum current (p. 6):**
```
I_hat_1 + I_hat_2 + I_hat_3 + I_hat_4 + I_hat_5 + I_hat_6 = 0
```
Physical meaning: equal current to all coils produces zero net charge and zero field.

**Equation (6) -- Decoupled force at workspace center (p. 6):**
Under constraint (5), the force model at the center simplifies to:
```
a_F_hat_cx = 6 * (I_hat_1^2 - I_hat_2^2)
a_F_hat_cy = 6 * (I_hat_3^2 - I_hat_4^2)
a_F_hat_cz = 6 * (I_hat_5^2 - I_hat_6^2)
```
(In normalized actuation frame.) Normalized forces range: [-6, 6].

**Key observation:** Each force component depends on only ONE pair of opposing poles. This is the decoupled structure that makes the inverse model tractable.

**Equation (7) -- Linear inverse solution (p. 7):**
```
I_hat = D * a_F_hat_c + E
```
where:
```
      [ 1/8  -1/8   0     0     0     0  ]^T
D =   [ 0     0    1/8  -1/8    0     0  ]
      [ 0     0     0     0   -1/16  1/16]

E = [1/3, 1/3, 1/3, 1/3, -2/3, -2/3]^T
```
This introduces 3 constraints (mapping 3 force components to 6 currents).

**Equation (8) -- Constrained force model (p. 7):**
```
a_F_hat = (D * a_F_hat_c + E)^T * a_N * (D * a_F_hat_c + E)
```
No longer underdetermined; unique inverse solution possible.

**Equation (9) -- First-order Taylor approximation (p. 7):**
```
a_F_hat ~ a_F_hat_c + U * a_P
```
where U = diag(8, 8, 32) and a_P = normalized position in actuation frame.

**Equation (10) -- Simplified inverse force model (p. 7):**
```
I_hat ~ D * (a_F_hat - U * a_P) + E
```
Valid when bead is near workspace center and desired force is not very large.

#### B. Force Generation Capability with Inverse Model (pp. 7-8, lines 474-487)

**Force envelopes [Fig. 10]:** Smaller than unconstrained envelopes (Fig. 7). At [0,0,0.3], zero force point no longer inside envelope.

**Anisotropy contours [Fig. 11]:** Gamma = 0.25, 0.10, 0.04 surfaces all smaller than Fig. 8. A "degeneration boundary" (near Gamma = 0.04) exists beyond which force generation degenerates and stable feedback control is impossible.

**Minimum envelope force [Fig. 12]:** F_hat_min = 3 surface is smaller than Fig. 9.

**Conclusion:** Inverse model does not fully utilize actuator capability but provides a simple linear formula adequate for real-time control.

### V. Experimental Validation of the Force Model (pp. 8-9, lines 506-611)

**Experimental setup:**
- Microscope: Nikon TE2000-U with 60x dry objective lens (CFI Super Plan Fluor ELWD 60xC) (p. 8, line 520)
- Camera: high-speed CMOS, Mikrotron MC 1310 (p. 8, line 524)
- 3-D tracking via in-focus and off-focus image analysis [18, 19]
- Lateral measurement range: 200 um (limited by camera FOV) (p. 8, line 528)
- Axial measurement range: up to 18 um (limited by depth of focus) (p. 8, line 529)
- Sampling rate: 200 frames/s (p. 8, line 531)

**Magnetic bead:** 2.8 um diameter (M280, Dynal) (p. 8, line 538)

**Experiment: 3-D grid raster scan [Fig. 13]:**
- Grid: 5 x 5 x 3 locations (p. 8, line 543)
- Lateral step: 20 um; axial step: 5 um (p. 8, line 498)
- Maximum input current: I_max = 1.2 A (p. 9, line 504)
- Bead controlled at each location for 10 s; last 5 s of data used (after transient vanishes)
- Brownian motion restricted within +/- 210 nm (p. 8, line 495)

**Langevin equation (11) (p. 9):**
```
m * x_ddot(t) + gamma * x_dot(t) = F_T(t) + F_x(t)
```
- m = bead mass (negligible inertia for microscopic particle)
- gamma = damping coefficient in water
- F_T = random thermal (Langevin) force (zero mean, white noise)
- F_x = applied magnetic force

At steady state with constant set point: mean damping force -> 0, so mean magnetic force = 0. This provides validation.

**Results [Fig. 14, 15]:**
- Steady-state currents vary with position as expected from inverse model
- Calculated magnetic forces from measured currents and positions are very close to zero in all three directions
- Fluctuations in currents and forces are due to controller compensating thermal forces
- This **partially verifies** the force model accuracy

**Force gain calibration (p. 9, line 606):**
- Method: PSD analysis of controlled Brownian motion to determine loop gain
- k_I_hat = 0.53 pN at I_max = 1.2 A
- Force range = k_I_hat * force envelopes (Figs. 7 and 10)

### VI. Conclusion (pp. 9-10, lines 614-617)

Summary of contributions. The developed micromanipulator can apply controlled 3-D forces to magnetic microbeads for probing biological samples and characterizing 3-D mechanical properties.

## Equations and Parameters We Use

### Geometric Parameters

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| Pole tip radius | ~40 um | Round tip of machined magnetic foil | 3 (line 180) |
| Pole foil thickness | 178 um | High-permeability magnetic foil | 3 (line 174) |
| Equilateral triangle side length | ~840 um | Formed by three pole tips on each layer | 3 (line 183-184) |
| Distance between two pole layers | 508 um | Controlled by spacer height | 3 (line 190) |
| Distance workspace center to pole (rho) | 594 um | Hexapole geometry after assembly | 3 (line 193) |
| Seal ring thickness | 120 um | Cell chamber spacing | 3 (line 195) |
| Coverslip thickness (No. 1) | 0.13-0.15 mm | Lower pole substrate | 3 (line 181) |
| Glass slide thickness | 1.2 mm | Upper pole substrate | 3 (line 185) |
| Setup total thickness | < 10 mm | Fits between objective and condenser | 3 (line 189) |

### Material Properties

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| Pole material | Nickel-iron-molybdenum alloy | High permeability, low hysteresis | 3 (line 175) |
| Pole saturation induction | ~2.1 T | Pole material property | 3 (line 177) |
| Yoke material | Cold-rolled steel | Square loop yoke | 3 (line 177) |

### Coil Specifications

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| Wire gauge | AWG #24 | Magnetic wire | 3 (line 178-179) |
| Wire diameter | 0.51 mm | AWG #24 | 3 (line 179) |
| Number of turns (N_c) | 50 | Per coil | 3 (line 180) |
| Maximum current (I_max) | 1.2 A | Experimental setting | 9 (line 504) |

### Magnetic Circuit Parameters

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| k_m | mu_0/(4*pi) = 1.0e-7 N/A^2 | Magnetic constant | 4 (line 238) |
| R_a (air reluctance) | 2.8e9 A/Wb | From FEM comparison | 4 (line 247) |
| K_I diagonal | 5/6 | Flux distribution matrix | 4 (line 234) |
| K_I off-diagonal | 1/6 | Flux distribution matrix | 4 (line 235) |

### Force Model Parameters

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| k_I_hat (force gain) | 0.53 pN | At I_max = 1.2 A, calibrated from Brownian motion PSD | 9 (line 606) |
| Max Gamma at center | 0.58 | Force generation anisotropy | 5 (line 338) |
| Gamma > 0.1 workspace radius | ~0.3 (normalized) | Practical workspace limit | 6 (line 403) |
| U matrix | diag(8, 8, 32) | Position-dependent linearization | 7 (line 463) |

### Key Equations

| Equation | Expression | Context | Page |
|----------|-----------|---------|------|
| (1) | B = sum k_m * (q_j/r_j^2) * u_j | Magnetic field from point charges | 4 |
| (2) | Q = (N_c/(mu_0*R_a)) * K_I * I | Charges from currents | 4 |
| (3) | F = (1/2) * grad(m . B) | Gradient force on superparamagnetic bead | 5 |
| (4) | F_hat = I_hat^T * N * I_hat | Normalized quadratic force model | 5 |
| (5) | sum(I_hat_i) = 0 | Zero-sum current constraint | 6 |
| (6) | F_hat_cx = 6*(I1^2 - I2^2), etc. | Decoupled force at center | 6 |
| (7) | I_hat = D * F_hat_c + E | Linear inverse at center | 7 |
| (9) | F_hat ~ F_hat_c + U*P | First-order Taylor approx. | 7 |
| (10) | I_hat ~ D*(F_hat - U*P) + E | Simplified inverse force model | 7 |
| (11) | m*x_ddot + gamma*x_dot = F_T + F_x | Langevin equation | 9 |

### Experimental Parameters

| Parameter | Value | Context | Page |
|-----------|-------|---------|------|
| Bead diameter | 2.8 um | Dynal M280 | 8 (line 538) |
| Bead type | M280 (Dynal) | Superparamagnetic | 8 (line 538) |
| Sampling rate | 200 frames/s | Control loop | 8 (line 531) |
| Lateral measurement range | 200 um | Camera FOV limited | 8 (line 528) |
| Axial measurement range | up to 18 um | Depth of focus limited | 8 (line 529) |
| Brownian motion amplitude | +/- 210 nm | Controlled bead at set point | 8 (line 495) |
| Power amplifier gain | 0.3 A/V | Current mode output | 3 (line 183) |
| Grid scan dimensions | 5 x 5 x 3 | Raster scan experiment | 8 (line 543) |
| Lateral step | 20 um | Grid spacing | 8 (line 498) |
| Axial step | 5 um | Grid spacing | 8 (line 498) |
| Dwell time per location | 10 s (last 5 s used) | Data collection | 8 (line 504) |

## Figures Worth Revisiting

| Figure | Page | Description | Why revisit |
|--------|------|-------------|-------------|
| Fig. 1 | 2 | (a) Top-view design concept showing 6 poles; (b) side zoomed view showing two-layer arrangement | Understand physical layout, dark=below/light=above convention |
| Fig. 2 | 3 | (a) Orthogonal pole arrangement; (b) rotated hexapole config with pole numbering P1-P6, both coordinate frames shown | **Critical**: pole numbering convention, coordinate frame definitions |
| Fig. 3 | 3 | Assembly process: (a) top 3 poles on coverslip, (b) bottom 3 on glass slide, (c) face-to-face, (d) full setup with yoke and coils | Physical assembly reference, spacer arrangement |
| Fig. 4 | 3 | Photo of actuator on inverted microscope | Real device reference |
| Fig. 5 | 4 | Magnetic circuit diagram of hexapole actuator | Understand reluctance model, R_p, R_y, R_a definitions |
| Fig. 6 | 5 | Calculated B-field in x_m-y_m and x_m-z_m planes (1A to P5 coil), poles drawn in scale | **Critical**: compare with our ANSYS FEM results for verification |
| Fig. 7 | 5 | Force envelopes at [0,0,0], [0.3,0,0], [0,0,0.3] (unconstrained) | Force capability analysis |
| Fig. 8 | 6 | Contour surfaces of anisotropy Gamma (0.25, 0.10, 0.04) | Workspace boundary determination |
| Fig. 9 | 6 | Contour surface of F_hat_min = 3 | Workspace force limit |
| Fig. 10 | 7 | Force envelopes with inverse model constraints | Compare with Fig. 7 to see constraint effect |
| Fig. 11 | 7 | Anisotropy contours with inverse model, degeneration boundary | Controllability limits |
| Fig. 12 | 8 | F_hat_min = 3 contour with inverse model | Compare with Fig. 9 |
| Fig. 13 | 8 | 3-D grid trajectory (5x5x3) in measurement frame | Experimental protocol |
| Fig. 14 | 9 | Steady-state currents I1, I3, I5 vs. grid position | Validation: currents vary with position |
| Fig. 15 | 9 | Calculated forces from applied currents -- should be ~0 | **Critical**: force model validation result |

## Cross-References

- [zhang-dissertation] -- Zhipeng Zhang PhD dissertation (2009, Ohio State University). Should contain extended details of the quadrupole work [18], FEM analysis, and possibly more geometric/material specifications.
- [long-dissertation] -- Fei Long PhD dissertation. Likely extends this hexapole work with additional experiments and control strategies.
- [18] Z. Zhang, K. Huang, and C.-H. Menq, "Design, implementation, and force modeling of quadrupole magnetic tweezers," ASME/IEEE Trans. Mechatronics, 2010. -- Contains details of matrix N computation and the quadrupole precursor.
- [19] Z. Zhang, Y. Huang, and C.-H. Menq, "Actively controlled manipulation of a magnetic microbead using quadrupole magnetic tweezers," IEEE Trans. Robot., 2010. -- Feedback control design and k_I_hat calibration method.

## Page Ranges for Claude

| Pages | Lines | Main Topic |
|-------|-------|------------|
| 1 | 1-70 | Title, abstract, keywords, beginning of Introduction |
| 2 | 71-134 | Introduction (cont.), Design concept (Sec. II-A) begins |
| 3 | 135-197 | Design concept (coordinate rotation, frames), Implementation (Sec. II-B): materials, geometry, coils, yoke |
| 4 | 198-287 | Force model derivation (Sec. III-A): magnetic charge model, Eqs. (1)-(2), magnetic circuit, reluctance |
| 5 | 288-348 | Force model (cont.): Eqs. (3)-(4), force envelopes [Fig. 7], anisotropy Gamma |
| 6 | 349-431 | Anisotropy contours [Fig. 8], F_hat_min [Fig. 9], Inverse force model (Sec. IV-A) begins: constraint (5), Eq. (6) |
| 7 | 432-487 | Inverse model: Eqs. (7)-(10), D/E/U matrices, Taylor approximation, force capability with inverse model |
| 8 | 488-545 | Inverse model capability (cont.) [Figs. 11-12], Experimental validation (Sec. V) begins: setup, bead, grid scan |
| 9 | 546-620 | Validation: Langevin eq. (11), steady-state currents [Fig. 14], forces [Fig. 15], k_I_hat = 0.53 pN, Conclusion (Sec. VI) |
| 10 | 621-670 | References [1]-[26], Author biographies |

## Notes for Our ANSYS Simulation

### What we directly use from this paper:
1. **Geometry**: pole tip radius (40 um), rho (594 um), triangle side (840 um), layer spacing (508 um), foil thickness (178 um)
2. **Materials**: Ni-Fe-Mo alloy poles (B_sat ~2.1 T), cold-rolled steel yoke
3. **Coils**: 50 turns, AWG #24 (0.51 mm diameter)
4. **Configuration**: hexapole in two layers, 3 poles per layer at 120 deg spacing
5. **Pole numbering**: P1-P6 as labeled in Fig. 2(b) -- mapped to APDL coil numbers in MEMORY.md
6. **Linear superposition**: the force model assumes superposition of fields from individual coils, which justifies our approach of running 6 unit-excitation simulations and combining results in MATLAB

### What our ANSYS simulation provides that the paper does not:
1. Detailed 3-D magnetic field distribution (the paper only shows analytical point-charge approximation)
2. Exact B-field values at arbitrary locations (for comparison with lumped-parameter model)
3. Saturation effects in pole tips (the analytical model assumes linearity)
4. Verification of the K_I flux distribution matrix values (5/6 and 1/6)

### FEM details mentioned in the paper:
- The paper mentions using "finite element software" [18] to determine R_a = 2.8e9 A/Wb by comparing analytical and FEM fields
- No details of the FEM simulation are given in this paper -- they reference [18] (the quadrupole paper)
- Our ANSYS simulation essentially performs the same FEM analysis but for the hexapole configuration
