<!--no-pdf-->
# CMSC 124 Problem Set 2 Starter

This repository contains the R prediction corpus and the four functions for
Problem Set 2. The assignment manual defines the work and the submission rules.

## Layout

```text
cases/cases.R           the 16 quoted expressions
predictions.tsv         your value, type, length, and dimension predictions
src/analysis.R          the four functions you implement
tests/expected.tsv      every published expected result
tests/check_all.R       the complete public grader
scripts/                given runner, formatting, and form-check code
run  lint  check.sh     the course run contract
```

## First Run

Fill `predictions.tsv`, check its format with `./lint`, and commit it before
executing a case. Then run one case or the whole grader:

```bash
./lint
./run P01
./check.sh
```

`./lint` reads the table's form only. It never opens `tests/expected.tsv` or
evaluates a case. You can run it before the prediction commit without revealing
an answer. It catches a padded cell, a space inside a value, a tab replaced with
spaces, and a missing or reordered row. Those faults otherwise look like wrong
predictions. One trailing space per line fails all 16 `dim` checks.
`./check.sh` lists the same faults before it scores.

A fresh starter reports `1/71 checks passed` and exits 1. A complete submission
reports `71/71 checks passed` and exits 0. This is the complete public automated
check. The rubric separately assesses analysis quality, prediction history,
collaboration, and workflow evidence. The expected table and grader are both in
this repository. The 71st check verifies that `ANALYSIS.md` contains no
placeholder text and stays within the 300 to 450 word range.

## Required Reading

The manual carries the rules the 16 cases grade. It doesn't teach R from
nothing, so these two go with it and are meant to be read while you work.

*An Introduction to R*, the official guide from the R Core Team, documents the
same R 4.6.1 this repository's workflow runs and uses no packages:

```text
https://cran.r-project.org/doc/manuals/R-intro.html
```

*Advanced R* by Hadley Wickham, chapter 3, "Vectors," covers coercion,
attributes, factors, lists, and data frames in this problem set's vocabulary.
Skip its tibble material, since nothing here uses one:

```text
https://adv-r.hadley.nz/vectors-chap.html
```

Watch the vocabulary in the official guide. It talks about an object's *mode*
and never mentions `typeof()`, and the two disagree:

```r
mode(c(1L, 2L))     # "numeric"
typeof(c(1L, 2L))   # "integer"
```

Half the cases have `integer` as their type, so read that guide for the rules
and write your predictions in `typeof()`'s words. The manual's Required Reading
section maps each topic to a section number.

## Reading a First Run

Don't read `1/71` as progress. The single pass is the check that the vector
stub contains no forbidden loop, which the empty stub satisfies by accident.
Every prediction, every function check, and the analysis check fail. Nothing has
been done.

The Actions badge on this repository is red for the same reason. It stays red
until a pair completes the assignment, which is the correct state for a
starter. Yours goes green when you finish.

## When the Grader Stops Early

`predictions.tsv` has to keep its five columns and all 16 ids in order. When it
doesn't, the grader stops before the first check and prints why. A run that
ends without a `== result ==` line never scored anything, so read the message
and repair the table's columns and ids before you look at your answers.

Fields are compared exactly. `double` passes and ` double` doesn't, so don't
pad a cell to line the columns up in your editor.

## Exit Codes

The course contract.

| Code | Command | Meaning |
|---|---|---|
| 0 | `./check.sh` | all 71 checks passed |
| 1 | `./check.sh` | at least one check failed |
| 0 | `./lint` | `predictions.tsv` is well formed and complete |
| 1 | `./lint` | the table is malformed or still holds a TODO |
| 0 | `./run <case>` | the case was found and printed |
| 64 | `./run <case>` | called with the wrong number of arguments |
| 65 | `./run <case>` | the case id is unknown |

## Tested Toolchains

Every row below is a run that happened.

| Environment | Versions | Result |
|---|---|---|
| Windows 11 | R 4.6.1 | `1/71` on the starter, `71/71` with the instructor solution |
| GitHub Actions, `ubuntu-latest` | R 4.6.1 through `r-lib/actions/setup-r` | `1/71` on the starter, matching the local run |
| GitHub Actions, `macos-latest` | the same workflow | `1/71` on the starter |
| GitHub Actions, `windows-latest` | the same workflow | `1/71` on the starter |
