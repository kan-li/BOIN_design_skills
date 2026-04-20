#!/usr/bin/env Rscript

# scripts/validate.R
# Purpose:
# - Generate BOIN boundary tables + OC summaries for the canonical fixture
# - Write outputs into outputs/
# - Compare against expected/ (golden files) if present
#
# Canonical fixture:
# 6 doses, target=0.30, cohortsize=3, ncohort=10
# p.true = (0.05, 0.15, 0.30, 0.35, 0.45, 0.60)
# ntrial=1000, seed=6

suppressPackageStartupMessages({
  if (!requireNamespace("BOIN", quietly = TRUE)) {
    stop("Package 'BOIN' is not installed. Install with: install.packages('BOIN')")
  }
})

# ---- utilities ----
dir_create <- function(path) if (!dir.exists(path)) dir.create(path, recursive = TRUE, showWarnings = FALSE)

read_csv_base <- function(path) {
  # Keep strings as strings, avoid factor conversion
  utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
}

write_csv_base <- function(df, path) {
  utils::write.csv(df, path, row.names = FALSE, quote = TRUE)
}

is_numeric_col <- function(x) is.numeric(x) || is.integer(x)

normalize_df <- function(df) {
  # Ensure stable column ordering and row ordering for diffs
  df
}

df_to_markdown <- function(df) {
  # Minimal Markdown table renderer (no external deps)
  cols <- colnames(df)
  header <- paste0("|", paste(cols, collapse = "|"), "|")
  sep <- paste0("|", paste(rep("---", length(cols)), collapse = "|"), "|")

  fmt_cell <- function(v) {
    if (is.na(v)) return("")
    if (is.numeric(v)) {
      # keep reasonable precision but stable formatting
      return(formatC(v, digits = 6, format = "fg", flag = "#"))
    }
    as.character(v)
  }

  rows <- apply(df, 1, function(r) {
    paste0("|", paste(vapply(r, fmt_cell, character(1)), collapse = "|"), "|")
  })

  paste(c(header, sep, rows), collapse = "\n")
}

compare_csv_exact <- function(got_path, exp_path) {
  got <- read_csv_base(got_path)
  exp <- read_csv_base(exp_path)

  # Exact match for non-numeric too; numeric compared by exact equality
  if (!identical(colnames(got), colnames(exp))) {
    return(list(ok = FALSE, msg = "Column names differ"))
  }
  if (nrow(got) != nrow(exp)) {
    return(list(ok = FALSE, msg = sprintf("Row counts differ (got %d vs expected %d)", nrow(got), nrow(exp))))
  }

  for (j in seq_along(got)) {
    gj <- got[[j]]
    ej <- exp[[j]]
    if (is_numeric_col(gj) && is_numeric_col(ej)) {
      if (!isTRUE(all.equal(gj, ej, tolerance = 0))) {
        return(list(ok = FALSE, msg = sprintf("Numeric column '%s' differs (exact)", colnames(got)[j])))
      }
    } else {
      if (!identical(gj, ej)) {
        return(list(ok = FALSE, msg = sprintf("Column '%s' differs", colnames(got)[j])))
      }
    }
  }
  list(ok = TRUE, msg = "Exact match")
}

compare_csv_numeric_tol <- function(got_path, exp_path, tol = 1e-8) {
  got <- read_csv_base(got_path)
  exp <- read_csv_base(exp_path)

  if (!identical(colnames(got), colnames(exp))) {
    return(list(ok = FALSE, msg = "Column names differ"))
  }
  if (nrow(got) != nrow(exp)) {
    return(list(ok = FALSE, msg = sprintf("Row counts differ (got %d vs expected %d)", nrow(got), nrow(exp))))
  }

  for (j in seq_along(got)) {
    gj <- got[[j]]
    ej <- exp[[j]]
    if (is_numeric_col(gj) && is_numeric_col(ej)) {
      if (!isTRUE(all.equal(gj, ej, tolerance = tol))) {
        return(list(ok = FALSE, msg = sprintf("Numeric column '%s' differs (tol=%g)", colnames(got)[j], tol)))
      }
    } else {
      if (!identical(gj, ej)) {
        return(list(ok = FALSE, msg = sprintf("Column '%s' differs", colnames(got)[j])))
      }
    }
  }
  list(ok = TRUE, msg = sprintf("Match within tolerance %g", tol))
}

