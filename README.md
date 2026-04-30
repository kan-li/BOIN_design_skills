# BOIN Basic Skill Package

A professional tool for designing Bayesian Optimal Interval (BOIN) Phase I dose-finding trials in oncology. This package provides an AI-assisted workflow for trial design consultation, boundary table generation, operating characteristic simulations, and protocol documentation.

## 🎯 What is This?

The BOIN Basic Skill Package is an AI-powered assistant that helps biostatisticians and clinical trialists design Phase I dose-finding studies using the BOIN method (Yuan et al., 2016). It combines:

- **Intelligent consultation** - Guides you through design parameter selection
- **Automated outputs** - Generates decision tables, visualizations, and protocols
- **Quality assurance** - Built-in validation against canonical fixtures
- **Professional documentation** - Ready-to-submit protocol sections

## Video Demo

https://drive.google.com/file/d/1_NrBAgfitFNB-lxZ78FbaGfs8lDi7YZ1/view?usp=sharing


## Community

Catalyst Circle: https://catalyst-pharma.circle.so/c/public/


## ✨ Key Features

### 🤖 AI-Assisted Design Consultation
- Interactive Q&A to collect trial parameters
- Clinical context understanding (DLT definitions, dose levels, safety considerations)
- Automatic parameter validation and recommendations

### 📊 Comprehensive Outputs
- **Decision tables** (full and simplified, CSV + Markdown)
- **Visualizations** (flowchart, decision heatmap, OC plots)
- **Operating characteristics** (multi-scenario simulations)
- **Protocol documents** (ready for copy texts)

### 🎨 Professional Visualizations
- **BOIN Flowchart** - Step-by-step decision process
- **Decision Table Heatmap** - Color-coded reference guide (E/S/D/DE)
- **OC Bar Charts** - Patient allocation across scenarios

### 🔧 Built on Best Practices
- Uses the BOIN R package (FDA fit-for-purpose designated)
- Follows canonical validation fixtures
- Includes comprehensive documentation of implementation details

---

## 📋 Prerequisites

### Software Requirements
- **R** (version 4.0+)
  - Install from: https://cran.r-project.org/
- **BOIN R package**
  ```r
  install.packages("BOIN")
  ```

### File Structure
```
Project2/
├── README.md                    # This file
├── SKILL.md                     # Complete skill specification
├── .cursor/rules/boin-basic/
│   └── RULE.md                  # AI assistant rules
├── scripts/
│   ├── validate.R               # Validation against fixtures
│   └── generate_outputs.R       # Main design generation script
├── expected/                    # Canonical validation fixtures
├── templates/
│   └── mini_protocol.md         # Protocol template
└── outputs/                     # Generated files (created automatically)
```

---

## 🚀 Getting Started

### Step 1: Start with Validation (Recommended First Time)

This verifies your R environment and BOIN package installation:

**Prompt to AI Assistant:**
```
Read the project BOIN rule and SKILL.md, then run Rscript scripts/validate.R and stop if anything differs from expected.
```

**What this does:**
- Reads project rules and specifications
- Runs validation script to ensure reproducibility
- Compares outputs against canonical fixtures
- Confirms your environment is correctly configured

**Expected output:** ✅ All validations pass

---

### Step 2: Design a New Trial (Main Workflow)

Once validated, start a new design consultation:

**Prompt to AI Assistant:**
```
I would like to design a new Phase 1 study using the BOIN method.
```

or more specifically:

```
I need to design a Phase 1 single-agent dose-escalation study using BOIN. 
Let's discuss the design parameters.
```

**What happens next:**
The AI assistant will guide you through a consultation session, asking about:

1. **Target DLT rate** - Your acceptable toxicity level (e.g., 20%, 30%, 33%)
2. **Dose levels** - Actual doses to test (e.g., 50mg, 100mg, 150mg, 250mg)
3. **Starting dose** - Which dose to begin with
4. **Cohort size** - Patients per cohort (typically 3-5)
5. **Maximum cohorts** - Total number of cohorts (determines max N)
6. **DLT definition** - What constitutes a dose-limiting toxicity
7. **DLT window** - Assessment period (e.g., first 28 days, first cycle)
8. **Safety preferences** - Dose skipping, early stopping rules
9. **Early stopping** - Whether to stop if a dose appears stable (n.earlystop parameter)

