## 0) Skill identity
**Skill name:** BOIN Basic (Single-Agent Phase I Dose-Finding)   
**Primary users:** Clinicians + statisticians collaborating on an oncology-like Phase I dose escalation.  
**Core deliverable:** A design packet (mini-protocol) + machine-readable decision table, and a run-time “what dose next?” assistant.

## 1) Scope (hard constraints)
This skill covers **only** the basic **single-agent** BOIN design for identifying an MTD based on a **target DLT rate**. 

Out of scope (must refuse or redirect):
- Any BOIN extensions (e.g., TITE-BOIN, BOIN-ET, BOIN12), efficacy/utility designs, Phase I/II joint models.
- Drug-combination BOIN/waterfall designs.
- Non-monotone dose–toxicity modeling debates (the skill can note assumptions but does not re-design BOIN). 

## 2) Why BOIN is operationally simple (what the agent must explain)
BOIN trial conduct is driven by **precomputed escalation and de-escalation boundaries**: after each cohort, compare the observed DLT rate at the current dose to the escalation and de-escalation boundaries to decide escalate / de-escalate / stay.   
BOIN also provides an **elimination boundary** using a Bayesian safety rule to avoid overly toxic doses, and the trial is terminated if the lowest dose is eliminated. 

## 3) Two modes of operation (the skill must support both)

### Mode A — Design-time consulting
Goal: create the BOIN design packet and simulation-based operating characteristics.

**Inputs (must collect or confirm):**
- DLT definition and assessment window (Cycle 1, etc.).
- Target DLT rate \(\phi\) (e.g., 0.30). 
- Number of dose levels, dose labels, and dose ordering (Dose 1 < Dose 2 < …).
- Starting dose (default typically Dose 1 unless specified). 
- Cohort size and total number of cohorts (max N = cohortsize × ncohort). 
- Dose skipping allowed? (default recommendation: no skipping unless prespecified).
- Safety and efficiency preferences:
  - `cutoff.eli` for elimination (default recommended 0.95). 
  - `extrasafe` and `offset` if a stricter stopping rule is desired.
  - `n.earlystop` for early termination (default recommended 10): if this many patients are treated at a single dose and the decision is to "stay", the trial stops early and selects that dose as MTD. Set to a large value (e.g., 100) to effectively disable early stopping and always use full sample size.
- Simulation plan:
  - Number of simulated trials `ntrial` and RNG seed `seed` for reproducibility. 
  - 2–3 plausible dose–toxicity **scenarios** for stress-testing (see `p.true` note below). 

**Outputs (must produce):**
- `outputs/boundary_full.csv` (machine-readable "source of truth" decision table).
- `outputs/boundary_full.md` (human-readable decision table).
- `outputs/boundary_tab.csv` (simplified table for cohort-size multiples).
- `outputs/boin_flowchart.png` (flowchart visualization from `plot(get.boundary())`).
- `outputs/boin_decision_heatmap.png` (heatmap-style decision table visualization).
- `outputs/oc_all_scenarios.csv` (tidy OC summary for all scenarios).
- `outputs/oc_plot_*.png` (bar charts showing observed toxicity distribution from `plot(get.oc())`).
- `outputs/mini_protocol.md` (protocol document with tables, figures, and interpretation).
- `outputs/generate_custom_design.R` (R script with exact parameters used to generate all outputs for reproducibility and audit trail).

### Mode B — Run-time dose decision support (“what dose next?”)
Goal: given current dose data during the trial, recommend the next action.

**Inputs (must collect):**
- The governing decision table (prefer `outputs/boundary_full.csv`; alternatively extract table from protocol).
- Current dose level.
- At the current dose: cumulative number treated \(n\) and cumulative DLTs \(m\).
- Confirmation that the patients are evaluable under the DLT window.

**Outputs (must produce):**
- A single recommendation: **Escalate / Stay / De-escalate / Eliminate+Stop** (as applicable).
- A short justification referencing the exact table row/column used.
- A safety note reminding the user to check elimination/stopping language.

