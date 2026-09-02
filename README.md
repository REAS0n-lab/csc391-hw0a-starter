# CSC 391/691 HW0a starter

This repository contains everything HW0a needs. A benchmark that multiplies
two dense matrices, a test that confirms the environment can run it, and
a Slurm script that runs it on a DEAC compute node.

You should be editing two lines in one file. If you find yourself writing lines and lines of code in the
benchmark, stop and reread this page.

**Assigned 9/2. Due at the start of class Wednesday 9/9.**

## Layout

```
matmul_bench.py       the benchmark, N x N dense multiply, reports GFLOP/s
test.py         environment check, run this first
jobs/matmul.slurm     the batch job, two lines marked EDIT
deac/site.sh          account, partition, and module settings for DEAC
deac/NODES.md         node hardware reference for the percent-of-peak number
env/setup.sh          builds a Python environment on DEAC, run once
tests/                offline unit tests, no cluster needed
validate.sh           one-shot environment report, used by course staff
results/              job output lands here and is not committed
```

## Setup

Make your own copy of this repository under the REASOn Lab organization, then
clone it onto DEAC and build the environment once. The organization login on
GitHub is spelled with a zero, REAS0n-lab, and the Canvas post has the same
command.

```bash
gh repo create REAS0n-lab/csc391-hw0a-YOUR-GITHUB-HANDLE \
  --template REAS0n-lab/csc391-hw0a-starter --private

ssh <you>@deac                      # then, on the cluster
git clone https://github.com/REAS0n-lab/csc391-hw0a-YOUR-GITHUB-HANDLE.git
cd csc391-hw0a-YOUR-GITHUB-HANDLE
./env/setup.sh
```

Your copy is where you work. Your last push before the deadline is your
submission, and there is no separate submit step.

Then run the smoke test on the login node.

```bash
python3 test.py
```

The smoke test is small on purpose. Nothing else in this repository should be
run on a login node. That machine is shared by everyone on the cluster.

## Run the benchmark

Open `jobs/matmul.slurm` and edit the two lines marked `EDIT` so that the job
runs under your account on the course partition. The values are on Canvas and
in `deac/site.sh`. Submit it.

```bash
sbatch jobs/matmul.slurm
```

The job runs `matmul_bench.py` at N = 1000 and N = 4000, writes human readable
output to `results/hw0a-matmul-<jobid>.out`, and appends one JSON record per
run to `results/hw0a.jsonl`.

Check on it with `squeue -u $USER`, and afterwards with

```bash
sacct -j <jobid> --format=JobID,State,Elapsed,ExitCode,MaxRSS
```

## What the benchmark reports

For each run it prints wall-clock seconds and GFLOP/s, computed as

```
GFLOP/s = 2 * N^3 / seconds / 1e9
```

The factor 2*N^3 is the operation count for a dense N x N multiply, counting
one multiply and one add per inner-product term.

Percent of peak is your arithmetic, not the harness's. `deac/NODES.md` holds
the node hardware figures and the formula for a single-core peak. Record which
clock you used, base or turbo, because the two give different answers and the
difference is worth a sentence in your write-up.

## Timing choices this harness makes

The timer starts after both matrices are allocated and filled, and it stops
after the multiply. `--reps` defaults to 1, so the default run reports a
single measurement with no warmup.

That default is a decision, not an oversight. Whether it is a good decision is
the subject of class on 9/11, and your numbers are the material.

## Running the tests

```bash
python3 -m pytest tests -q
```

These check the GFLOP/s arithmetic and that the harness performs the multiply
it claims to. They do not check anything about performance.

## If you cannot log in

Email the instructor by 5pm Friday 9/4. Account
provisioning has a lead time and the DEAC session on 9/9 is intended to troubleshoot,
so the more of this you have already attempted the more
useful meeting with the HPC team will be.