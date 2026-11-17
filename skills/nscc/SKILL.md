---
name: nscc
description: Use the `nscc` CLI for the NSCC ASPIRE 2A supercomputer (超算) — run commands, submit PBS jobs, check status/logs, move data. Use whenever the user mentions nscc, NSCC, 超算, ASPIRE, qsub/qstat or PBS jobs.
---

# nscc

The account only allows password SSH, so plain `ssh`/`rsync`/`scp` fail. Always use `nscc`; it logs in with `$MYPASS_XL` and reuses that connection for 10 min.

```bash
nscc run "<cmd>"                  # run a command on the login node (test: nscc run hostname)
nscc status                       # qstat for this user
nscc submit <project-dir> <pbs>   # upload to ~/nscc_submit/<name>/runs/<stamp>/ and qsub there
nscc log [job-id] [--err]         # job stdout/stderr; no id = latest (avoid -f, it never exits)
nscc del <job-id>                 # qdel
nscc fetch <url> <project>        # download on NSCC into ~/nscc_submit/<project>/data/
nscc pull <remote-path> [local]   # copy results to this machine
```

- Each submit is a new snapshot in `runs/<stamp>/`; job outputs stay there and are never overwritten. Shared data lives in `<project>/data/` (symlinked into each run as `data/`).
- Recent job ids and run dirs are in `~/.nscc/history.log`. Never print `$MYPASS_XL` or `~/.nscc/config`.
- On `Permission denied`, stop after one try (account lockout risk) and ask the user to update the password in `~/.zshrc`.
