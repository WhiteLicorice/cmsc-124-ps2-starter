# validate_predictions.R -- form checks for predictions.tsv.
#
# This file never reads tests/expected.tsv and never evaluates a case, so
# running it tells you nothing about whether an answer is right. That is what
# makes it safe to run before the prediction commit.
#
# It reads the raw lines instead of read.delim's output, because read.delim
# hides the faults this is looking for. A padded cell survives the parse and
# then fails its comparison, which reads like a wrong prediction rather than a
# stray space. One trailing space per line fails all 16 dim checks that way.

PREDICTION_COLUMNS <- c("id", "value", "type", "length", "dim")
PREDICTION_IDS <- sprintf("P%02d", seq_len(16))
TYPEOF_SPELLINGS <- c("logical", "integer", "double", "character", "list")

validate_predictions <- function(path = "predictions.tsv") {
    problems <- character(0)
    todos <- character(0)
    note <- function(...) problems <<- c(problems, paste0(...))

    if (!file.exists(path)) {
        return(list(problems = paste0(path, " is missing."), todos = todos))
    }

    lines <- readLines(path, warn = FALSE)
    # A CRLF file grades correctly, so the carriage return is not a fault.
    lines <- sub("\r$", "", lines)
    # Neither is a blank line at the end of the file.
    while (length(lines) > 0L && !nzchar(lines[[length(lines)]])) {
        lines <- lines[-length(lines)]
    }

    if (length(lines) == 0L) {
        return(list(problems = paste0(path, " is empty."), todos = todos))
    }

    if (!identical(strsplit(lines[[1]], "\t", fixed = TRUE)[[1]], PREDICTION_COLUMNS)) {
        note("line 1: the header row must be exactly ",
             paste(PREDICTION_COLUMNS, collapse = "<TAB>"), ".")
    }

    wanted_lines <- length(PREDICTION_IDS) + 1L
    if (length(lines) != wanted_lines) {
        note("the file holds ", length(lines), " lines. It needs ", wanted_lines,
             ", one header and one row for each of P01 to P16.")
    }

    for (index in seq_along(lines)[-1]) {
        row <- index - 1L
        fields <- strsplit(lines[[index]], "\t", fixed = TRUE)[[1]]
        label <- paste0("line ", index)

        if (length(fields) != length(PREDICTION_COLUMNS)) {
            note(label, ": found ", length(fields), " fields, expected ",
                 length(PREDICTION_COLUMNS),
                 ". Separate the columns with one tab each and use no tab anywhere else.",
                 " An editor set to insert spaces instead of tabs lands here.")
            next
        }

        for (column in seq_along(PREDICTION_COLUMNS)) {
            value <- fields[[column]]
            where <- paste0(label, ", column ", PREDICTION_COLUMNS[[column]])

            if (!nzchar(value)) {
                note(where, ": the cell is empty.")
                next
            }
            if (grepl("^[[:space:]]|[[:space:]]$", value)) {
                note(where, ": the cell has leading or trailing whitespace. The",
                     " comparison is exact, so \"", value, "\" is not the same",
                     " answer as \"", trimws(value), "\".")
            }
            if (grepl("[[:space:]]", trimws(value))) {
                note(where, ": the cell contains a space. No field in this table",
                     " holds one, so \"[1, 2]\" fails where \"[1,2]\" passes.")
            }
        }

        if (row <= length(PREDICTION_IDS)) {
            found_id <- trimws(fields[[1]])
            wanted_id <- PREDICTION_IDS[[row]]
            if (!identical(found_id, wanted_id)) {
                note(label, ": the id reads \"", found_id, "\". Row ", row,
                     " must be ", wanted_id, ", and all 16 ids stay in order.")
            }
        }

        cells <- trimws(fields[-1])
        names(cells) <- PREDICTION_COLUMNS[-1]

        if (any(cells == "TODO")) {
            todos <- c(todos, paste0(trimws(fields[[1]]), ": ",
                                     sum(cells == "TODO"), " of 4 cells still read TODO"))
            next
        }

        if (!(cells[["type"]] %in% TYPEOF_SPELLINGS)) {
            note(label, ", column type: \"", cells[["type"]],
                 "\" is not a word typeof() returns. It answers with one of ",
                 paste(TYPEOF_SPELLINGS, collapse = ", "), ".")
        }
        if (!grepl("^[0-9]+$", cells[["length"]])) {
            note(label, ", column length: \"", cells[["length"]],
                 "\" is not a whole number. length() counts elements, so it is 0 or more.")
        }
        if (!identical(cells[["dim"]], "none") &&
            !grepl("^[0-9]+(x[0-9]+)*$", cells[["dim"]])) {
            note(label, ", column dim: \"", cells[["dim"]],
                 "\" is neither none nor dimensions joined with x, as in 2x3.")
        }
    }

    list(problems = problems, todos = todos)
}