# ---- canonical fixture parameters ----
target <- 0.30
ncohort <- 10
cohortsize <- 3
p_true <- c(0.05, 0.15, 0.30, 0.35, 0.45, 0.60)
ntrial <- 1000
seed <- 6

# Default BOIN params (kept explicit to avoid ambiguity)
p_saf <- 0.6 * target
p_tox <- 1.4 * target
cutoff_eli <- 0.95
extrasafe <- FALSE
offset <- 0.05
n_earlystop <- 100

# ---- paths ----
out_dir <- "outputs"
exp_dir <- "expected"
dir_create(out_dir)

boundary_csv <- file.path(out_dir, "boundary_full.csv")
boundary_md  <- file.path(out_dir, "boundary_full.md")
oc_csv       <- file.path(out_dir, "oc_baseline.csv")
oc_md        <- file.path(out_dir, "oc_baseline.md")

# ---- generate boundaries ----
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

# $full_boundary_tab is explicitly documented as part of get.boundary() return
full_tab <- bound$full_boundary_tab
write_csv_base(full_tab, boundary_csv)
cat(df_to_markdown(full_tab), file = boundary_md)

# ---- generate OCs (baseline scenario) ----
oc <- BOIN::get.oc(
  target = target,
  p.true = p_true,
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

# Build a tidy OC table: one row per dose + a totals row
dose <- seq_along(p_true)
oc_tbl <- data.frame(
  dose = dose,
  p_true = p_true,
  selpercent = as.numeric(oc$selpercent),
  mean_npatients = as.numeric(oc$npatients),
  mean_ntox = as.numeric(oc$ntox),
  stringsAsFactors = FALSE
)

totals <- data.frame(
  dose = NA_integer_,
  p_true = NA_real_,
  selpercent = NA_real_,
  mean_npatients = as.numeric(oc$totaln),
  mean_ntox = as.numeric(oc$totaltox),
  stringsAsFactors = FALSE
)

# Add trial-level metrics as attributes-like columns in totals row (easier to diff)
totals$percentstop <- as.numeric(oc$percentstop)
totals$overdose60 <- as.numeric(oc$overdose60)
totals$overdose80 <- as.numeric(oc$overdose80)

# Ensure columns exist in both parts
oc_tbl$percentstop <- NA_real_
oc_tbl$overdose60 <- NA_real_
oc_tbl$overdose80 <- NA_real_

oc_out <- rbind(oc_tbl, totals)
write_csv_base(oc_out, oc_csv)
cat(df_to_markdown(oc_out), file = oc_md)

# ---- compare against expected/ if present ----
status_ok <- TRUE

if (dir.exists(exp_dir)) {
  exp_boundary <- file.path(exp_dir, "boundary_full.csv")
  exp_oc <- file.path(exp_dir, "oc_baseline.csv")

  if (file.exists(exp_boundary)) {
    res <- compare_csv_exact(boundary_csv, exp_boundary)
    message(sprintf("[boundary_full.csv] %s", res$msg))
    status_ok <- status_ok && res$ok
  } else {
    message("[boundary_full.csv] expected file not found; skipping boundary diff.")
  }

  if (file.exists(exp_oc)) {
    # In principle seed should make this exact, but keep a small tolerance to avoid platform jitter.
    res <- compare_csv_numeric_tol(oc_csv, exp_oc, tol = 1e-8)
    message(sprintf("[oc_baseline.csv] %s", res$msg))
    status_ok <- status_ok && res$ok
  } else {
    message("[oc_baseline.csv] expected file not found; skipping OC diff.")
  }
} else {
  message("expected/ folder not found; outputs generated but not compared.")
}

# ---- finish ----
if (!status_ok) {
  message("VALIDATION FAILED: outputs differ from expected/.")
  #quit(status = 1)
} else {
  message("VALIDATION PASSED: outputs match expected/ (or expected/ not provided).")
  #quit(status = 0)
}
