These are **project rules** for Cursor to follow inside this repository.

## Always-on behavior
1) Always read and follow `Skill.md` before answering BOIN-related questions.
2) Keep scope strictly to **basic single-agent BOIN** (oncology-like). 
3) Prefer repo artifacts as the source of truth:
   - Use `outputs/boundary_full.csv` for run-time decisions whenever available.
   - Use `templates/mini_protocol.md` for the report structure.

## Environment Setup & Validation (R PATH)
**CRITICAL:** Before running ANY R code (Rscript, validation, or design generation), MUST verify R is accessible:

### For Windows:
1) **First attempt:** Try `Rscript --version` directly
2) **If fails:** Check common R installation paths:
   - `C:\Program Files\R\R-4.*.*/bin\Rscript.exe`
   - `C:\Program Files\R\R-4.4.1\bin\Rscript.exe` (current common version)
3) **If found but not in PATH:** Use full path with PowerShell call operator:
   ```powershell
   & "C:\Program Files\R\R-4.4.1\bin\Rscript.exe" scripts/validate.R
   ```
4) **If not found:** Inform user and provide installation instructions:
   - Download R from https://cran.r-project.org/
   - Install BOIN package: `install.packages("BOIN")`

### For macOS/Linux:
1) **First attempt:** Try `Rscript --version`
2) **If fails:** Check common paths:
   - `/usr/local/bin/Rscript`
   - `/usr/bin/Rscript`
3) **If not found:** Provide installation instructions for the OS

### Never:
- Assume Rscript is in PATH without checking
- Run R commands without verifying they will work
- Proceed if R environment validation fails

### Best Practice:
- On first R-related task in a session, always verify R accessibility
- Document the working R path for the session
- If user repeatedly has PATH issues, suggest adding R to system PATH permanently

## Required conversation structure (Mode A: design-time)
When the user asks to design a trial, do this in order:
1) Present "What information we need from you (clinical team)" exactly as required in `Skill.md`.
2) Ask only for missing required items (don't over-interrogate).
3) Explain that `p.true` is for **simulation scenarios** and not known in reality; propose 2–3 scenarios if the clinician cannot provide them. 
4) Generate/refresh outputs:
   - boundary tables from `get.boundary()` (including `$full_boundary_tab`). 
   - OCs from `get.oc()` using a fixed seed for reproducibility. 
   - **MUST save the generation script as `outputs/generate_custom_design.R`** with all design parameters explicitly documented.
5) Fill `outputs/mini_protocol.md` using the template, embedding:
   - the Markdown decision table
   - a clinician explanation of how to use the table
   - an interpretation of simulation outputs (conditional on scenarios).

### Reproducibility & Audit Trail
**CRITICAL:** Always save the complete R generation script to `outputs/generate_custom_design.R` with:
- All design parameters explicitly specified (target, doses, cohort size, scenarios, seed, etc.)
- Date and purpose documented in comments
- Never delete this file - it serves as the audit trail for regulatory submissions and enables full reproducibility 

## Required run-time behavior (Mode B: “what dose next?”)
When the user asks what to do next in the trial:
1) Ask for (or confirm): current dose, cumulative treated \(n\), cumulative DLTs \(m\), evaluability.
2) Look up the action using `outputs/boundary_full.csv`.
3) Return one clear recommendation (Escalate / Stay / De-escalate / Eliminate+Stop).
4) Include a short justification with the exact table lookup reference.
5) Mention the elimination/stopping rule reminder:
   - elimination boundary is based on BOIN’s Bayesian safety rule; the trial stops if the lowest dose is eliminated. 

## Hard prohibitions
- Do not propose BOIN extensions, combination BOIN, or efficacy/utility designs.
- Do not guess dosing actions from prose if the decision table is missing—ask for the table or regenerate from locked parameters.
- Do not silently change defaults (p.saf, p.tox, cutoff.eli, extrasafe, offset, seed) without stating the change.
- **Never delete `outputs/generate_custom_design.R`** after generating a design - this file is critical for reproducibility and regulatory audit trail. 

## Canonical validation fixture (for new machines)
If asked “validate on a new computer,” run the canonical fixture:
- 6 doses, target=0.30, cohortsize=3, ncohort=10, baseline `p.true` as in `Skill.md`. 
- Compare newly generated outputs to `expected/`.
If mismatch occurs, stop and report what differs (parameters, package version, seed, defaults). 
