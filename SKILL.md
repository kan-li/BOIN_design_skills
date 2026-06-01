---
name: boin-basic
description: Design single-agent BOIN Phase I dose-finding trials and provide run-time dose decision support during trial conduct. Use this skill whenever a user mentions BOIN, Phase I oncology, MTD identification, dose escalation or de-escalation, dose-limiting toxicity (DLT), cohort dose decisions, operating characteristics, decision tables, or protocol writing for a dose-finding study. Also use this skill when someone asks "what dose should we give next?" or similar during an ongoing trial. Even if the user does not explicitly say "BOIN", use this skill whenever the context involves a Phase I oncology dose-finding design with a target toxicity rate.
---

# BOIN Basic — Single-Agent Phase I Dose-Finding Skill

A skill for designing Bayesian Optimal Interval (BOIN) Phase I trials and providing real-time dose decision support during trial conduct.

**Primary users:** Clinicians and statisticians collaborating on a Phase I oncology dose-escalation study.  
**Core deliverable:** A design packet (mini-protocol) with machine-readable decision tables, visualizations, and operating characteristics — plus a run-time "what dose next?" assistant.

---

## Scope

This skill covers **only** the basic **single-agent** BOIN design for identifying the MTD based on a **target DLT rate**.

Out of scope — refuse or redirect:
- BOIN extensions (TITE-BOIN, BOIN-ET, BOIN12), efficacy/utility designs, Phase I/II joint models
- Drug-combination BOIN or waterfall designs
- Non-monotone dose–toxicity modeling (the skill may note assumptions but does not re-design BOIN)

---

## Environment Prerequisites

Before running any R code, verify R is accessible:

1. Try `Rscript --version` in the terminal.
2. **Windows — if not in PATH:** check `C:\Program Files\R\R-4.*.*\bin\Rscript.exe` and use the full path with the shell call operator: `& "C:\Program Files\R\R-4.4.x\bin\Rscript.exe" scripts/validate.R`
3. **macOS/Linux — if not found:** check `/usr/local/bin/Rscript` or `/usr/bin/Rscript`.
4. If R is absent, ask the user to install R (https://cran.r-project.org/) and run `install.packages("BOIN")`.

Never assume Rscript is in PATH without checking. Never proceed if R environment validation fails.

---

## Two Modes of Operation

### Mode A — Design-Time Consulting

**Goal:** Create the full BOIN design packet.

#### Step 1 — Present the intake checklist

At the start of a design consultation, present this checklist to the clinical team:

> **What we need from you:**
> 1. DLT definition and assessment window (e.g., Grade ≥3 non-hematologic toxicity in Cycle 1).
> 2. Target DLT rate φ (e.g., 0.30).
> 3. Number of dose levels, dose labels, and ordering (Dose 1 < Dose 2 < …).
> 4. Starting dose (default: Dose 1).
> 5. Cohort size and maximum number of cohorts (max N = cohort size × n cohorts).
> 6. Dose skipping policy (default recommendation: no skipping).
> 7. Early stopping preference (`n.earlystop`, default = 10): trial stops early if this many patients have been treated at one dose with a "stay" decision. Set to a large value (e.g., 100) to always use the full sample size.
> 8. 2–3 plausible toxicity scenarios for simulation — or permission to propose them.
>
> *Note: `p.true` scenarios are used only to simulate operating characteristics in `get.oc()`; true toxicity probabilities are unknown in practice.*

Ask only for missing items. Do not over-interrogate if the user has already provided information.

#### Step 2 — Generate outputs

After collecting parameters, generate and save:

| File | Description |
|------|-------------|
| `outputs/boundary_full.csv` | Full decision table — **source of truth** for trial conduct |
| `outputs/boundary_full.md` | Human-readable version of the full table |
| `outputs/boundary_tab.csv` | Simplified table for cohort-size multiples |
| `outputs/boundary_tab.md` | Human-readable simplified table |
| `outputs/boin_flowchart.png` | Flowchart from `plot(get.boundary())` |
| `outputs/boin_decision_heatmap.png` | Color-coded E/S/D/DE heatmap (custom, not from BOIN package) |
| `outputs/oc_all_scenarios.csv` | Tidy OC summary for all scenarios |
| `outputs/oc_plot_*.png` | Bar charts from `plot(get.oc())`, one per scenario |
| `outputs/mini_protocol.md` | Protocol document with tables, figures, and interpretation |
| `outputs/generate_custom_design.R` | **Complete R script** with all parameters — audit trail |

**Critical:** Always save `outputs/generate_custom_design.R` with all design parameters explicitly documented. This file serves as the regulatory audit trail and must never be deleted.

#### Step 3 — Fill the protocol document

Populate `outputs/mini_protocol.md` using `templates/mini_protocol.md`, embedding:
- The Markdown decision table
- A clinician explanation of how to use the table
- Interpretation of simulation results (conditional on the scenarios)

---

### Mode B — Run-Time Dose Decision Support

**Goal:** Given current trial data, recommend the next action.

#### Algorithm (must be deterministic)

1. Confirm: current dose level, cumulative patients treated (*n*), cumulative DLTs (*m*), and that patients are evaluable under the DLT window.
2. Load `outputs/boundary_full.csv` as the source of truth. Find the column for *n* and read the boundaries.
3. Return one clear recommendation: **Escalate / Stay / De-escalate / Eliminate+Stop**.
4. Provide a short justification referencing the exact table row used.
5. Remind the user to check the elimination rule: if the lowest dose is eliminated, the trial terminates.
6. If the decision table cannot be found or extracted with confidence, **stop and ask** for it — or for permission to regenerate from the locked parameters.

---

## Computation Contract

Use only these BOIN functions:

- `get.boundary(target, ncohort, cohortsize, ...)` — generates escalation/de-escalation boundaries and elimination boundary; returns `$boundary_tab` and `$full_boundary_tab`.
- `get.oc(target, p.true, ncohort, cohortsize, ..., ntrial, seed)` — simulates operating characteristics.
- `select.mtd(target, npts, ntox, ...)` — optional, for end-of-trial MTD selection.

Default parameters are acceptable unless the user requests changes. Key defaults:
- `p.saf = 0.6 × target`
- `p.tox = 1.4 × target`
- `cutoff.eli = 0.95`
- `n.earlystop = 10`

Never silently change defaults — state any changes explicitly.

---

## Implementation Notes (Critical)

### Boundary table structure

`get.boundary()` returns `$full_boundary_tab` — a **matrix with row names**, not a data frame. Row names are:
- "Number of patients treated"
- "Escalate if # of DLT <="
- "Deescalate if # of DLT >="
- "Eliminate if # of DLT >="

Always use `row.names = TRUE` in `write.csv()`. Dropping row names makes the table uninterpretable.

### Visualizations

- `plot(get.boundary())` → flowchart showing decision process with λₑ and λd.
- `plot(get.oc())` → bar chart of observed toxicity distribution.
- **Heatmap**: custom base-R visualization showing E/S/D/DE decisions by (n, m). The BOIN package does *not* provide this natively — see `scripts/generate_outputs.R` for the reference implementation.
- Save all PNGs at 800–1200px wide, 600–1000px tall, 120 dpi.

### OC table construction

The OC table is built per-dose and then appended with a totals row. Before `rbind()`, ensure both data frames have identical columns (add NA columns to dose rows for trial-level metrics like `percentstop`, `overdose60`, `overdose80`).

### Code generation

- Always reference `scripts/generate_outputs.R` as the canonical implementation.
- When generating a custom design, save the complete script as `outputs/generate_custom_design.R` with all parameters explicitly set and the date/purpose documented.

### Common pitfalls

1. Writing boundary tables without row names → table becomes uninterpretable.
2. Using `row.names = FALSE` in `write.csv()` for BOIN matrices → loses decision rule labels.
3. Treating `full_boundary_tab` as a data frame → it is a matrix.
4. Mismatched column counts before `rbind()` → add NA columns first.

---

## Safety and Governance Rules

- Never recommend dose skipping unless the protocol explicitly allows it.
- Never invent a decision table — read from CSV or regenerate from explicit, locked parameters.
- If a protocol's table disagrees with the repo table, flag the discrepancy and ask which is authoritative before making any dosing recommendation.
- Never delete `outputs/generate_custom_design.R` — it is the regulatory audit trail.
- Do not propose BOIN extensions, combination designs, or efficacy/utility endpoints.

---

## Glossary (inject definitions in clinician conversations)

When a clinician uses or asks about any of these terms, add a short footnote-style definition:

| Term | Definition |
|------|-----------|
| **DLT** | Dose-limiting toxicity — defined per protocol. |
| **DLT window** | Time window for counting DLTs (typically Cycle 1). |
| **Target DLT rate (φ)** | The toxicity rate the design aims for at the MTD. |
| **Cohort size** | Number of patients treated before a dose decision. |
| **Number of cohorts (ncohort)** | Maximum cohorts; with cohort size determines max N. |
| **Dose skipping** | Whether escalation can jump over doses. |
| **Decision table / boundaries** | Precomputed rules for escalation/de-escalation. |
| **Elimination rule** | Bayesian safety rule that removes overly toxic doses. |
| **Early stopping (efficiency rule)** | Trial may end before max N if stable results at one dose (controlled by `n.earlystop`). |
| **Operating characteristics (OCs)** | Simulation-based summaries of expected design behavior. |
| **`p.true` scenarios** | Hypothetical "true" toxicity rates for OC simulation — not known in practice. |

---

## Canonical Validation Fixture

Used to verify installation, defaults, and reproducibility on a new machine or environment.

**Parameters:**
- 6 dose levels
- Target DLT φ = 0.30
- Cohort size = 3
- Total cohorts = 10 (max N = 30)
- Baseline `p.true` = (0.05, 0.15, 0.30, 0.35, 0.45, 0.60)
- `ntrial = 1000`, `seed = 6`
- `n.earlystop = 100` (disabled for fixture)

Run `scripts/validate.R` and compare against `expected/`. If outputs differ, stop and report what differs (parameters, package version, seed, defaults). Do not proceed with a new design until the environment is validated.

---

## Repository Layout

```
project/
├── SKILL.md                          # This file — skill specification
├── README.md                         # Getting started guide
├── templates/
│   └── mini_protocol.md              # Protocol document template
├── scripts/
│   ├── generate_outputs.R            # Reference implementation
│   └── validate.R                    # Canonical fixture validation
├── expected/                         # Golden outputs for fixture comparison
│   ├── boundary_full.csv
│   └── oc_baseline.csv
└── outputs/                          # Generated files (created at runtime)
    ├── boundary_full.csv             # Source of truth for trial conduct
    ├── boundary_full.md
    ├── boundary_tab.csv
    ├── boundary_tab.md
    ├── boin_flowchart.png
    ├── boin_decision_heatmap.png
    ├── oc_all_scenarios.csv
    ├── oc_plot_*.png
    ├── mini_protocol.md
    └── generate_custom_design.R      # Audit trail — never delete
```
