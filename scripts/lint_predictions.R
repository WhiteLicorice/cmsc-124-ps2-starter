source("scripts/validate_predictions.R")

report <- validate_predictions("predictions.tsv")

if (length(report$problems) > 0L) {
    cat("== form ==\n")
    for (problem in report$problems) {
        cat("  ", problem, "\n", sep = "")
    }
}

if (length(report$todos) > 0L) {
    cat(if (length(report$problems) > 0L) "\n" else "", "== unfinished ==\n", sep = "")
    for (todo in report$todos) {
        cat("  ", todo, "\n", sep = "")
    }
}

if (length(report$problems) == 0L && length(report$todos) == 0L) {
    cat("predictions.tsv is well formed and complete.\n")
    cat("This read the table's shape only. It says nothing about whether an answer is right.\n")
    quit(status = 0L)
}

cat("\n")
if (length(report$problems) > 0L) {
    cat("Those are formatting faults, not wrong answers. Fix them first.\n")
}
if (length(report$todos) > 0L) {
    cat("Replace every TODO before you commit the table.\n")
}
quit(status = 1L)