---

## 📊 Example Session

### Complete Workflow Example

```
USER: I would like to design a new Phase 1 study using the BOIN method.

ASSISTANT: I'll help you design a Phase 1 BOIN trial. Let me gather the necessary parameters...

[Assistant asks clarifying questions]

USER: Target DLT rate is 30%, dose levels are 50mg, 100mg, 150mg, 250mg, 
      cohort size is 5, maximum cohorts are 10, starting at 50mg, 
      DLT definition is Grade 3+ non-hematologic toxicities in first 28 days, 
      and early stopping N=10 patients if a dose is stable.

ASSISTANT: [Generates complete design with all outputs]
```

### Generated Outputs

After the design is complete, you'll have:

```
outputs/
├── boundary_full.csv               # Full decision table (source of truth)
├── boundary_full.md                # Human-readable decision table
├── boundary_tab.csv                # Simplified table (cohort multiples)
├── boundary_tab.md                 # Human-readable simplified table
├── boin_flowchart.png              # BOIN decision flowchart
├── boin_decision_heatmap.png       # Decision table heatmap 🎨
├── oc_all_scenarios.csv            # Operating characteristics (all scenarios)
├── oc_all_scenarios.md             # Human-readable OCs
├── oc_plot_*.png                   # OC visualization plots (per scenario)
└── mini_protocol.md                # Complete protocol document
```

---

## 🎨 Understanding the Visualizations

### 1. BOIN Decision Flowchart
**File:** `boin_flowchart.png`

Shows the step-by-step decision process:
- Start → Treat patients → Check max N → Compute DLT rate
- Compare to boundaries (λₑ, λd) → Escalate/Stay/De-escalate

### 2. Decision Table Heatmap
**File:** `boin_decision_heatmap.png`

Color-coded reference guide:
- **X-axis:** Number of evaluable patients treated at current dose
- **Y-axis:** Number of patients with DLT
- **Colors:** 
  - Light gray (E) = Escalate
  - Medium gray (S) = Stay
  - Dark gray (D) = De-escalate
  - Darkest gray (DE) = De-escalate and Eliminate

**Use cases:**
- Quick reference during trial conduct
- Training clinical staff
- Regulatory submissions
- Protocol presentations

### 3. Operating Characteristics Plots
**Files:** `oc_plot_*.png` (one per scenario)

Bar charts showing:
- Patient allocation across dose levels
- Distribution of toxicities
- Performance under different true DLT rate scenarios

---

## 📖 Using the Generated Outputs

### For Protocol Writing
- Copy relevant sections from `outputs/mini_protocol.md`
- Include `boin_flowchart.png` and `boin_decision_heatmap.png`
- Reference the OC tables for expected performance

### For Trial Conduct
- Use `boundary_full.csv` as the **source of truth**
- Print `boin_decision_heatmap.png` for clinical team reference
- Follow decision table for dose escalation/de-escalation

### For Run-Time Decisions
During trial conduct, provide current data to the AI assistant:

**Prompt:**
```
We are currently at Dose 2 (100mg). We have treated 7 evaluable patients 
at this dose, and 2 have experienced DLTs. What should we do next?
```

The assistant will consult the decision table and provide:
- Recommendation (Escalate/Stay/De-escalate/Eliminate)
- Rationale based on boundary table
- Safety checks (elimination rule, stopping criteria)

---

## 🔧 Advanced Usage

### Modifying Design Parameters

To regenerate outputs with different parameters, update `scripts/generate_outputs.R`:

```r
# Key parameters to modify:
target <- 0.30           # Target DLT rate (e.g., 0.20, 0.25, 0.30, 0.33)
dose_levels <- c("50mg", "100mg", "150mg", "250mg")
cohortsize <- 5          # Patients per cohort
ncohort <- 10            # Maximum number of cohorts
n_earlystop <- 10        # Early stopping threshold
```

