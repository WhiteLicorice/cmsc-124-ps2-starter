source("cases/cases.R")
source("scripts/support.R")
source("scripts/validate_predictions.R")

# A form fault in predictions.tsv survives the parse and then fails its
# comparison, which reads like a wrong prediction rather than a stray space.
# One trailing space per line fails all 16 dim checks that way. Name the faults
# before scoring so nobody hunts for a coercion rule they already understood.
# Only malformations are listed here. A cell still reading TODO already shows
# as a failed check, and on a fresh starter every cell does.
prediction_form <- validate_predictions("predictions.tsv")
if (length(prediction_form$problems) > 0L) {
    cat("== predictions.tsv form ==
")
    for (problem in prediction_form$problems) {
        cat("  ", problem, "
", sep = "")
    }
    cat("
Those are formatting faults, not wrong answers.",
        " Run ./lint to see this list on its own.

", sep = "")
}

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

tryCatch(
    source("src/analysis.R"),
    error = function(error) {
        message("    src/analysis.R did not load: ", conditionMessage(error))
    }
)
sample_scores <- c(Ada = 8, Grace = NA_real_, Linus = 12, Barbara = 4)
expected_clean <- c(Ada = 16, Grace = 0, Linus = 20, Barbara = 8)

body_source <- function(name) {
    if (!exists(name, mode = "function")) {
        return(NA_character_)
    }
    paste(deparse(body(get(name, mode = "function"))), collapse = "\n")
}

# The two cleaner checks below compare against the same sample every worked
# example uses, so a cleaner that mishandles empty, all-missing, NaN, or
# single-element input still matches it. These five pairs cover those inputs.
# review_clean() joins them to the two existing checks rather than adding a check
# of its own, so the total stays at 76.
review_inputs <- list(
    numeric(0),
    c(A = 3),
    c(A = NA_real_, B = NA_real_),
    c(A = NaN, B = 3),
    c(A = 9.5, B = 10, C = 10.25)
)
review_outputs <- list(
    numeric(0),
    c(A = 6),
    c(A = 0, B = 0),
    c(A = 0, B = 6),
    c(A = 19, B = 20, C = 20)
)
review_clean <- function(fn) {
    all(vapply(seq_along(review_inputs), function(index) {
        tryCatch(
            identical(fn(review_inputs[[index]]), review_outputs[[index]]),
            error = function(error) FALSE
        )
    }, logical(1)))
}

# clean_scores_scalar() must evaluate one element per pass. What the code does
# when it runs decides that. This check counts loop iterations at run time. It
# does not read the loop domain. A saved constant or a legal literal domain
# defeats any domain rule. The rewrite wraps each for loop body so every pass
# increments a counter. The counter sits in an environment spliced into the
# rewrite. No name in student scope reaches it. A loop that never runs counts
# zero, however its domain is written.
#
# The probe is a length-4 numeric vector with no missing value. A length-4 probe
# keeps the four never-running faults below four passes. A probe with no missing
# value keeps which(!is.na(scores)) at four passes. The doubled probe values stay
# at or below 16. A cap threshold of 16 or higher therefore leaves the probe
# result unchanged, and the cap variants stay at 74/76.
#
# The check sums iterations across all loops. Nested loops inflate that total. A
# per-loop maximum would instead reject a legal nested loop, so the sum is
# deliberate.
probe_scores <- c(A = 8, B = 4, C = 7, D = 3)
probe_clean <- c(A = 16, B = 8, C = 14, D = 6)

record_iteration <- function(counter) {
    counter$total <- counter$total + 1L
    invisible(NULL)
}

instrument_for_loops <- function(node, counter) {
    if (!is.call(node)) {
        return(node)
    }
    if (identical(node[[1]], as.name("for"))) {
        node[[3]] <- instrument_for_loops(node[[3]], counter)
        node[[4]] <- instrument_for_loops(node[[4]], counter)
        node[[4]] <- as.call(list(
            as.name("{"),
            as.call(list(record_iteration, counter)),
            node[[4]]
        ))
        return(node)
    }
    for (index in seq_along(node)) {
        if (!identical(node[[index]], quote(expr = )) &&
            !is.null(node[[index]])) {
            node[[index]] <- instrument_for_loops(node[[index]], counter)
        }
    }
    node
}

loops_cover_each_element <- function(fn) {
    counter <- new.env(parent = emptyenv())
    counter$total <- 0L
    instrumented <- fn
    body(instrumented) <- instrument_for_loops(body(fn), counter)
    identical(instrumented(probe_scores), probe_clean) &&
        counter$total >= length(probe_scores)
}

cat("\n== implementation ==\n")
vector_source <- body_source("clean_scores_vector")
scalar_source <- body_source("clean_scores_scalar")
check("clean_scores_vector_model", function() {
    !is.na(vector_source) &&
        !grepl("\\b(for|while|repeat|Map|lapply|sapply|vapply)\\b", vector_source)
})
check("clean_scores_scalar_model", function() {
    if (is.na(scalar_source) || grepl("clean_scores_vector\\s*\\(", scalar_source)) {
        return(FALSE)
    }
    fn <- tryCatch(
        get("clean_scores_scalar", mode = "function"),
        error = function(error) NULL
    )
    !is.null(fn) && loops_cover_each_element(fn)
})
check("clean_scores_vector", function() {
    identical(clean_scores_vector(sample_scores), expected_clean) &&
        review_clean(clean_scores_vector)
})
check("clean_scores_scalar", function() {
    identical(clean_scores_scalar(sample_scores), expected_clean) &&
        review_clean(clean_scores_scalar)
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

# The sample above is the one every worked example uses, so a function that
# returns those literals passes it without implementing anything. These four
# checks use different inputs, the same way, so hard-coded sample results fail.
alternate_scores <- c(X = 1, Missing = NA_real_, Capped = 11)
expected_alternate_clean <- c(X = 2, Missing = 0, Capped = 20)

check("clean_scores_vector_alternate", function() {
    identical(clean_scores_vector(alternate_scores), expected_alternate_clean)
})
check("clean_scores_scalar_alternate", function() {
    identical(clean_scores_scalar(alternate_scores), expected_alternate_clean)
})

# adjusted_score is the cleaner's own output, so build it with the cleaner rather
# than a literal. The manual fixes no storage type for the cleaning result, so a
# cleaner that keeps integers for integer input passes here too. name, group, and
# raw_score stay literal, since those have a fixed required form.
alternate_names <- c("A", "B", "C")
alternate_groups <- c("gold", "bronze", "silver")
alternate_raw_scores <- c(A = 1L, B = 2L, C = 6L)

check("build_roster_alternate", function() {
    adjusted <- unname(clean_scores_vector(alternate_raw_scores))
    expected <- data.frame(
        name = alternate_names,
        group = factor(alternate_groups, levels = alternate_groups),
        raw_score = c(1L, 2L, 6L),
        adjusted_score = adjusted,
        passed = adjusted >= 12,
        stringsAsFactors = FALSE
    )
    identical(
        build_roster(alternate_names, alternate_groups, alternate_raw_scores),
        expected
    )
})

expected_alternate_summary <- list(
    rows = 3L,
    missing_raw = 0L,
    mean_adjusted = 6,
    passed = "C",
    mean_by_group = c(gold = 2, bronze = 4, silver = 12)
)
check("summarize_roster_alternate", function() {
    alternate_roster <- data.frame(
        name = alternate_names,
        group = factor(alternate_groups, levels = alternate_groups),
        raw_score = c(1L, 2L, 6L),
        adjusted_score = c(2, 4, 12),
        passed = c(FALSE, FALSE, TRUE),
        stringsAsFactors = FALSE
    )
    identical(summarize_roster(alternate_roster), expected_alternate_summary)
})

cat("\n== analysis ==\n")
analysis_text <- tryCatch(
    paste(readLines("ANALYSIS.md", warn = FALSE), collapse = "\n"),
    error = function(error) NA_character_
)
analysis_words <- function(text) {
    words <- strsplit(trimws(text), "[[:space:]]+")[[1]]
    length(words[nzchar(words)])
}
reasoning_placeholder <- "Replace this line with the rule that decides this case."
reasoning_text <- tryCatch(
    paste(readLines("REASONING.md", warn = FALSE), collapse = "\n"),
    error = function(error) NA_character_
)
reasoning_problem <- function(text) {
    if (is.na(text)) {
        return("REASONING.md is missing.")
    }
    lines <- trimws(strsplit(text, "\n", fixed = TRUE)[[1]])
    headings <- paste0("## P", sprintf("%02d", 1:16))
    labels <- sprintf("P%02d", 1:16)
    positions <- match(headings, lines)
    for (index in seq_along(headings)) {
        if (is.na(positions[[index]])) {
            return(paste0("REASONING.md is missing the heading ", labels[[index]], "."))
        }
        if (index > 1L && positions[[index]] < positions[[index - 1L]]) {
            return(paste0("REASONING.md puts ", labels[[index]], " out of order."))
        }
    }
    for (index in seq_along(headings)) {
        start <- positions[[index]] + 1L
        end <- if (index < length(headings)) positions[[index + 1L]] - 1L else length(lines)
        section <- if (start <= end) lines[start:end] else character(0)
        section <- section[nzchar(section)]
        if (any(section == reasoning_placeholder)) {
            return(paste0("REASONING.md still holds the placeholder under ", labels[[index]], "."))
        }
        if (length(section) == 0L) {
            return(paste0("REASONING.md has an empty section under ", labels[[index]], "."))
        }
    }
    NA_character_
}
check("reasoning_written", function() {
    problem <- reasoning_problem(reasoning_text)
    if (!is.na(problem)) {
        cat("    ", problem, "\n", sep = "")
    }
    is.na(problem)
})
check("analysis_written", function() {
    !is.na(analysis_text) &&
        !grepl("Replace this paragraph", analysis_text) &&
        { count <- analysis_words(analysis_text); count >= 300L && count <= 450L }
})

cat("\n== result ==\n")
cat(passed, "/", total, " checks passed\n", sep = "")
if (passed != total) {
    quit(status = 1L)
}
