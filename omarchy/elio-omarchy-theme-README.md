# elio ↔ Omarchy theme integration — install on another system

Makes the `elio` terminal file manager follow the active Omarchy theme
automatically, via Omarchy Quattro's user-template system.

## What you need to copy

One file: **`elio-omarchy-theme-install.sh`**

It is fully self-contained — the theme template and the uninstaller are
embedded inside it. No network access, no package installs, no repo clone.

```bash
# from system 1
scp ~/.local/bin/elio-omarchy-theme-install.sh system2:~/
```

## Fastest path (no Claude Code needed)

```bash
chmod +x ~/elio-omarchy-theme-install.sh
~/elio-omarchy-theme-install.sh --check      # preflight only, changes nothing
~/elio-omarchy-theme-install.sh --dry-run    # show the plan
~/elio-omarchy-theme-install.sh              # install + self-verify
```

It refuses to touch anything if preflight fails, backs up any existing
regular `~/.config/elio/theme.toml`, and verifies its own output
(no leftover `{{ }}`, all values 6-digit hex, parses as valid TOML).

To undo: `~/.local/bin/elio-omarchy-theme-uninstall.sh` (`--dry-run` to preview).

---

## Prompt to feed Claude Code on system 2

Paste this verbatim:

> I have a self-contained installer at `~/elio-omarchy-theme-install.sh` that
> makes the `elio` file manager follow the active Omarchy theme using Omarchy
> Quattro's user-template system. Please install and verify it.
>
> Constraints:
> - Touch ONLY paths under `~/.config` and `~/.local`. Nothing in
>   `/usr/share/omarchy`, `/etc`, or any pacman-owned path.
> - Do not install packages or run pacman/paru without asking me first.
> - Do not edit the installer's embedded template unless a check actually fails.
>
> Steps:
> 1. Run `~/elio-omarchy-theme-install.sh --check` and show me the output.
>    If any check fails, STOP and report — do not try to work around it.
> 2. Run `~/elio-omarchy-theme-install.sh --dry-run`, then run it for real.
> 3. Verify beyond the script's own checks:
>    - `~/.local/state/omarchy/current/theme/elio.toml` exists, contains real
>      hex values, and has no un-substituted `{{ }}`.
>    - elio renders WITHOUT falling back to its built-in defaults. Invalid TOML
>      fails silently, so check the actual rendered colors — run elio in a sized
>      tmux pane and read the ANSI truecolor codes:
>      ```
>      tmux new-session -d -s p -x 120 -y 30 "cd ~; command elio"; sleep 3
>      tmux capture-pane -p -e -t p | grep -oE '[34]8;2;[0-9]+;[0-9]+;[0-9]+' \
>        | sort | uniq -c | sort -rn | head
>      tmux kill-session -t p
>      ```
>      The theme's `foreground`/`accent` (from
>      `~/.local/state/omarchy/current/theme/colors.toml`, converted hex→decimal)
>      should appear. elio's fallback default bg is `#050505` = `5;5;5` — if you
>      see that, it fell back.
>    - Switch to a visually distinct theme (a light one like `flexoki-light` is
>      the strongest test), confirm elio's colors changed, then switch back to
>      the original theme.
> 4. Confirm `~/.local/bin/elio-omarchy-theme-uninstall.sh --dry-run` prints a
>    sane plan.
>
> Report: what changed, any backup paths created, and the exact undo command.

---

## Notes / known behaviour

- **A running elio does not retint.** It reads `theme.toml` once at startup;
  restart it after a theme switch. (Verified: switching themes under a live
  elio produced byte-identical output.)
- **Themes without a `colors.toml`** (typically legacy 2.x-era themes under
  `~/.config/omarchy/themes/`) render no templates at all, so `elio.toml` is
  not generated and the symlink dangles — elio then falls back to its own
  default. Graceful, not a crash. The installer warns which of your themes
  these are.
- **What the template covers:** `[palette]` (27/27 keys, full coverage of
  elio's upstream default), `[preview.code]` (18/18), and the 12
  `[classes.*]` colors. `[extensions.*]`, `[files.*]` and `[directories.*]`
  are deliberately left to elio's built-in defaults — those are brand colors
  (Rust orange, Docker blue) and icons that shouldn't chase the terminal
  palette.
- **Color collisions are expected.** Most Omarchy themes define
  `bright_magenta == magenta`, `bright_cyan == cyan`, `bright_red == red`, so
  `parameter`/`keyword`, `operator`/`tag` and `invalid`/`macro` may render
  identically. The template uses the `bright_*` variants anyway so themes that
  *do* distinguish them get the distinction.
- **Verified against** Omarchy 4.0.0.alpha and elio 1.11.2 and 1.12.0 (theme
  schema unchanged between those elio versions).