Then run:
```bash
Rscript scripts/generate_outputs.R
```

### Custom Scenarios

Add custom OC scenarios in `scripts/generate_outputs.R`:

```r
scenarios <- list(
  list(name = "Custom scenario", p_true = c(0.10, 0.20, 0.30, 0.40)),
  # ... add more scenarios
)
```

---

## 📚 Key Concepts

### BOIN Design Parameters

| Parameter | Description | Typical Values |
|-----------|-------------|----------------|
| **φ (target DLT rate)** | Desired toxicity at MTD | 20%, 25%, 30%, 33% |
| **λₑ (escalation boundary)** | Escalate if DLT rate ≤ λₑ | 0.6 × φ |
| **λd (de-escalation boundary)** | De-escalate if DLT rate > λd | 1.4 × φ |
| **Cohort size** | Patients per cohort | 3-5 |
| **n.earlystop** | Early stopping threshold | 10 (default) |
| **cutoff.eli** | Elimination probability | 0.95 |

### Decision Rules

1. **Escalate:** If observed DLT rate ≤ λₑ
2. **Stay:** If λₑ < observed DLT rate ≤ λd
3. **De-escalate:** If observed DLT rate > λd
4. **Eliminate:** If Pr(p > φ | data) > 0.95 and n ≥ 3

### Stopping Criteria

The trial stops when:
1. **Maximum sample size reached** (N = cohortsize × ncohort)
2. **Safety:** Lowest dose eliminated (all doses too toxic)
3. **Efficiency:** n.earlystop patients treated at single dose with "stay" decision

---

## 🔍 Quality Assurance

### Validation Fixtures

The package includes canonical validation fixtures in `expected/`:
- `expected/boundary_full.csv` - Known-good decision table
- `expected/oc_baseline.csv` - Known-good OC summary

Run validation to ensure reproducibility:
```bash
Rscript scripts/validate.R
```

### Documentation

- **`SKILL.md`** - Complete specification of the assistant's capabilities
- **`outputs/VISUALIZATION_GUIDE.md`** - Detailed visualization documentation
- **`outputs/HEATMAP_VISUALIZATION_GUIDE.md`** - Heatmap implementation details
- **`outputs/LESSONS_LEARNED.md`** - Common pitfalls and solutions

---

## 🤝 Best Practices

### Before Starting a Design
1. ✅ Run validation to confirm environment setup
2. ✅ Review `SKILL.md` for design parameters and options
3. ✅ Gather clinical input (target DLT rate, dose levels, DLT definition)

### During Design Consultation
1. ✅ Provide clear DLT definition with clinical context
2. ✅ Discuss early stopping preferences with clinical team
3. ✅ Review operating characteristics for multiple scenarios
4. ✅ Ensure dose levels are clinically meaningful and ordered

### After Design Generation
1. ✅ Review `outputs/mini_protocol.md` for completeness
2. ✅ Check decision table makes clinical sense
3. ✅ Review OC scenarios - add custom scenarios if needed
4. ✅ Share visualizations with clinical team for feedback

---

## 📖 References

### BOIN Method
- **Yuan Y, Hess KR, Hilsenbeck SG, Gilbert MR.** (2016). Bayesian optimal interval design: A simple and well-performing design for phase I oncology trials. *Clinical Cancer Research*, 22(17), 4291-4301.

- **Liu S, Yuan Y.** (2015). Bayesian optimal interval designs for phase I clinical trials. *Journal of the Royal Statistical Society: Series C*, 64(3), 507-523.

### BOIN Software
- **BOIN R Package:** Available on CRAN - https://cran.r-project.org/package=BOIN
- **BOIN Web Tool:** http://www.trialdesign.org

### FDA Designation
- **U.S. FDA Fit-for-Purpose Initiative** - BOIN design received fit-for-purpose designation for drug development (2021)

---

## 🆘 Troubleshooting

### Common Issues

