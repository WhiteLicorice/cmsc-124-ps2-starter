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
reports `70/70 checks passed` and exits 0. The one starting pass confirms that
the vector stub doesn't contain a forbidden loop. `check.sh` is the whole grade.
The expected table and grader are both in this repository.
