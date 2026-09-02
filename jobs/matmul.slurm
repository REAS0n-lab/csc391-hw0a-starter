#!/bin/bash
# HW0a batch job. Two lines need editing before this will run. They are
# marked EDIT. Leave everything else alone.

#SBATCH --job-name=hw0a-matmul
#SBATCH --account=REPLACE_WITH_COURSE_ACCOUNT      # EDIT
#SBATCH --partition=REPLACE_WITH_CPU_PARTITION     # EDIT
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=24G
#SBATCH --time=00:30:00
#SBATCH --output=results/%x-%j.out
#SBATCH --error=results/%x-%j.err

set -uo pipefail
cd "${SLURM_SUBMIT_DIR:-$PWD}"
mkdir -p results

source deac/site.sh
deac_load_cpu

# One thread. The benchmark is single threaded in HW0a so that the peak you
# compare against is a single-core peak. HW0b takes the resource request
# apart and asks what the other cores were doing.
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1

echo "=== node ==="
hostname
lscpu 2>/dev/null | head -20
free -g 2>/dev/null | head -2
echo

echo "=== N = 1000 ==="
python3 matmul_bench.py -n 1000 --json results/hw0a.jsonl
echo

echo "=== N = 4000 ==="
python3 matmul_bench.py -n 4000 --json results/hw0a.jsonl