**Issue:** `Rscript` not found / not recognized
- **Root Cause:** R is not in system PATH
- **Quick Fix (Windows):**
  1. Test if R is accessible: `Rscript --version`
  2. If fails, locate your R installation (usually `C:\Program Files\R\R-4.4.1\`)
  3. Use full path with PowerShell call operator:
     ```powershell
     & "C:\Program Files\R\R-4.4.1\bin\Rscript.exe" scripts/validate.R
     ```
- **Permanent Fix (Windows):**
  1. Add R to system PATH:
     - Search "Environment Variables" in Windows
     - Edit "Path" under System Variables
     - Add: `C:\Program Files\R\R-4.4.1\bin\`
     - Restart terminal
  2. Verify: `Rscript --version`
- **macOS/Linux:** Check `/usr/local/bin/Rscript` or install via package manager

**Issue:** BOIN package not found
- **Solution:** Install the package in R:
  ```r
  install.packages("BOIN")
  ```
- **Verify installation:**
  ```r
  library(BOIN)
  packageVersion("BOIN")
  ```

**Issue:** Validation differences detected
- **Solution:** Check R version and BOIN package version. Seeds should ensure reproducibility, but package updates may affect results.
- **Action:** Update `expected/` fixtures if using a newer BOIN version

**Issue:** Decision table missing row names in CSV
- **Solution:** Ensure `row.names = TRUE` in `write.csv()` calls (already fixed in current version)

**Issue:** PowerShell script execution errors
- **Solution:** If you see "Unexpected token" errors, ensure you're using the `&` call operator for paths with spaces:
  ```powershell
  # ❌ Wrong
  "C:\Program Files\R\R-4.4.1\bin\Rscript.exe" scripts/validate.R
  
  # ✅ Correct
  & "C:\Program Files\R\R-4.4.1\bin\Rscript.exe" scripts/validate.R
  ```

---

## 🎯 Quick Reference: Common Prompts

### Validation
```
Read the project BOIN rule and SKILL.md, then run Rscript scripts/validate.R 
and stop if anything differs from expected.
```

### New Design (Interactive)
```
I would like to design a new Phase 1 study using the BOIN method.
```

### New Design (With Parameters)
```
Design a Phase 1 BOIN trial with target DLT 30%, 4 dose levels (50mg, 100mg, 
150mg, 250mg), cohort size 5, max 10 cohorts, starting at 50mg, DLT defined 
as Grade 3+ non-hematologic toxicity in first 28 days.
```

### Run-Time Decision
```
We are at Dose 2 with 5 evaluable patients and 2 DLTs. What dose should we 
use for the next cohort?
```

### Regenerate Outputs
```
Please regenerate all outputs using the current parameters in 
scripts/generate_outputs.R.
```

### Update Parameters
```
Please update the maximum number of cohorts to 8 and regenerate all outputs.
```

---

## 📞 Support

For questions about:
- **BOIN method** → See references above or http://www.trialdesign.org
- **This package** → Review `SKILL.md` for complete specifications
- **Implementation details** → See documentation in `outputs/` folder

---

## 📄 License

This package uses the BOIN R package, which is available under GPL-2 license.

---

## 🎓 Learning Resources

### For Biostatisticians
- Read the original BOIN papers (Yuan et al., 2016)
- Explore `SKILL.md` for implementation details
- Review `outputs/LESSONS_LEARNED.md` for common pitfalls

### For Clinicians
- Review `outputs/mini_protocol.md` for example protocols
- Use `boin_decision_heatmap.png` as a quick reference guide
- Understand the three stopping criteria (max N, safety, efficiency)

### For Regulators
- BOIN has FDA fit-for-purpose designation
- Review operating characteristics across multiple scenarios
- Decision tables are pre-specified before trial start

---

**Ready to get started?** 🚀

Begin with asking your AI agent to
```
Read the project BOIN rule and SKILL.md, then run Rscript scripts/validate.R 
and stop if anything differs from expected.
```

Then design your first trial:
```
I would like to design a new Phase 1 study using the BOIN method.
```


