# Statistical Considerations for Dose Finding

## Dose Finding Design

We will employ the Bayesian optimal interval (BOIN) design (Liu and Yuan, 2015; Yuan et al., 2016) to find the MTD. The BOIN design is implemented in a simple way similar to the traditional 3+3 design, but is more flexible and possesses superior operating characteristics that are comparable to those of the more complex model-based designs, such as the continual reassessment method (CRM) (Zhou et al., 2018). BOIN received the fit-for-purpose designation from U.S. Food & Drug Administration (FDA, 2021) as a tool for drug development.

The target toxicity rate for the MTD is φ = {{TARGET_DLT}} and the maximum sample size is {{MAX_N}}. We will enroll and treat patients in cohorts of size {{COHORT_SIZE}}. DLTs are defined as {{DLT_DEFINITION}}, and only those DLTs that occur within {{DLT_WINDOW}} will be used for dose finding. As shown in Figure 1, the BOIN design uses the following rule to guide dose escalation/de-escalation:

- If the observed DLT rate at the current dose is **≤ {{LAMBDA_E}}**, escalate the dose to the next higher level.
- If the observed DLT rate at the current dose is **> {{LAMBDA_D}}**, de-escalate the dose to the next lower level.
- Otherwise, stay at the current dose.

The steps to implement the BOIN design are described as follows:

1. **Starting dose:** Patients in the first cohort are treated at dose level {{START_DOSE}} ({{START_DOSE_LABEL}}).

2. **Dose escalation and de-escalation:** Based on the observed DLT data at the current dose, make the decision to escalate, de-escalate, or stay using the decision rule described in Table 1.

3. **Dose elimination:** If **≥ 3 patients** have been treated at the current dose and the data indicate that **Pr(p > φ | data) > {{CUTOFF_ELI}}**, where p is the true DLT rate of the current dose, **eliminate this dose and all higher doses from the trial** to prevent exposing patients to these overly toxic doses. The trial continues by treating the next cohort of patients at the next lower dose. If the lowest dose is eliminated, the trial is terminated early and no dose is selected as the MTD.

4. **Early stopping for efficiency:** If {{N_EARLYSTOP}} patients have been treated at a single dose and the decision is to "stay" at that dose, the trial may be stopped early and that dose selected as the MTD. This improves trial efficiency by avoiding unnecessary patient exposure once a stable dose is identified.

5. **Trial termination:** The trial is terminated if one of the following occurs: (i) the maximum sample size of {{MAX_N}} patients is reached; (ii) the lowest dose is eliminated due to safety; or (iii) the early stopping criterion for efficiency is met.

### Table 1. Dose escalation/de-escalation rule for the BOIN design

{{INSERT_BOUNDARY_TABLE}}

The decision boundaries are calculated based on the BOIN design with target DLT rate φ = {{TARGET_DLT}} and cohort size = {{COHORT_SIZE}}. The table shows, for each number of patients (n) treated at the current dose:
- **Escalate if # of DLT ≤**: The maximum number of DLTs to allow escalation
- **De-escalate if # of DLT ≥**: The minimum number of DLTs to trigger de-escalation
- **Eliminate if # of DLT ≥**: The minimum number of DLTs to trigger elimination of this dose and all higher doses

**How to use the table:** After treating patients at the current dose, count the total number of evaluable patients (n) and total number of DLTs (m) at that dose. Use the table to determine whether to escalate, de-escalate, stay, or eliminate based on the values of n and m.

### Visual Aids for Trial Conduct

Two visualizations are provided to help communicate the BOIN design to the clinical team:

#### Figure 1. BOIN Decision Flowchart

![BOIN Flowchart](boin_flowchart.png)

*Figure 1 shows the decision flowchart for dose escalation and de-escalation. The observed DLT rate is calculated as the ratio of total DLTs to total evaluable patients at the current dose. Based on whether this rate falls below λₑ ({{LAMBDA_E}}), within [λₑ, λd], or above λd ({{LAMBDA_D}}), the trial escalates, stays, or de-escalates the dose.*

#### Figure 2. BOIN Decision Table Heatmap

![BOIN Decision Heatmap](boin_decision_heatmap.png)

*Figure 2 shows a color-coded heatmap of the BOIN decision table. The X-axis represents the number of evaluable patients treated at the current dose, and the Y-axis represents the number of patients with DLT. Each cell shows the decision: E (Escalate, light gray), S (Stay, medium gray), D (De-escalate, dark gray), or DE (De-escalate and Eliminate, darkest gray). This visualization provides an intuitive reference for clinicians during trial conduct and can be used for training and regulatory submissions.*

