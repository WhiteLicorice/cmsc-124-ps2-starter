case_expressions <- list(
    P01 = quote(c(TRUE, 2L, 3.5)),
    P02 = quote(c(1L, "2", TRUE)),
    P03 = quote(c(10L, 20L, 30L, 40L) + c(1L, 2L)),
    P04 = quote(c(first = 8L, second = 5L, third = 9L)[c(3L, 1L)]),
    P05 = quote(c(4L, 7L, 9L)[-2L]),
    P06 = quote({
        x <- c(5L, NA_integer_, 12L, 3L)
        x[is.na(x) | x > 10L]
    }),
    P07 = quote(factor(c("low", "high", "low"), levels = c("low", "high"))),
    P08 = quote(list(scores = c(3L, 5L), label = "A")),
    P09 = quote(data.frame(id = 1:2, passed = c(TRUE, FALSE))),
    P10 = quote(matrix(1:6, nrow = 2L) + c(10L, 20L)),
    P11 = quote(mean(c(8, NA_real_, 10))),
    P12 = quote(mean(c(8, NA_real_, 10), na.rm = TRUE)),
    P13 = quote({
        x <- 1:3
        x[2] <- 2.5
        x
    }),
    P14 = quote({
        scores <- c(7, NA_real_, 12, 4)
        adjusted <- ifelse(is.na(scores), 0, scores * 2)
        adjusted[adjusted > 15] <- 15
        adjusted
    }),
    P15 = quote(array(1:8, dim = c(2L, 2L, 2L))),
    P16 = quote(c(4L, 7L, 9L)[0L])
)
