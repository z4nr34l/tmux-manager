# tmux-manager

Interactive tmux session manager for SSH connections. Select existing sessions or create new ones with custom names.

## Preview

```
╔════════════════════════════════════╗
║      tmux session manager          ║
╚════════════════════════════════════╝

Existing sessions:
─────────────────────────────────────
  1) dev - 3 windows
  2) server - 1 windows (attached)
  3) logs - 2 windows
─────────────────────────────────────

Options:
  1-3) Attach to existing session
  n) Create new session with custom name
  q) Quit (no tmux)

Select option:
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/install.sh | bash
```

## Features

- Lists all existing tmux sessions with window count
- Shows which sessions are currently attached
- Attach to any session by number
- Create new sessions with custom names
- Skip tmux entirely with quit option
- Auto-starts on SSH login (optional)

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/z4nr34l/tmux-manager/main/uninstall.sh | bash
```

## License

MIT
