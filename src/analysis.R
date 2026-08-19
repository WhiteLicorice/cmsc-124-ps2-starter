# analysis.R -- the four functions Part 2 asks for.
#
# Each stub below carries what it receives, what it must return, the constraint
# the grader enforces on it, and one worked call using the published sample. The
# sample is the same one tests/check_all.R runs, so a function that reproduces
# the call below passes its check.
#
# The published sample, used by every example here:
#
#   sample_scores <- c(Ada = 8, Grace = NA_real_, Linus = 12, Barbara = 4)

# clean_scores_vector(scores)
#
# scores:  a numeric vector, possibly carrying a `names` attribute, and possibly
#          holding NA values.
# returns: a numeric vector of the same length, carrying the same names, where
#          every NA has become 0 and every other element is min(2 * score, 20).
#
# Vector expressions and subassignment only. No for, while, repeat, Map, lapply,
# sapply, or vapply. The grader deparses this function's body and fails the run
# when it finds one of those words, so the constraint is checked whether or not
# the numbers come out right.
#
#   clean_scores_vector(sample_scores)
#   #     Ada   Grace   Linus Barbara
#   #      16       0      20       8
#
# A logical vector the same length as `scores`, placed inside [ ] on the left of
# <-, replaces exactly the elements it marks and leaves the names attached. That
# is the subassignment the constraint is asking for.
clean_scores_vector <- function(scores) {
    stop("TODO: implement clean_scores_vector()")
}

# clean_scores_scalar(scores)
#
# scores:  the same input as clean_scores_vector().
# returns: the same output as clean_scores_vector(), element for element,
#          including the names.
#
# This one must use a `for` loop and handle one element per pass, and it must not
# call clean_scores_vector(). The grader checks both. The loop is the point: it
# gives you a scalar evaluation model to set against R's vector model in
# ANALYSIS.md.
#
#   clean_scores_scalar(sample_scores)
#   #     Ada   Grace   Linus Barbara
#   #      16       0      20       8
#
# Copy `scores` into a local vector and write each result back with
# out[[i]] <- value, which keeps the names attached. Accumulating into a fresh
# vector with out <- c(out, value) drops them, and the check compares with
# identical(), which notices.
clean_scores_scalar <- function(scores) {
    stop("TODO: implement clean_scores_scalar()")
}

# build_roster(student_names, groups, scores)
#
# student_names: a character vector of names.
# groups:        a character vector of group labels, the same length.
# scores:        a numeric vector of raw scores, the same length, possibly named.
# returns:       a data frame with five columns, in this order:
#                  name            the names as character values
#                  group           a factor whose levels follow first appearance
#                                  in `groups`
#                  raw_score       the scores with their names removed
#                  adjusted_score  clean_scores_vector(scores), names removed
#                  passed          TRUE when adjusted_score is at least 12
#
# Build it with stringsAsFactors = FALSE. The `group` column is an explicit
# factor, so that setting only affects `name`, which has to stay character.
#
#   build_roster(c("Ada", "Grace", "Linus", "Barbara"),
#                c("red", "blue", "red", "blue"),
#                sample_scores)
#   #      name group raw_score adjusted_score passed
#   # 1     Ada   red         8             16   TRUE
#   # 2   Grace  blue        NA              0  FALSE
#   # 3   Linus   red        12             20   TRUE
#   # 4 Barbara  blue         4              8  FALSE
#
# factor(groups) sorts its levels, which for "red" and "blue" gives the wrong
# order. factor(groups, levels = unique(groups)) keeps first-appearance order.
# unname() is what strips the names off the two score columns.
build_roster <- function(student_names, groups, scores) {
    stop("TODO: implement build_roster()")
}

# summarize_roster(roster)
#
# roster:  a data frame built by build_roster().
# returns: a list with these five items, in this order, with these types:
#            rows           integer, the row count
#            missing_raw    integer, how many raw_score values are NA
#            mean_adjusted  double, the mean of adjusted_score
#            passed         character, the names of students whose passed is TRUE
#            mean_by_group  a named double vector with no dim attribute, one
#                           mean of adjusted_score per level of the group
#                           factor, named by that level, in level order
#
# The check compares with identical(), so the types are graded as strictly as
# the numbers. nrow() and sum() over a logical already give integers, and mean()
# gives a double. tapply() looks like the tool for mean_by_group and returns a
# one-dimensional array, which carries a dim attribute and fails identical()
# even when it prints the same two numbers.
#
#   summarize_roster(build_roster(...))    # the call above
#   # List of 5
#   #  $ rows         : int 4
#   #  $ missing_raw  : int 1
#   #  $ mean_adjusted: num 11
#   #  $ passed       : chr [1:2] "Ada" "Linus"
#   #  $ mean_by_group: Named num [1:2] 18 4
#   #   ..- attr(*, "names")= chr [1:2] "red" "blue"
#
# Building mean_by_group with c() over two means you computed yourself is the
# straightforward route. sapply() over split() also returns a named vector with
# no dimensions.
summarize_roster <- function(roster) {
    stop("TODO: implement summarize_roster()")
}
