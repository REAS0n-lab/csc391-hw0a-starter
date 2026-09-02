# DEAC node reference

This file holds the hardware numbers you need for a percent-of-peak
calculation. Filling them in is the course staff's job, not yours. If a row
still says UNCONFIRMED, the number has not been verified on DEAC and you
should say so in your report rather than guessing.

## CPU nodes

| Field | Value | Source |
|---|---|---|
| Partition name | UNCONFIRMED | DEAC |
| CPU model | UNCONFIRMED | `lscpu` on a compute node |
| Sockets per node | UNCONFIRMED | `lscpu` |
| Cores per socket | UNCONFIRMED | `lscpu` |
| Base clock (GHz) | UNCONFIRMED | vendor spec sheet |
| All-core turbo clock (GHz) | UNCONFIRMED | vendor spec sheet |
| Vector width (bits) | UNCONFIRMED | `lscpu` flags, avx2 or avx512 |
| FMA units per core | UNCONFIRMED | vendor microarchitecture note |
| Memory per node (GB) | UNCONFIRMED | `free -g` |
| Memory bandwidth (GB/s) | UNCONFIRMED | vendor spec sheet or STREAM |

## GPU nodes

| Field | Value | Source |
|---|---|---|
| Partition name | UNCONFIRMED | DEAC |
| GPU model | UNCONFIRMED | `nvidia-smi` |
| GPUs per node | UNCONFIRMED | `nvidia-smi -L` |
| Memory per GPU (GB) | UNCONFIRMED | `nvidia-smi` |
| fp64 peak (TFLOP/s) | UNCONFIRMED | vendor spec sheet |
| fp32 peak (TFLOP/s) | UNCONFIRMED | vendor spec sheet |
| Tensor-core peak, tf32 or fp16 (TFLOP/s) | UNCONFIRMED | vendor spec sheet |
| HBM bandwidth (GB/s) | UNCONFIRMED | vendor spec sheet |
| CUDA driver and runtime version | UNCONFIRMED | `nvidia-smi`, `nvcc --version` |

## Interconnect

| Field | Value | Source |
|---|---|---|
| Fabric | UNCONFIRMED | DEAC |
| Peak bandwidth per node (GB/s) | UNCONFIRMED | vendor spec sheet |
| MPI implementation and version | UNCONFIRMED | `mpirun --version` |

## How to compute CPU peak

Peak floating-point rate for one node in double precision is

```
peak_GFLOPs = cores * clock_GHz * (vector_width_bits / 64) * fma_per_core * 2
```

The final factor of 2 counts the fused multiply-add as two operations. In
single precision, replace 64 with 32.

This number assumes every core runs vector FMAs every cycle at the stated
clock. No real matrix multiply reaches it. The gap between your measurement
and this number is the subject of the assignment, so record which clock you
used and whether it was the base or the turbo figure.
