#!/bin/bash
# Environment validation for the CSC 391/691 HW0a starter.
#
#   ./validate.sh            check the login environment only
#   ./validate.sh --submit   also submit the batch job and print the job id
#
# Every check runs. The script does not stop at the first failure, so one
# pass produces the full picture.

set -uo pipefail
cd "$(dirname "$0")"
PASS=0; FAIL=0
ok()   { echo "[ok  ] $*"; PASS=$((PASS+1)); }
bad()  { echo "[FAIL] $*"; FAIL=$((FAIL+1)); }
info() { echo "[info] $*"; }

echo "=== CSC 391/691 HW0a starter validation ==="
echo "host $(hostname)   date $(date -Iseconds)"
echo

if source deac/site.sh 2>/dev/null; then ok "deac/site.sh sources"; else bad "deac/site.sh sources"; fi
info "account   ${DEAC_ACCOUNT:-unset}"
info "cpu part  ${DEAC_CPU_PARTITION:-unset}"

if command -v python3 >/dev/null; then ok "python3 on PATH ($(python3 -V 2>&1))"; else bad "python3 on PATH"; fi
deac_load_cpu 2>/dev/null || info "module load reported an error, continuing"

if python3 -c "import numpy" 2>/dev/null; then ok "numpy importable"; else bad "numpy importable"; fi
if python3 smoke_test.py; then ok "smoke_test.py passed"; else bad "smoke_test.py passed"; fi

for tool in sbatch sacct sinfo scontrol; do
  if command -v $tool >/dev/null; then ok "$tool on PATH"; else bad "$tool on PATH"; fi
done
if command -v seff >/dev/null; then ok "seff on PATH"; else info "seff absent, HW0b part A falls back to sacct"; fi

if [ -n "${DEAC_CPU_PARTITION:-}" ] && command -v sinfo >/dev/null; then
  if sinfo -h -p "$DEAC_CPU_PARTITION" >/dev/null 2>&1; then
    ok "cpu partition $DEAC_CPU_PARTITION exists"
    sinfo -h -p "$DEAC_CPU_PARTITION" -o '       %P %a %l %D %T' | head -5
  else
    bad "cpu partition $DEAC_CPU_PARTITION exists"
  fi
fi

if [ "${1:-}" = "--submit" ]; then
  mkdir -p results
  if JOB=$(sbatch --parsable jobs/matmul.slurm 2>&1); then
    ok "batch job submitted, id $JOB"
    info "check with  sacct -j $JOB --format=JobID,State,Elapsed,ExitCode"
  else
    bad "batch job submitted ($JOB)"
  fi
fi

echo
echo "passed $PASS   failed $FAIL"
[ "$FAIL" -eq 0 ]
