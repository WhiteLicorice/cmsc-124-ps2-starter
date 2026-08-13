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
scripts/                given runner and formatting code
run  check.sh           the course run contract
```

## First Run

Fill and commit `predictions.tsv` before executing a case. Then run one case or
the whole grader:

```bash
./run P01
./check.sh
```

A fresh starter reports `1/70 checks passed` and exits 1. A complete submission
reports `70/70 checks passed` and exits 0. `check.sh` is the whole grade. The
expected table and grader are both in this repository.

## Reading a First Run

Don't read `1/70` as progress. The single pass is the check that the vector
stub contains no forbidden loop, which the empty stub satisfies by accident.
Every prediction and every function check fails. Nothing has been done.

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
| 0 | `./check.sh` | all 70 checks passed |
| 1 | `./check.sh` | at least one check failed |
| 0 | `./run <case>` | the case was found and printed |
| 64 | `./run <case>` | called with the wrong number of arguments |
| 65 | `./run <case>` | the case id is unknown |

## Tested Toolchains

Every row below is a run that happened.

| Environment | Versions | Result |
|---|---|---|
| Windows 11 | R 4.6.1 | `1/70` on the starter; `70/70` with the instructor solution |
| GitHub Actions, `ubuntu-latest` | R 4.6.1 through `r-lib/actions/setup-r` | `1/70` on the starter, matching the local run |
| GitHub Actions, `macos-latest` | the same workflow | `1/70` on the starter |
| GitHub Actions, `windows-latest` | the same workflow | `1/70` on the starter |
