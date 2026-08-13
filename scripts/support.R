encode_scalar <- function(value) {
    if (is.na(value)) {
        return("NA")
    }
    if (is.character(value)) {
        return(encodeString(value, quote = '"'))
    }
    if (is.logical(value)) {
        return(if (value) "TRUE" else "FALSE")
    }
    format(value, trim = TRUE, scientific = FALSE)
}

encode_atomic <- function(value) {
    pieces <- vapply(value, encode_scalar, character(1), USE.NAMES = FALSE)
    value_names <- names(value)
    if (!is.null(value_names)) {
        named <- nzchar(value_names)
        pieces[named] <- paste0(value_names[named], "=", pieces[named])
    }
    paste0("[", paste(pieces, collapse = ","), "]")
}

encode_value <- function(value) {
    if (is.factor(value)) {
        labels <- paste(as.character(value), collapse = ",")
        level_text <- paste(levels(value), collapse = ",")
        return(paste0("factor[", labels, "];levels=[", level_text, "]"))
    }

    if (is.data.frame(value)) {
        columns <- Map(
            function(column, column_name) {
                paste0(column_name, "=", encode_value(column))
            },
            value,
            names(value)
        )
        size <- paste(dim(value), collapse = "x")
        return(paste0("data.frame[", size, "]{", paste(columns, collapse = ","), "}"))
    }

    if (is.list(value)) {
        item_names <- names(value)
        items <- Map(
            function(item, index) {
                prefix <- ""
                if (!is.null(item_names) && nzchar(item_names[[index]])) {
                    prefix <- paste0(item_names[[index]], "=")
                }
                paste0(prefix, encode_value(item))
            },
            value,
            seq_along(value)
        )
        return(paste0("list{", paste(items, collapse = ","), "}"))
    }

    value_dim <- dim(value)
    if (!is.null(value_dim)) {
        kind <- if (length(value_dim) == 2L) "matrix" else "array"
        size <- paste(value_dim, collapse = "x")
        payload <- paste(vapply(as.vector(value), encode_scalar, character(1)), collapse = ",")
        return(paste0(kind, "[", size, "](", payload, ")"))
    }

    encode_atomic(value)
}

describe_value <- function(value) {
    value_dim <- dim(value)
    c(
        value = encode_value(value),
        type = typeof(value),
        length = as.character(length(value)),
        dim = if (is.null(value_dim)) "none" else paste(value_dim, collapse = "x")
    )
}

evaluate_case <- function(case_id, expressions) {
    if (!(case_id %in% names(expressions))) {
        stop("unknown case: ", case_id, call. = FALSE)
    }
    value <- eval(expressions[[case_id]], envir = new.env(parent = baseenv()))
    describe_value(value)
}