## MTD Selection

After the trial is completed, select the MTD based on isotonic regression as specified in Liu and Yuan (2015). This computation is implemented by the shiny app "BOIN" (Zhou et al., 2021) available at http://www.trialdesign.org. Specifically, select as the MTD the dose for which the isotonic estimate of the toxicity rate is closest to the target toxicity rate {{TARGET_DLT}}. If there are ties:
- Select the **higher dose level** when the isotonic estimate is **lower than** the target toxicity rate
- Select the **lower dose level** when the isotonic estimate is **greater than or equal to** the target toxicity rate

## Operating Characteristics

Table 2 shows the operating characteristics of the trial design based on 1000 simulations of the trial using the R package "BOIN" available at http://www.trialdesign.org. The operating characteristics show that the design selects the true MTD, if any, with high probability and allocates a high percentage of patients to the dose levels with the DLT rate closest to the target of {{TARGET_DLT}}.

### Table 2. Operating characteristics of the BOIN design

{{INSERT_OC_TABLE}}

**Interpretation of operating characteristics:**

The simulation scenarios represent hypothetical "true" DLT rates at each dose level, which are unknown in reality. These scenarios help evaluate how the design performs under different possible realities:

- **Selection %:** The percentage of simulated trials in which each dose was selected as the MTD
- **Mean # treated:** The average number of patients treated at each dose level across simulated trials
- **Mean # DLTs:** The average number of DLTs observed at each dose level
- **Early stop %:** The percentage of trials that stopped early (either for safety or efficiency)

**Key performance metrics to evaluate:**
- **MTD identification accuracy:** Proportion of trials selecting the true MTD or an acceptable nearby dose
- **Sample size efficiency:** Average number of patients enrolled compared to maximum N (early stopping benefit)
- **Safety profile:** Overall DLT rate and distribution of patients across dose levels
- **Adaptive behavior:** Appropriate escalation when doses are safe, appropriate de-escalation/stopping when doses are toxic

{{INSERT_SCENARIO_INTERPRETATIONS}}

### Figures 3-5. Observed toxicity distribution by scenario

{{INSERT_OC_PLOTS}}

*Figures 3-5 show the distribution of observed toxicities across dose levels for each simulation scenario. These bar charts visualize the average number of patients treated at each dose (darker bars = current dose, lighter bars = other doses) and help assess the design's ability to allocate patients appropriately across dose levels under different toxicity profiles.*

## References

- Liu, S., & Yuan, Y. (2015). Bayesian optimal interval designs for phase I clinical trials. *Journal of the Royal Statistical Society: Series C (Applied Statistics)*, 64(3), 507-523.

- Yuan, Y., Hess, K. R., Hilsenbeck, S. G., & Gilbert, M. R. (2016). Bayesian optimal interval design: a simple and well-performing design for phase I oncology trials. *Clinical Cancer Research*, 22(17), 4291-4301.

- Zhou, H., Yuan, Y., & Nie, L. (2018). Accuracy, safety, and reliability of novel phase I trial designs. *Clinical Cancer Research*, 24(18), 4357-4364.

- U.S. Food and Drug Administration. (2021). Fit-for-purpose initiative. https://www.fda.gov/about-fda/oncology-center-excellence/project-fda

- Zhou, Y., Lin, R., Kuo, Y., Lee, J. J., & Yuan, Y. (2021). BOIN suite: a software platform to design and implement novel early phase clinical trials. *JCO Clinical Cancer Informatics*, 5, 91-101.

---

## Appendix A: Full BOIN Decision Boundary Table

For situations where the number of evaluable patients deviates from cohort-size multiples (e.g., due to patient inevaluability or over-enrollment), use the full boundary table below which provides decisions for every possible number of patients from 1 to {{MAX_N}}:

{{INSERT_FULL_BOUNDARY_TABLE}}

This comprehensive table should be used as the source of truth during trial conduct to handle any enrollment scenario. The machine-readable version is available in `outputs/boundary_full.csv`.

## Appendix B: Additional Documentation

For more information about the BOIN visualizations and implementation details, see:
- `outputs/VISUALIZATION_GUIDE.md` - Guide to flowchart and OC plots
- `outputs/HEATMAP_VISUALIZATION_GUIDE.md` - Detailed explanation of the decision table heatmap
- `scripts/generate_outputs.R` - Source code for generating all outputs
