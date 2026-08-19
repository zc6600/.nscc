# nscc

Helper CLI to submit jobs to [NSCC ASPIRE 2A](https://helpdesk.nscc.sg).
Lives in `~/.nscc/nscc`, symlinked into `/opt/homebrew/bin/nscc`.

### Why

The NSCC account (`zhu-chen@aspire2a.nus.edu.sg`) has no key-based SSH auth
enabled, so every `ssh`/`rsync`/`qsub` requires typing the password by hand.
This wraps the first connection in `expect`, feeding the password from the
`MYPASS_XL` environment variable, and opens it as an SSH ControlMaster
(`~/.ssh/nscc-*`). All subsequent ssh/rsync calls in the next 10 minutes
multiplex over that master — no password, and no pty in rsync's data path
(which would otherwise corrupt its binary protocol).

### How to use

```bash
nscc submit <project-path> <pbs-file>   # sync project to ~/nscc_submit/<name> + qsub
nscc fetch <url> <project-name>         # download URL directly on NSCC -> <name>/data/
nscc pull <remote-path> [local-path]    # copy files from NSCC to this machine
nscc run "<command>"                    # run any command on the login node
nscc status                             # qstat for this user
nscc log [job-id] [--err] [-f]          # job stdout/stderr; -f follows, no id = latest
nscc del <job-id>                       # qdel a job
nscc ssh                                # interactive login shell
nscc close                              # tear down the master connection
```

Every action is appended to `~/.nscc/history.log` (timestamp, action, detail,
result — e.g. the job id of each submit).

Setup:

1. `export MYPASS_XL=<your NSCC password>` (e.g. in `~/.zshrc`)
2. Symlink: `ln -sf ~/.nscc/nscc /opt/homebrew/bin/nscc`

### Sharing with teammates

This directory (`~/.nscc`) is itself the git repo — the script, installer,
and docs are tracked; your personal `config` and `history.log` are
gitignored and never leave your machine. Teammates install with:

```bash
git clone <repo-url> ~/.nscc
sh ~/.nscc/install.sh
```

which symlinks `~/.nscc/nscc` into a bin dir and creates a config template
(`nscc init` refuses to overwrite an existing config). A clone or zip
anywhere else also works: `sh install.sh` from inside it copies into
`~/.nscc` first.

Per-user settings live in `~/.nscc/config` — everyone hardcodes their own
account there:

```ini
[nscc]
host = your-user@aspire2a.nus.edu.sg   ; or an ~/.ssh/config alias
remote_base = ~/nscc_submit
password_env = MYPASS_XL                ; env var that holds your password
; password = your-password              ; discouraged, see below
```

Security notes:

- **Never commit or share `~/.nscc/config` if it contains a `password` line**
  (the file is chmod 600, but the env-var route is safer — the password then
  lives only in your shell profile).
- The same for `MYPASS_XL` in `~/.zshrc`: it is per-machine, per-user.
- `~/.nscc/history.log` and job logs may contain paths/output — fine to
  share in debugging, but they are personal artifacts.

### Large data

For datasets bigger than the local disk, don't route them through your
laptop:

- `nscc fetch <url> <project>` downloads directly on the NSCC login node
  (resumable via `wget -c`), into `~/nscc_submit/<project>/data/`. Your
  jobs read it from there.
- `nscc pull <remote-path>` brings back only the results you need.
- Data already on another server can be moved server-to-server by running
  rsync/scp inside `nscc ssh` — again bypassing the local machine.