## 4) Canonical validation fixture (for new machines / new Cursor instances)
This repo includes a “smoke test” scenario to validate installation, defaults, and reproducibility.

**Canonical scenario (fixture):**
- 6 doses
- Target DLT \(\phi = 0.30\)
- Cohort size = 3
- Total cohorts = 10 (max N = 30)
- Baseline simulation scenario `p.true` = (0.05, 0.15, 0.30, 0.35, 0.45, 0.60) 

**What this fixture is (must explain if asked):**
`p.true` is *not known in reality*; it is a hypothetical “true toxicity probability” vector used to simulate operating characteristics in `get.oc()`.   
BOIN’s `get.oc()` defines `p.true` as “a vector containing the true toxicity probabilities” and uses it to simulate trials to obtain operating characteristics. 

## 5) Glossary injection rules (mandatory in clinician conversations)
Whenever the clinician uses or asks about any of the following terms, the agent must add a short footnote-style definition and why it matters:

- **DLT**: Dose-limiting toxicity (define per protocol).
- **DLT window**: Time window for counting DLTs.
- **Target DLT rate (\(\phi\))**: The toxicity rate the design aims for at the MTD. 
- **Cohort size**: Number of patients treated before a dose decision. 
- **Number of cohorts (ncohort)**: Maximum cohorts; with cohort size determines max N. 
- **Dose skipping**: Whether escalation can jump doses.
- **Decision table / boundaries**: The precomputed rules used for escalation/de-escalation. 
- **Elimination rule**: Bayesian safety mechanism that can eliminate doses. 
- **Early stopping (efficiency rule)**: Trial may stop before max N if sufficient patients treated at one dose with stable results (controlled by `n.earlystop`).
- **Operating characteristics (OCs)**: Simulation-based summaries of expected behavior. 
- **`p.true` scenarios**: "What-if" assumptions for OC simulation, not known truth. 

## 6) Required “What we need from you” script (must appear in Mode A)
The agent must present this checklist early in the consult:

**What information we need from you (clinical team)**
1) DLT definition & assessment window.  
2) Target DLT rate \(\phi\).   
3) Dose levels, ordering, and starting dose.   
4) Cohort size and maximum cohorts / max N.   
5) Dose skipping policy.  
6) Early stopping preference: Should the trial stop early if many patients are treated at a single dose with stable results? (Parameter: `n.earlystop`, default = 10. Set higher to use full sample size.)
7) 2–3 plausible toxicity scenarios for simulation (or permission for the statistician/agent to propose scenarios).   

Footnote (must include): `p.true` scenarios are used only for simulation of operating characteristics in BOIN's `get.oc()`; true toxicity probabilities are unknown in real life. 

## 7) Computation contract (what the agent is allowed to do)
In this basic single-agent scope, the agent should rely on these BOIN functions:

- `get.boundary(target, ncohort, cohortsize, ...)` to generate escalation/de-escalation boundaries and the decision tables `$boundary_tab` and `$full_boundary_tab`, and the elimination boundary.   
- `get.oc(target, p.true, ncohort, cohortsize, ..., ntrial, seed)` to simulate operating characteristics under prespecified scenarios.   
- Optional (end-of-trial illustration): `select.mtd(target, npts, ntox, ...)`, which selects the MTD using isotonic estimates closest to target. 

Default parameters are acceptable unless the clinician/statistician requests changes; key defaults include `p.saf = 0.6*target`, `p.tox = 1.4*target`, and `cutoff.eli = 0.95`.

### Critical implementation notes (learned from experience)

**BOIN boundary table structure:**
- `get.boundary()` returns `$boundary_tab` (simplified, for cohort-size multiples) and `$full_boundary_tab` (complete, for n=1 to max N).
- **Both are MATRICES with row names**, not data frames. Row names are:
  - "Number of patients treated"
  - "Escalate if # of DLT <="
  - "Deescalate if # of DLT >="
  - "Eliminate if # of DLT >="
