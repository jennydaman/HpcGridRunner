# Multi-Node, Multi-CPU Parallel HpcGridRunner

This repository is a (hacky) fork of
[HpcGridRunner](https://github.com/HpcGridRunner/HpcGridRunner).

The program reads a text file containing a list of commands to run,
and then schedules them to SLURM as separate jobs.

The list of commands is split up evenly. The scheduling of commands
as multiple jobs parallelizes across multiple nodes.
Unlike the original
[HpcGridRunner](https://github.com/HpcGridRunner/HpcGridRunner).
this program will use
[GNU parallel](https://www.gnu.org/software/parallel/parallel.html)
within every job to parallelize across CPUs as well.
Hence, the work is parallelized across nodes and across CPUs within
nodes.

Use case: you want to run a large number (like 90,000) of commands via
SLURM, where each command requires 1 CPU and 1G mem. Your typical
usage limit includes many high core-count nodes (like 100 nodes with 128 cores).

## Known Problems

Querying a job which timed out using `squeue -j JOBID` causes

```
slurm_load_jobs error: Invalid job id specified
```

If you see this in the output, give up,
[kill everything](#Cencel-jobs),
increase the time limit per job and try again.

## Useful Commands

#### Show Job Limit

```shell
sacctmgr show qos format=Name,Priority,MaxJobsPU,MaxSubmitPU,MaxSubmitPA,MaxJobsPA
```

#### Cancel jobs

```shell
# cancel all jobs
for job in $(squeue -u $USER --format '%A' -h); do scancel $job; done

# cancel all pending jobs
for job in $(squeue -u $USER --format '%A' -h --state=PD); do scancel $job; done


squeue -u zhang.jenn --state=PD --format '%A' -h
```

