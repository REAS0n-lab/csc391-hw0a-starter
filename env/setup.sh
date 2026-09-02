#!/bin/bash
# Build a Python environment for the course on DEAC.
#
# Run once. Afterwards, job scripts pick the environment up through
# deac/site.sh, so you do not need to activate anything by hand.

set -euo pipefail
cd "$(dirname "$0")/.."
source deac/site.sh
deac_load_cpu

VENV="${CSC391_VENV:-$HOME/.venvs/csc391}"
python3 -m venv "$VENV"
source "$VENV/bin/activate"
python3 -m pip install --upgrade pip
python3 -m pip install -r env/requirements.txt

echo
echo "Environment built at $VENV"
echo "Add this line to deac_load_cpu in deac/site.sh so that jobs use it:"
echo "  source $VENV/bin/activate"
