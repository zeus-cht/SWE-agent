#!/bin/bash

set -euo pipefail

# Minimal install script for the OpenViking tool bundle.
# We intentionally keep dependencies small and rely on the official PyPI package.

if ! command -v python &>/dev/null && ! command -v python3 &>/dev/null; then
  echo "Python interpreter not found (python/python3). Please install Python 3.9+." >&2
  exit 1
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"

echo "[openviking] Using Python interpreter: ${PYTHON_BIN}"
echo "[openviking] Installing openviking Python package from PyPI..."

"${PYTHON_BIN}" -m pip install --quiet --upgrade openviking

echo "[openviking] Installation completed."

