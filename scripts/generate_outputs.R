#!/usr/bin/env Rscript

# scripts/generate_outputs.R
# Purpose:
# - Generate BOIN boundary tables + OC summaries for a new design
# - Write outputs into outputs/
#
# Usage: Modify the parameters section below for your specific design

suppressPackageStartupMessages({
  if (!requireNamespace("BOIN", quietly = TRUE)) {
    stop("Package 'BOIN' is not installed. Install with: install.packages('BOIN')")
  }
})

# ---- utilities ----
dir_create <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)

write_csv_base <- function(df, path) {
  utils::write.csv(df, path, row.names = TRUE, quote = TRUE)
}

df_to_markdown <- function(df) {
  # Minimal Markdown table renderer (no external deps)
  # Handle matrices with row names (like BOIN boundary tables)
  if (is.matrix(df)) {
    rnames <- rownames(df)
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    if (!is.null(rnames) && any(nzchar(rnames))) {
      df <- cbind(data.frame(row_label = rnames, stringsAsFactors = FALSE), df)
    }
  }
  
  cols <- colnames(df)
  header <- paste0("|", paste(cols, collapse = "|"), "|")
  sep <- paste0("|", paste(rep("---", length(cols)), collapse = "|"), "|")

  fmt_cell <- function(v) {
    if (is.na(v)) return("")
    if (is.numeric(v)) {
      return(formatC(v, digits = 6, format = "fg", flag = "#"))
    }
    as.character(v)
  }

  rows <- apply(df, 1, function(r) {
    paste0("|", paste(vapply(r, fmt_cell, character(1)), collapse = "|"), "|")
  })

  paste(c(header, sep, rows), collapse = "\n")
}

# ---- DESIGN PARAMETERS (MODIFY FOR YOUR STUDY) ----
target <- 0.30
ncohort <- 10
cohortsize <- 5
n_doses <- 4
dose_labels <- c("50mg", "100mg", "150mg", "250mg")

# Simulation scenarios (modify as needed)
scenarios <- list(
  scenario1 = list(
    name = "MTD at middle dose (100mg)",
    p.true = c(0.05, 0.20, 0.30, 0.50)
  ),
  scenario2 = list(
    name = "All doses too toxic",
    p.true = c(0.35, 0.50, 0.65, 0.80)
  ),
  scenario3 = list(
    name = "MTD at highest dose (250mg)",
    p.true = c(0.05, 0.10, 0.20, 0.30)
  )
)

ntrial <- 1000
seed <- 123

# Default BOIN params (explicit to avoid ambiguity)
p_saf <- 0.6 * target
p_tox <- 1.4 * target
cutoff_eli <- 0.95
extrasafe <- FALSE
offset <- 0.05
n_earlystop <- 10  # Stop early if this many patients treated at single dose with "stay" decision

# ---- paths ----
out_dir <- "outputs"
dir_create(out_dir)

boundary_csv <- file.path(out_dir, "boundary_full.csv")
boundary_md  <- file.path(out_dir, "boundary_full.md")
flowchart_png <- file.path(out_dir, "boin_flowchart.png")

# ---- generate boundaries ----
cat("Generating decision boundaries...\n")
bound <- BOIN::get.boundary(
  target = target,
  ncohort = ncohort,
  cohortsize = cohortsize,
  n.earlystop = n_earlystop,
  p.saf = p_saf,
  p.tox = p_tox,
  cutoff.eli = cutoff_eli,
  extrasafe = extrasafe,
  offset = offset
)

# IMPORTANT: full_boundary_tab is a MATRIX with row names
# Row names are: "Number of patients treated", "Escalate if # of DLT <=", 
#                "Deescalate if # of DLT >=", "Eliminate if # of DLT >="
full_tab <- bound$full_boundary_tab
write_csv_base(full_tab, boundary_csv)
cat(df_to_markdown(full_tab), file = boundary_md)
cat("✓ Decision boundaries saved to outputs/boundary_full.csv and .md\n")

# Also save the simplified boundary_tab for cohort-size multiples
boundary_tab_csv <- file.path(out_dir, "boundary_tab.csv")
boundary_tab_md <- file.path(out_dir, "boundary_tab.md")
write_csv_base(bound$boundary_tab, boundary_tab_csv)
cat(df_to_markdown(bound$boundary_tab), file = boundary_tab_md)
cat("✓ Simplified boundary table saved to outputs/boundary_tab.csv and .md\n")

# Generate flowchart visualization
cat("✓ Generating BOIN flowchart...\n")
png(flowchart_png, width = 1000, height = 800, res = 120)
plot(bound)
dev.off()
cat("✓ Flowchart saved to outputs/boin_flowchart.png\n")

# Generate heatmap-style decision table visualization
cat("✓ Generating BOIN decision table heatmap...\n")
heatmap_png <- file.path(out_dir, "boin_decision_heatmap.png")

