"""Offline tests. These run without a cluster and without a GPU."""

import os
import sys

import numpy as np
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from matmul_bench import gflops, run  # noqa: E402


def test_gflops_formula():
    # A 1000 x 1000 multiply is 2e9 flops. One second is therefore 2 GFLOP/s.
    assert gflops(1000, 1.0) == pytest.approx(2.0)


def test_run_returns_one_time_per_rep():
    times, checksum = run(128, 3, np.dtype("float64"), seed=0)
    assert len(times) == 3
    assert all(t > 0 for t in times)
    assert np.isfinite(checksum)


def test_run_is_a_correct_multiply():
    rng = np.random.default_rng(0)
    a = np.ascontiguousarray(rng.standard_normal((128, 128), dtype=np.float64))
    b = np.ascontiguousarray(rng.standard_normal((128, 128), dtype=np.float64))
    # run() uses the same seed and shapes, so its checksum is C[0, 0].
    times, checksum = run(128, 1, np.dtype("float64"), seed=0)
    assert checksum == pytest.approx(float((a @ b)[0, 0]), rel=1e-12)