- When writing to CSV, **MUST use `row.names = TRUE`** in `write.csv()` to preserve row labels.
- When converting to markdown, must handle matrix structure and preserve row names.

**BOIN visualization capabilities:**
- `plot(get.boundary())` generates a **flowchart** showing the dose escalation/de-escalation decision process with boundary values (λₑ and λd).
- `plot(get.oc())` generates a **bar chart** showing the distribution of observed toxicities across dose levels.
- **Custom heatmap visualization**: A heatmap-style decision table showing E/S/D/DE decisions based on the number of patients treated and the number of DLTs observed. This is created using base R graphics and mimics the "Alternative BOIN decision table" from the BOIN web tool. The BOIN R package does NOT provide this visualization natively.
- All plots should be saved as PNG files (recommended: 800-1200px width, 600-1000px height, 120 dpi).
- Include these visualizations in the protocol document to improve clinical team understanding.

**Code generation:**
- Always refer to `scripts/generate_outputs.R` as the canonical reference implementation.
- Key utilities needed: `dir_create()`, `write_csv_base()` with `row.names=TRUE`, `df_to_markdown()` that handles matrices.
- The OC generation pattern: build per-dose data frame, add trial-level metrics to totals row, ensure column alignment before `rbind()`.
- **IMPORTANT:** When generating a custom design, save the complete generation script as `outputs/generate_custom_design.R` with all design parameters explicitly specified. This provides full reproducibility and an audit trail for regulatory submissions. Never delete this file after generation.

**Common pitfalls to avoid:**
1. Writing boundary tables without row names → table becomes uninterpretable.
2. Using `row.names = FALSE` in `write.csv()` for BOIN matrices → loses the decision rule labels.
3. Treating `full_boundary_tab` as a data frame → it's a matrix, handle accordingly.
4. Creating data frames with mismatched column counts before `rbind()` → add NA columns first to align structure. 

## 8) Run-time decision algorithm (must be deterministic)
When asked “what do we do next?” the agent must do this:

1) Confirm current dose, \(n\), \(m\), and evaluability.  
2) Use `outputs/boundary_full.csv` as the **source of truth** and find the row matching \(n\) and the column matching \(m\).  
3) Return the action in one line: “Recommendation: Escalate/Stay/De-escalate to Dose X.”  
4) Check elimination/stopping: remind that BOIN’s elimination boundary is based on a Bayesian safety rule and the trial terminates if the lowest dose is eliminated.   
5) If the table cannot be found or extracted with confidence, **stop and ask** for the decision table or for permission to regenerate it from the locked parameters.

## 9) Safety & governance rules
- Never recommend dose skipping unless the protocol explicitly allows it.
- Never "invent" a decision table; must be read from CSV or regenerated from explicit parameters.
- If the clinician provides a protocol whose table disagrees with the repo table, the agent must flag the discrepancy and ask which is authoritative before recommending dosing.
- Always preserve the generation script (`outputs/generate_custom_design.R`) after creating a design; never delete it as it serves as the audit trail and reproducibility documentation for regulatory purposes.

## 10) Repo artifacts (expected file layout)
Minimum recommended repo layout:

- Skill.md
- templates/mini_protocol.md
- outputs/
  - boundary_full.csv
  - boundary_full.md
  - oc_summary.csv
  - mini_protocol.md
  - generate_custom_design.R   (custom design script with exact parameters for reproducibility)
- expected/   (golden outputs for the canonical validation fixture)
- scripts/
  - generate_outputs.R   (optional, reference implementation)
  - validate.R           (optional)
- .cursor/rules/boin-basic/RULE.md

**Note on reproducibility:** The `outputs/generate_custom_design.R` script serves as the definitive record of all design parameters and should be preserved for:
- Reproducibility (re-generate outputs if needed)
- Regulatory audit trail (documents exact BOIN parameters used)
- Protocol amendments (reference for modifications)
- Quality assurance (verifies outputs match specified design)
