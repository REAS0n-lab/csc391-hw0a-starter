#!/usr/bin/env python3
"""Dense square matrix multiply timing harness.

Times C = A @ B for N x N matrices and reports GFLOP/s using 2*N^3 floating
point operations. Allocation and random fill happen before the timer starts,
so the reported time covers the multiply only.
"""

import argparse
import json
import os
import platform
import socket
import sys
import time

import numpy as np

THREAD_VARS = (
    "OMP_NUM_THREADS",
    "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS",
    "NUMEXPR_NUM_THREADS",
    "SLURM_CPUS_PER_TASK",
)


def environment():
    """Collect the run context that a measurement is worthless without."""
    return {
        "hostname": socket.gethostname(),
        "python": platform.python_version(),
        "numpy": np.__version__,
        "slurm_job_id": os.environ.get("SLURM_JOB_ID", ""),
        "slurm_array_task_id": os.environ.get("SLURM_ARRAY_TASK_ID", ""),
        "threads": {v: os.environ.get(v, "") for v in THREAD_VARS},
    }


def run(n, reps, dtype, seed):
    """Return a list of elapsed times, one per repetition, and C[0, 0]."""
    rng = np.random.default_rng(seed)
    a = np.ascontiguousarray(rng.standard_normal((n, n), dtype=dtype))
    b = np.ascontiguousarray(rng.standard_normal((n, n), dtype=dtype))

    times = []
    checksum = None
    for _ in range(reps):
        start = time.perf_counter()
        c = a @ b
        elapsed = time.perf_counter() - start
        times.append(elapsed)
        # Touch the result so that no implementation can defer the work.
        checksum = float(c[0, 0])
    return times, checksum


def gflops(n, seconds):
    return (2.0 * n ** 3) / seconds / 1e9


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("-n", "--size", type=int, required=True,
                   help="matrix dimension N")
    p.add_argument("-r", "--reps", type=int, default=1,
                   help="timed repetitions (default 1)")
    p.add_argument("--dtype", default="float64", choices=["float32", "float64"])
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--json", default=None,
                   help="append one JSON record per repetition to this file")
    args = p.parse_args(argv)

    dtype = np.dtype(args.dtype)
    times, checksum = run(args.size, args.reps, dtype, args.seed)

    env = environment()
    print(f"host        {env['hostname']}")
    print(f"numpy       {env['numpy']}")
    print(f"dtype       {dtype.name}")
    print(f"N           {args.size}")
    print(f"reps        {args.reps}")
    for k, v in env["threads"].items():
        if v:
            print(f"{k:<12}{v}")
    print()
    print(f"{'rep':>4}  {'seconds':>12}  {'GFLOP/s':>12}")
    for i, t in enumerate(times):
        print(f"{i:>4}  {t:>12.6f}  {gflops(args.size, t):>12.3f}")
    best = min(times)
    print()
    print(f"best        {best:.6f} s   {gflops(args.size, best):.3f} GFLOP/s")
    print(f"checksum    {checksum:.6e}")

    if args.json:
        with open(args.json, "a") as fh:
            for i, t in enumerate(times):
                record = {
                    "benchmark": "matmul",
                    "device": "cpu",
                    "n": args.size,
                    "rep": i,
                    "dtype": dtype.name,
                    "seconds": t,
                    "gflops": gflops(args.size, t),
                }
                record.update(env)
                fh.write(json.dumps(record) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
