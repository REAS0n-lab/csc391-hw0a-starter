#!/bin/bash
# DEAC site configuration for CSC 391/691.
#
# Every value below is filled in once, by the course staff, after the DEAC
# team confirms it. Job scripts and submit wrappers source this file so that
# no Slurm directive is duplicated across assignments.
#
# Values marked UNCONFIRMED have not been verified on DEAC. Do not treat a
# job that fails against an UNCONFIRMED value as a bug in your code.

# ---------------------------------------------------------------- accounting
# Slurm account charged for course jobs.
export DEAC_ACCOUNT="${DEAC_ACCOUNT:-UNCONFIRMED_account}"

# Optional QOS or reservation for the course. Leave empty if none is granted.
export DEAC_QOS="${DEAC_QOS:-}"
export DEAC_RESERVATION="${DEAC_RESERVATION:-}"

# ---------------------------------------------------------------- partitions
# CPU partition used by HW0a, HW0b parts A to C, HW1, and HW2.
export DEAC_CPU_PARTITION="${DEAC_CPU_PARTITION:-UNCONFIRMED_cpu_partition}"

# GPU partition used by HW0b part D and HW3.
export DEAC_GPU_PARTITION="${DEAC_GPU_PARTITION:-UNCONFIRMED_gpu_partition}"

# Generic resource string passed to --gres. Example values are gpu:1 and
# gpu:a100:1. HW3 needs the device type to be pinned so that the roofline
# bound matches the device the job landed on.
export DEAC_GPU_GRES="${DEAC_GPU_GRES:-gpu:1}"

# ------------------------------------------------------------------- limits
# Largest node count the course allocation supports for a multi-node job.
# HW2 sweeps 1, 2, 4, 8 when this is 8 or larger, and 1, 2, 4 otherwise.
export DEAC_MAX_NODES="${DEAC_MAX_NODES:-8}"

# Cores per node on the CPU partition. Used to set OMP_NUM_THREADS and to
# convert wall-clock time into core-hours in HW0b part A.
export DEAC_CORES_PER_NODE="${DEAC_CORES_PER_NODE:-UNCONFIRMED}"

# Default wall-clock ceiling for a single course job.
export DEAC_DEFAULT_TIME="${DEAC_DEFAULT_TIME:-00:30:00}"

# ------------------------------------------------------------------ modules
# Module lines are executed in order. Keep each entry a complete command so
# that a site needing "module use" or a conda activate can be expressed here
# without changing any job script.
deac_load_cpu() {
  module purge 2>/dev/null || true
  # UNCONFIRMED. Replace with the DEAC module names.
  module load python 2>/dev/null || true
}

deac_load_mpi() {
  deac_load_cpu
  # UNCONFIRMED. Replace with the DEAC MPI module.
  module load openmpi 2>/dev/null || true
}

deac_load_gpu() {
  deac_load_cpu
  # Confirmed on DEAC (artemis) on 2026-09-02. DEAC also carries 12.4.1 under
  # the same prefix. Keep 12.8.1, because it matches the CI toolkit and the
  # PyTorch cu128 wheel.
  module load nvidia/cuda12/cuda/12.8.1
}

# --------------------------------------------------------------- sbatch args
# Assembles the account, partition, and reservation flags for a submit
# wrapper. Usage is  sbatch $(deac_sbatch_args cpu) jobs/example.slurm
deac_sbatch_args() {
  local kind="${1:-cpu}"
  local args="--account=${DEAC_ACCOUNT}"
  case "$kind" in
    gpu) args="$args --partition=${DEAC_GPU_PARTITION} --gres=${DEAC_GPU_GRES}" ;;
    *)   args="$args --partition=${DEAC_CPU_PARTITION}" ;;
  esac
  [ -n "$DEAC_QOS" ] && args="$args --qos=${DEAC_QOS}"
  [ -n "$DEAC_RESERVATION" ] && args="$args --reservation=${DEAC_RESERVATION}"
  echo "$args"
}
