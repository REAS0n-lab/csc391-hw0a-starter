#!/usr/bin/env python3
"""Confirm that the environment can run the HW0a benchmark.

Checks the Python version, imports NumPy, reports the BLAS backend, and
multiplies a small pair of matrices against an independently computed
reference. Exits non-zero if any check fails.
"""

import os
import platform
import socket
import sys

FAILURES = []


def check(label, condition, detail=""):
    status = "ok  " if condition else "FAIL"
    print(f"[{status}] {label}" + (f"  {detail}" if detail else ""))
    if not condition:
        FAILURES.append(label)
    return condition


def blas_backend(np):
    try:
        cfg = np.__config__.show(mode="dicts")
        return cfg["Build Dependencies"]["blas"]["name"]
    except Exception:
        pass
    try:
        info = np.__config__.get_info("blas_opt")
        return (info or {}).get("libraries", ["unknown"])[0]
    except Exception:
        return "unknown"


def main():
    print(f"hostname   {socket.gethostname()}")
    print(f"python     {platform.python_version()}  ({sys.executable})")
    print()

    check("python >= 3.8", sys.version_info >= (3, 8),
          f"found {platform.python_version()}")

    try:
        import numpy as np
    except ImportError as exc:
        check("numpy imports", False, str(exc))
        return finish()
    check("numpy imports", True, f"version {np.__version__}")
    print(f"[info] numpy BLAS backend  {blas_backend(np)}")

    for var in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
                "SLURM_CPUS_PER_TASK", "SLURM_JOB_ID"):
        if os.environ.get(var):
            print(f"[info] {var}={os.environ[var]}")

    a = np.array([[1.0, 2.0], [3.0, 4.0]])
    b = np.array([[5.0, 6.0], [7.0, 8.0]])
    expected = np.array([[19.0, 22.0], [43.0, 50.0]])
    check("2x2 multiply matches hand calculation", bool(np.allclose(a @ b, expected)))

    rng = np.random.default_rng(0)
    m = rng.standard_normal((128, 128))
    check("A @ I equals A at 128x128", bool(np.allclose(m @ np.eye(128), m)))

    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from matmul_bench import gflops, run
    times, _ = run(256, 1, np.dtype("float64"), 0)
    check("benchmark harness runs at N=256",
          len(times) == 1 and times[0] > 0,
          f"{times[0]:.4f} s, {gflops(256, times[0]):.2f} GFLOP/s")

    return finish()


def finish():
    print()
    if FAILURES:
        print(f"SMOKE TEST FAILED  {len(FAILURES)} check(s) -> {', '.join(FAILURES)}")
        return 1
    print("SMOKE TEST PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
