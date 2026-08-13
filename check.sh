#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"

if ! command -v Rscript >/dev/null 2>&1; then
    echo "check.sh: Rscript is not on PATH. Complete the R setup in the manual." >&2
    exit 1
fi

exec Rscript tests/check_all.R
