# References

Reference papers for the magnetic tweezers ANSYS simulation project.

## How This Works

This folder uses a **notes-first** strategy for working with Claude Code:

| Tier | When | Action |
|------|------|--------|
| **1. Notes** | 95% of cases | Read `notes/*.md` directly |
| **2. Targeted text** | Notes lack detail | Read `texts/*.txt` at specific line range (use `_page_index.txt` to locate pages), then update notes |
| **3. Full intake** | New paper added | Convert PDF via `pdftotext -layout`, read TOC, build skeleton note, deep-read key sections |

## Paper Index

<!-- Add papers here as they are processed. Citation key = note filename without .md -->

| Citation Key | Authors | Year | Type | Tags | Note Status |
|--------------|---------|------|------|------|-------------|
| zhang-dissertation | Zhipeng Zhang | 2009 | PhD Dissertation | force-modeling, monopole-approximation, magnetic-circuit, calibration, quadrupole | complete |
| long-2016-dissertation | Fei Long | 2016 | PhD Dissertation | geometry, materials, fem-simulation, calibration, force-model, inverse-model, pole-naming, coil-design, superposition, hall-sensor | complete |
| zhang-2011-actuator-design | Z. Zhang, C.-H. Menq | 2011 | journal | geometry, materials, force-model, superposition, coil-design, pole-configuration, magnetic-circuit, inverse-model, calibration | complete |
| long-2016-active-control | F. Long, D. Matsuura, C.-H. Menq | 2016 | journal | geometry, materials, fem-simulation, calibration, force-model, inverse-model, optimal-control | complete |

## Topic Index

### Geometry & Device Design
- [zhang-dissertation](notes/zhang-dissertation.md) -- Quadrupole design: pole material (MuShield), dimensions, yoke
- [long-2016-dissertation](notes/long-2016-dissertation.md) -- Hexapole design: 1018 steel poles (40 um tip), 70-turn coils, 6-pole geometry, workspace 500 um
- [zhang-2011-actuator-design](notes/zhang-2011-actuator-design.md) -- Hexapole design: Ni-Fe-Mo foil poles (40 um tip, 178 um thick), 50-turn AWG#24 coils, rho=594 um, two-layer config
- [long-2016-active-control](notes/long-2016-active-control.md) -- Same 1018 steel hexapole as Long diss; FEM mesh in Fig. 2(b) is our ANSYS reference

### Materials & Magnetic Properties
- [zhang-dissertation](notes/zhang-dissertation.md) -- MuShield Ni-Fe-Mo alloy (mu_R=36000), cold rolled steel yoke (mu_R=5000), saturation ~0.9T
- [long-2016-dissertation](notes/long-2016-dissertation.md) -- 1018 low-carbon steel (>2T saturation), air reluctance 6.3e8 A/Wb, nonlinear B-H modeling
- [zhang-2011-actuator-design](notes/zhang-2011-actuator-design.md) -- Ni-Fe-Mo alloy poles (B_sat ~2.1 T), cold-rolled steel yoke, AWG#24 wire
<!--  -->

### FEM Simulation Methods
- [long-2016-dissertation](notes/long-2016-dissertation.md) -- ANSYS APDL magnetostatic, SOLID96/SOURC36, unit-excitation superposition, 6-solve approach
- [zhang-2011-actuator-design](notes/zhang-2011-actuator-design.md) -- References FEM for reluctance calibration (R_a=2.8e9 A/Wb), no FEM details given (see [18])
<!--  -->

### Calibration & Force Measurement
- [zhang-dissertation](notes/zhang-dissertation.md) -- PSD-based calibration, saturation current, inverse force model validation
- [long-2016-dissertation](notes/long-2016-dissertation.md) -- Flux distribution matrix K_I calibration, Hall-sensor force model, Langevin bead magnetization
- [zhang-2011-actuator-design](notes/zhang-2011-actuator-design.md) -- PSD-based k_I_hat calibration (0.53 pN at 1.2A), Brownian motion validation
<!--  -->

### Superposition & Field Computation
- [zhang-dissertation](notes/zhang-dissertation.md) -- Monopole approximation, superposition principle, quadratic force model F=Q^T*M*Q
- [long-2016-dissertation](notes/long-2016-dissertation.md) -- Magnetic charge model, quadratic force F=g*I^T*K^T*L*K*I, optimal inverse model, least-square position fitting
- [zhang-2011-actuator-design](notes/zhang-2011-actuator-design.md) -- Magnetic charge model, K_I matrix (5/6, 1/6), quadratic force F_hat=I_hat^T*N*I_hat, inverse model
<!--  -->

## Expected PDF Files

The following PDFs should be placed in `pdfs/` (gitignored, not tracked):

- `Design_and_Modeling_of_a_3-D_Magnetic_Actuator_for_Magnetic_Microbead_Manipulation.pdf` — Zhang & Menq, IEEE/ASME Trans. Mechatronics, 2011 (10 pp.)
- `Actively_Controlled_Hexapole_Electromagnetic_Actuating_System_Enabling_3-D_Force_Manipulation_in_Aqueous_Solutions.pdf` — (12 pp.)
- `Fei Long_dissertation.pdf` — Long, PhD Dissertation, Ohio State University, 2016 (167 pp.)
- `Zhipeng Zhang.pdf` — Zhang, PhD Dissertation (165 pp.)

## Text Extraction

PDFs are converted to text using Poppler's `pdftotext -layout` and stored in `texts/` (gitignored).
Each text file has a `_page_index.txt` that maps PDF page numbers to line numbers.

To regenerate all text files:
```bash
PBIN="C:/Users/pmero/AppData/Local/Microsoft/WinGet/Packages/oschwartz10612.Poppler_Microsoft.Winget.Source_8wekyb3d8bbwe/poppler-25.07.0/Library/bin"
for f in references/pdfs/*.pdf; do
  "$PBIN/pdftotext.exe" -layout "$f" "references/texts/$(basename "$f" .pdf).txt"
done
```

## Adding a New Paper

1. Place PDF in `pdfs/` with naming convention: `firstname-year-short-topic.pdf`
2. Run `pdftotext -layout` to generate text extract in `texts/`
3. Generate page index: `awk 'BEGIN{page=1; print "Page 1: line 1"} /\f/{page++; print "Page " page ": line " NR}' texts/name.txt > texts/name_page_index.txt`
4. Copy `notes/_TEMPLATE.md` to `notes/firstname-year-short-topic.md`
5. Read the TOC from text file and build a skeleton note
6. Fill in key sections based on project needs
7. Update the Paper Index and Topic Index tables above