# Extract the full boundary table
full_tab <- bound$full_boundary_tab
n_patients <- as.numeric(full_tab["Number of patients treated", ])
escalate_boundary <- as.numeric(full_tab["Escalate if # of DLT <=", ])
deescalate_boundary <- as.numeric(full_tab["Deescalate if # of DLT >=", ])
eliminate_boundary <- as.numeric(full_tab["Eliminate if # of DLT >=", ])

# Create a grid for the heatmap
max_n <- max(n_patients)
min_n <- min(n_patients)
n_range <- min_n:max_n
decision_matrix <- matrix("", nrow = max_n + 1, ncol = length(n_range))
rownames(decision_matrix) <- 0:max_n
colnames(decision_matrix) <- n_range

# Fill in the decision matrix
for (i in 1:length(n_patients)) {
  n <- n_patients[i]
  col_idx <- which(n_range == n)
  esc_bound <- escalate_boundary[i]
  deesc_bound <- deescalate_boundary[i]
  elim_bound <- eliminate_boundary[i]
  
  for (dlt in 0:n) {
    if (!is.na(elim_bound) && dlt >= elim_bound) {
      decision_matrix[dlt + 1, col_idx] <- "DE"  # De-escalate and Eliminate
    } else if (dlt >= deesc_bound) {
      decision_matrix[dlt + 1, col_idx] <- "D"   # De-escalate
    } else if (dlt <= esc_bound) {
      decision_matrix[dlt + 1, col_idx] <- "E"   # Escalate
    } else {
      decision_matrix[dlt + 1, col_idx] <- "S"   # Stay
    }
  }
}

# Create the heatmap using base R graphics
png(heatmap_png, width = 1200, height = 1000, res = 120)
par(mar = c(5, 5, 2, 2))

# Define colors for each decision
decision_colors <- c("E" = "#CCCCCC", "S" = "#999999", "D" = "#666666", "DE" = "#333333")

# Create empty plot
plot(0, 0, type = "n", xlim = c(min_n - 0.5, max_n + 0.5), ylim = c(-0.5, max_n + 0.5),
     xlab = "Number of evaluable patients treated at current dose",
     ylab = "Number of patients with DLT",
     xaxt = "n", yaxt = "n", main = "")

# Add grid lines
abline(h = 0:max_n, col = "white", lwd = 2)
abline(v = n_range - 0.5, col = "white", lwd = 2)
abline(v = max_n + 0.5, col = "white", lwd = 2)

# Fill in the cells
for (i in 1:nrow(decision_matrix)) {
  for (j in 1:ncol(decision_matrix)) {
    decision <- decision_matrix[i, j]
    if (decision != "") {
      n_val <- n_range[j]
      rect(n_val - 0.5, i - 1.5, n_val + 0.5, i - 0.5, 
           col = decision_colors[decision], border = NA)
      text(n_val, i - 1, decision, cex = 1.2, font = 2)
    }
  }
}

# Add axes
axis(1, at = n_range, labels = n_range)
axis(2, at = 0:max_n, labels = 0:max_n, las = 1)

# Add legend
legend("topleft", 
       legend = c("E = Escalate to the next higher dose",
                  "DE = De-escalate and eliminate\n     the current and higher doses",
                  "D = De-escalate to the next lower dose",
                  "S = Stay at the current dose"),
       fill = c(decision_colors["E"], decision_colors["DE"], 
                decision_colors["D"], decision_colors["S"]),
       title = "Decision",
       cex = 0.9,
       bg = "white")

dev.off()
cat(sprintf("✓ Decision table heatmap saved to %s\n", heatmap_png))

# ---- generate OCs for each scenario ----
cat("\nGenerating operating characteristics (1000 simulated trials per scenario)...\n")

oc_results <- list()

