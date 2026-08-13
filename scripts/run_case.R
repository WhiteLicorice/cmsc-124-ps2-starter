args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
    cat("usage: ./run CASE_ID\n", file = stderr())
    quit(status = 64L)
}

source("cases/cases.R")
source("scripts/support.R")

description <- tryCatch(
    evaluate_case(args[[1]], case_expressions),
    error = function(error) {
        cat(conditionMessage(error), "\n", sep = "", file = stderr())
        quit(status = 65L)
    }
)

cat("case: ", args[[1]], "\n", sep = "")
for (field in names(description)) {
    cat(field, ": ", description[[field]], "\n", sep = "")
}
