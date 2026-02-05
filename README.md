# tmux-manager

Interactive TUI for managing tmux sessions. Navigate with arrow keys, select with Enter.

## Preview

```
        ╭────────────────────┤ tmux sessions ├─────────────────────╮
        │                                                          │
        │    dev                              3w                   │
        │    server                           1w ●                 │
        │  ➤ logs                             2w                   │
        │    + New session                                         │
        │    Skip (no tmux)                                        │
        │                                                          │
        │  ↑↓/jk navigate  Enter select  q quit                    │
        ╰──────────────────────────────────────────────────────────╯
```

## Installation

### Interactive

```bash
curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/install.sh | bash
```

### Non-interactive

```bash
# Full install with auto-start
curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/install.sh | bash -s -- --bashrc -y

# Without .bashrc modification
curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/install.sh | bash -s -- --no-bashrc -y
```

### Installer Options

| Option | Description |
|--------|-------------|
| `--bashrc` | Enable auto-start on SSH login |
| `--no-bashrc` | Don't modify .bashrc |
| `--path-export` | Add ~/.local/bin to PATH |
| `--no-path-export` | Don't modify PATH |
| `-y, --yes` | Accept defaults (non-interactive) |

## Controls

| Key | Action |
|-----|--------|
| `↑` / `k` | Move up |
| `↓` / `j` | Move down |
| `Enter` | Select |
| `q` / `Esc` | Quit |

## Features

- Arrow key navigation
- Shows session window count
- Indicates attached sessions (●)
- Create new session with custom or auto-generated name
- Centered TUI box

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/uninstall.sh | bash
```

## License

MIT
