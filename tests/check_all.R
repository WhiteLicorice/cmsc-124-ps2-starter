source("cases/cases.R")
source("scripts/support.R")

read_table <- function(path) {
    read.delim(
        path,
        header = TRUE,
        sep = "\t",
        quote = "",
        colClasses = "character",
        check.names = FALSE,
        na.strings = NULL
    )
}

expected <- read_table("tests/expected.tsv")
predictions <- read_table("predictions.tsv")
fields <- c("value", "type", "length", "dim")

required_columns <- c("id", fields)
if (!identical(names(expected), required_columns)) {
    stop("tests/expected.tsv has the wrong columns", call. = FALSE)
}
if (!identical(names(predictions), required_columns)) {
    stop("predictions.tsv has the wrong columns", call. = FALSE)
}
if (!identical(expected$id, names(case_expressions))) {
    stop("the expected table and case corpus disagree on case IDs", call. = FALSE)
}
if (!identical(predictions$id, expected$id)) {
    stop("predictions.tsv must contain P01 through P16 in order", call. = FALSE)
}

for (row in seq_len(nrow(expected))) {
    observed <- evaluate_case(expected$id[[row]], case_expressions)
    for (field in fields) {
        if (!identical(unname(observed[[field]]), expected[[field]][[row]])) {
            stop(
                "published expectation drifted for ", expected$id[[row]], ".", field,
                ": expected ", expected[[field]][[row]],
                ", R produced ", observed[[field]],
                call. = FALSE
            )
        }
    }
}

passed <- 0L
total <- 0L

check <- function(label, thunk) {
    total <<- total + 1L
    result <- tryCatch(
        isTRUE(thunk()),
        error = function(error) {
            message("    ", conditionMessage(error))
            FALSE
        }
    )
    if (result) {
        passed <<- passed + 1L
        cat("PASS ", label, "\n", sep = "")
    } else {
        cat("FAIL ", label, "\n", sep = "")
    }
}

cat("== predictions ==\n")
for (row in seq_len(nrow(expected))) {
    for (field in fields) {
        case_id <- expected$id[[row]]
        check(
            paste0(case_id, ".", field),
            local({
                actual <- predictions[[field]][[row]]
                wanted <- expected[[field]][[row]]
                function() identical(actual, wanted)
            })
        )
    }
}

source("src/analysis.R")
sample_scores <- c(Ada = 8, Grace = NA_real_, Linus = 12, Barbara = 4)
expected_clean <- c(Ada = 16, Grace = 0, Linus = 20, Barbara = 8)

cat("\n== implementation ==\n")
vector_source <- paste(deparse(body(clean_scores_vector)), collapse = "\n")
scalar_source <- paste(deparse(body(clean_scores_scalar)), collapse = "\n")
check("clean_scores_vector_model", function() {
    !grepl("\\b(for|while|repeat|Map|lapply|sapply|vapply)\\b", vector_source)
})
check("clean_scores_scalar_model", function() {
    grepl("\\bfor\\s*\\(", scalar_source) &&
        !grepl("clean_scores_vector\\s*\\(", scalar_source)
})
check("clean_scores_vector", function() {
    identical(clean_scores_vector(sample_scores), expected_clean)
})
check("clean_scores_scalar", function() {
    identical(clean_scores_scalar(sample_scores), expected_clean)
})

expected_roster <- data.frame(
    name = c("Ada", "Grace", "Linus", "Barbara"),
    group = factor(c("red", "blue", "red", "blue"), levels = c("red", "blue")),
    raw_score = unname(sample_scores),
    adjusted_score = unname(expected_clean),
    passed = c(TRUE, FALSE, TRUE, FALSE),
    stringsAsFactors = FALSE
)

roster <- NULL
check("build_roster", function() {
    roster <<- build_roster(
        c("Ada", "Grace", "Linus", "Barbara"),
        c("red", "blue", "red", "blue"),
        sample_scores
    )
    identical(roster, expected_roster)
})

expected_summary <- list(
    rows = 4L,
    missing_raw = 1L,
    mean_adjusted = 11,
    passed = c("Ada", "Linus"),
    mean_by_group = c(red = 18, blue = 4)
)
check("summarize_roster", function() {
    if (is.null(roster)) {
        roster <- expected_roster
    }
    identical(summarize_roster(roster), expected_summary)
})

cat("\n== result ==\n")
cat(passed, "/", total, " checks passed\n", sep = "")
if (passed != total) {
    quit(status = 1L)
}