for (sc_name in names(scenarios)) {
  sc <- scenarios[[sc_name]]
  cat(sprintf("  - %s: p.true = (%s)\n", 
              sc$name, 
              paste(sc$p.true, collapse = ", ")))
  
  oc <- BOIN::get.oc(
    target = target,
    p.true = sc$p.true,
    ncohort = ncohort,
    cohortsize = cohortsize,
    n.earlystop = n_earlystop,
    startdose = 1,
    titration = FALSE,
    p.saf = p_saf,
    p.tox = p_tox,
    cutoff.eli = cutoff_eli,
    extrasafe = extrasafe,
    offset = offset,
    boundMTD = FALSE,
    ntrial = ntrial,
    seed = seed
  )
  
  # Build tidy OC table
  dose <- seq_along(sc$p.true)
  oc_tbl <- data.frame(
    scenario = sc$name,
    dose = dose,
    dose_label = dose_labels[dose],
    p_true = sc$p.true,
    selpercent = as.numeric(oc$selpercent),
    mean_npatients = as.numeric(oc$npatients),
    mean_ntox = as.numeric(oc$ntox),
    stringsAsFactors = FALSE
  )
  
  # Add trial-level columns to dose rows as NA
  oc_tbl$percentstop <- NA_real_
  oc_tbl$overdose60 <- NA_real_
  oc_tbl$overdose80 <- NA_real_
  
  # Extract trial-level metrics safely
  totaln_val <- if (length(oc$totaln) > 0) as.numeric(oc$totaln) else NA_real_
  totaltox_val <- if (length(oc$totaltox) > 0) as.numeric(oc$totaltox) else NA_real_
  percentstop_val <- if (length(oc$percentstop) > 0) as.numeric(oc$percentstop) else NA_real_
  overdose60_val <- if (length(oc$overdose60) > 0) as.numeric(oc$overdose60) else NA_real_
  overdose80_val <- if (length(oc$overdose80) > 0) as.numeric(oc$overdose80) else NA_real_
  
  # Create totals row with all columns
  totals <- data.frame(
    scenario = sc$name,
    dose = NA_integer_,
    dose_label = "TOTAL",
    p_true = NA_real_,
    selpercent = NA_real_,
    mean_npatients = totaln_val,
    mean_ntox = totaltox_val,
    percentstop = percentstop_val,
    overdose60 = overdose60_val,
    overdose80 = overdose80_val,
    stringsAsFactors = FALSE
  )
  
  oc_results[[sc_name]] <- rbind(oc_tbl, totals)
}

# Combine all scenarios into one table
oc_combined <- do.call(rbind, oc_results)
oc_csv <- file.path(out_dir, "oc_all_scenarios.csv")
oc_md <- file.path(out_dir, "oc_all_scenarios.md")
write_csv_base(oc_combined, oc_csv)
cat(df_to_markdown(oc_combined), file = oc_md)
cat("✓ Operating characteristics saved to outputs/oc_all_scenarios.csv and .md\n")

# Generate OC plots for each scenario
cat("\nGenerating OC visualization plots...\n")
for (sc_name in names(scenarios)) {
  sc <- scenarios[[sc_name]]
  cat(sprintf("  - Plotting %s\n", sc$name))
  
  # Re-run OC for individual plot
  oc_plot <- BOIN::get.oc(
    target = target,
    p.true = sc$p.true,
    ncohort = ncohort,
    cohortsize = cohortsize,
    n.earlystop = n_earlystop,
    startdose = 1,
    titration = FALSE,
    p.saf = p_saf,
    p.tox = p_tox,
    cutoff.eli = cutoff_eli,
    extrasafe = extrasafe,
    offset = offset,
    boundMTD = FALSE,
    ntrial = ntrial,
    seed = seed
  )
  
  # Clean filename
  filename <- gsub("[^A-Za-z0-9]+", "_", tolower(sc$name))
  plot_path <- file.path(out_dir, sprintf("oc_plot_%s.png", filename))
  
  png(plot_path, width = 800, height = 600, res = 120)
  plot(oc_plot)
  title(main = sc$name, line = 2.5)
  dev.off()
}
cat("✓ OC plots saved to outputs/oc_plot_*.png\n")

# ---- summary report ----
cat("\n", rep("=", 60), "\n", sep = "")
cat("BOIN DESIGN GENERATION COMPLETE\n")
cat(rep("=", 60), "\n", sep = "")
cat("\nDesign parameters:\n")
cat(sprintf("  Target DLT rate: %.2f\n", target))
cat(sprintf("  Dose levels: %d (%s)\n", n_doses, paste(dose_labels, collapse = ", ")))
cat(sprintf("  Cohort size: %d\n", cohortsize))
cat(sprintf("  Max cohorts: %d (max N = %d)\n", ncohort, ncohort * cohortsize))
cat(sprintf("  Starting dose: %s (Dose 1)\n", dose_labels[1]))
cat(sprintf("  Lambda_e (escalation boundary): %.3f\n", bound$lambda_e))
cat(sprintf("  Lambda_d (de-escalation boundary): %.3f\n", bound$lambda_d))
cat("\nOutputs generated:\n")
cat("  - outputs/boundary_full.csv (full decision table with row names)\n")
cat("  - outputs/boundary_full.md (human-readable full table)\n")
cat("  - outputs/boundary_tab.csv (simplified table for cohort multiples)\n")
cat("  - outputs/boundary_tab.md (human-readable simplified table)\n")
cat("  - outputs/boin_flowchart.png (decision flowchart visualization)\n")
cat("  - outputs/boin_decision_heatmap.png (decision table heatmap)\n")
cat("  - outputs/oc_all_scenarios.csv (operating characteristics)\n")
cat("  - outputs/oc_all_scenarios.md (human-readable OCs)\n")
cat("  - outputs/oc_plot_*.png (OC visualization plots for each scenario)\n")
cat("\nNext step:\n")
cat("  Review the outputs and update mini_protocol.md with figures\n")
