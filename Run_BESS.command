#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Run_BESS.command  —  double-click me on Mac to open the BESS control panel
#
#  What this does:
#   1. Changes into the project directory (the folder containing this file)
#   2. Activates the .venv if it exists
#   3. Installs / upgrades the package in editable mode if needed
#   4. Launches bess_control.py (interactive menu-driven CLI)
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── 1. Resolve project root (same folder as this script) ──────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
echo ""
echo "  ⚡  BESS ML — Starting control panel"
echo "  📁  Project: $SCRIPT_DIR"
echo ""

# ── 2. Activate virtual environment ───────────────────────────────────────
if [[ -f ".venv/bin/activate" ]]; then
    # shellcheck disable=SC1091
    source ".venv/bin/activate"
    echo "  ✓  Virtual environment activated (.venv)"
elif [[ -f "venv/bin/activate" ]]; then
    # shellcheck disable=SC1091
    source "venv/bin/activate"
    echo "  ✓  Virtual environment activated (venv)"
else
    echo "  ⚠  No .venv found — using system Python."
    echo "     Run:  python3 -m venv .venv && source .venv/bin/activate && pip install -e .[dev]"
    echo "     to set up the environment."
    echo ""
fi

PYTHON="$(command -v python3 || command -v python)"
echo "  🐍  Python: $PYTHON  ($(${PYTHON} --version 2>&1))"
echo ""

# ── 3. Ensure bess-ml package is installed (editable) ─────────────────────
if ! "${PYTHON}" -c "import bess_ml" 2>/dev/null; then
    echo "  📦  bess_ml package not found — installing in editable mode …"
    "${PYTHON}" -m pip install -e ".[dev]" --quiet
    echo "  ✓  Installed."
    echo ""
fi

# ── 4. Check for Rich (nice-to-have, not required) ────────────────────────
if ! "${PYTHON}" -c "import rich" 2>/dev/null; then
    echo "  ℹ   Tip: install 'rich' for a prettier interface: pip install rich"
    echo ""
fi

# ── 5. Launch the control panel ───────────────────────────────────────────
exec "${PYTHON}" -m bess_ml.cli "$@"
