# BOIN Basic — Phase I Dose-Finding Skill

An AI skill that helps biostatisticians and clinical trialists design Phase I dose-finding studies using the BOIN method (Yuan et al., 2016) and provide real-time dose decision support during trial conduct.

Works with any AI coding assistant that supports skills or rules: **Claude Code, Cursor, Codex**, or similar.

---

## What This Skill Does

| Mode | When to use | What you get |
|------|------------|--------------|
| **Design-time (Mode A)** | Starting a new Phase I study | Decision tables, OC simulations, flowcharts, protocol document, audit-trail R script |
| **Run-time (Mode B)** | During trial conduct | Escalate / Stay / De-escalate / Eliminate recommendation with table-based justification |

---

## Prerequisites

- **R** (version 4.0+) — https://cran.r-project.org/
- **BOIN R package**

```r
install.packages("BOIN")
```

---

## Getting Started

### Step 1 — Validate your environment (recommended first time)

This confirms R and the BOIN package are working correctly and that outputs match the canonical fixture.

```
Read SKILL.md, then run scripts/validate.R and stop if anything differs from expected/.
```

Expected result: `VALIDATION PASSED`

### Step 2 — Design a new trial

```
I would like to design a new Phase I study using the BOIN method.
```

The AI will guide you through a consultation collecting:

1. Target DLT rate φ (e.g., 0.30)
2. Dose levels, labels, and ordering
3. Starting dose
4. Cohort size and maximum number of cohorts (max N)
5. DLT definition and assessment window
6. Dose skipping policy
7. Early stopping preference (`n.earlystop`)
8. 2–3 simulation scenarios (or permission to propose them)

### Step 3 — Run-time dose decisions

During the trial, ask:

```
We are at Dose 2 (100mg). We have treated 7 evaluable patients at this dose 
and 2 have experienced DLTs. What should we do next?
```

The AI looks up the decision in `outputs/boundary_full.csv` and returns a single recommendation with justification.

---

## Generated Outputs

After a design is complete:

```
outputs/
├── boundary_full.csv           # Full decision table — source of truth for trial conduct
├── boundary_full.md            # Human-readable full table
├── boundary_tab.csv            # Simplified table (cohort-size multiples)
├── boundary_tab.md
├── boin_flowchart.png          # Decision flowchart
├── boin_decision_heatmap.png   # Color-coded E/S/D/DE reference guide
├── oc_all_scenarios.csv        # Operating characteristics (all scenarios)
├── oc_plot_*.png               # OC bar charts per scenario
├── mini_protocol.md            # Protocol document ready for editing
└── generate_custom_design.R    # Complete R script — audit trail, do not delete
```

---

## Understanding the Visualizations

### Decision flowchart (`boin_flowchart.png`)
Step-by-step decision process showing escalation boundary λₑ and de-escalation boundary λd.

### Decision table heatmap (`boin_decision_heatmap.png`)
Color-coded grid: X-axis = patients treated at current dose, Y-axis = DLTs observed.
- **E** (light) = Escalate
- **S** (medium) = Stay
- **D** (dark) = De-escalate
- **DE** (darkest) = De-escalate and Eliminate

Print this for the clinical team as a bedside reference during trial conduct.

### OC plots (`oc_plot_*.png`)
Bar charts of patient allocation and DLT distribution across dose levels under each simulation scenario.

---

## Key Design Parameters

| Parameter | Description | Typical values |
|-----------|-------------|----------------|
| φ (target DLT rate) | Toxicity rate the design targets at the MTD | 0.20, 0.25, 0.30, 0.33 |
| λₑ (escalation boundary) | Escalate if observed DLT rate ≤ λₑ | ~0.6 × φ |
| λd (de-escalation boundary) | De-escalate if observed DLT rate > λd | ~1.4 × φ |
| Cohort size | Patients per cohort | 3–5 |
| `n.earlystop` | Early stopping threshold (patients at one stable dose) | 10 (default) |
| `cutoff.eli` | Bayesian elimination probability threshold | 0.95 |

---

## Repository Structure

```
project/
├── SKILL.md                    # Full skill specification (start here)
├── README.md                   # This file
├── templates/
│   └── mini_protocol.md        # Protocol document template
├── scripts/
│   ├── generate_outputs.R      # Reference implementation
│   └── validate.R              # Canonical fixture validation
├── expected/                   # Golden outputs for validation
└── outputs/                    # Generated at runtime
```

---

## Common Prompts

**Validate environment:**
```
Read SKILL.md, then run scripts/validate.R and stop if anything differs from expected/.
```

**New design (interactive):**
```
I would like to design a new Phase I study using the BOIN method.
```

**New design (with parameters):**
```
Design a Phase I BOIN trial: target DLT 30%, 4 dose levels (50mg, 100mg, 150mg, 250mg), 
cohort size 3, max 10 cohorts, starting at 50mg, DLT = Grade 3+ non-hematologic 
toxicity in Cycle 1.
```

**Run-time decision:**
```
We are at Dose 3 with 6 evaluable patients and 3 DLTs. What dose should 
we use for the next cohort?
```

**Regenerate outputs:**
```
Regenerate all outputs using the parameters in scripts/generate_outputs.R.
```

---

## Troubleshooting

**`Rscript` not found**

Test: `Rscript --version`

Windows — if not in PATH, use the full path:
```powershell
& "C:\Program Files\R\R-4.4.x\bin\Rscript.exe" scripts/validate.R
```

To add R to PATH permanently on Windows: System Properties → Environment Variables → Edit "Path" → Add `C:\Program Files\R\R-4.4.x\bin\`

**BOIN package not found**
```r
install.packages("BOIN")
library(BOIN)
packageVersion("BOIN")
```

**Validation mismatch**  
Check R and BOIN package versions. If using a newer BOIN version, update `expected/` after confirming the new outputs are correct.

**Decision table missing row names**  
Ensure `write.csv(..., row.names = TRUE)` — this is already correct in `scripts/generate_outputs.R`.

---

## References

- Yuan Y, Hess KR, Hilsenbeck SG, Gilbert MR. (2016). Bayesian optimal interval design: a simple and well-performing design for phase I oncology trials. *Clinical Cancer Research*, 22(17), 4291–4301.
- Liu S, Yuan Y. (2015). Bayesian optimal interval designs for phase I clinical trials. *JRSS-C*, 64(3), 507–523.
- BOIN R package: https://cran.r-project.org/package=BOIN
- BOIN web tool: http://www.trialdesign.org
- U.S. FDA Fit-for-Purpose designation (2021): https://www.fda.gov/about-fda/oncology-center-excellence/project-fda

---

## Demo

https://drive.google.com/file/d/1_NrBAgfitFNB-lxZ78FbaGfs8lDi7YZ1/view?usp=sharing

## Community

Catalyst Circle: https://catalyst-pharma.circle.so/c/public/
