#!/bin/sh
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Entrypoint: Qualcomm EDL Container Runtime Orchestrator
# Description: Prepares environment, permissions, and executes commands.
# ----------------------------------------------------------------
# Repository: https://github.com/boardport/edl-container
# Author: BoardPort Community <boardport@proton.me>
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

set -o nounset
set -o errexit

# ----------------------------------------------------------------
# Environments
# ----------------------------------------------------------------

EDL_DIR=${EDL_DIR:-/opt/edl}
EDL_DUMP_DIR=${EDL_DUMP_DIR:-/opt/edl/dumps}
EDL_DUMP_UID=${EDL_DUMP_UID:-1000}

# ----------------------------------------------------------------
# Runtime
# ----------------------------------------------------------------

# Execute entrypoint scripts
if [ -d '/docker-entrypoint.d' ]; then
  for s in $(find '/docker-entrypoint.d' -maxdepth 1 -name '*.sh' | sort); do
    if [ -x "$s" ]; then
      echo "[INFO] Docker entrypoint: Executing script ${s##*/}"
      "$s"
    fi
  done
fi

# Ensure dumps directory exists
mkdir -p "$EDL_DUMP_DIR" || true

# Execute CMD
case "${1:-}" in
  sh|bash|/bin/sh|/bin/bash|adb|fastboot|python|python3)
    exec "$@"
    ;;
  edl)
    shift
    echo "[INFO] Docker entrypoint: Executing python $EDL_DIR/edl.py $*"
    set +e
    python "$EDL_DIR/edl.py" "$@"
    EXIT_CODE=$?
    set -e
    chown -R "${EDL_DUMP_UID}:${EDL_DUMP_UID}" "$EDL_DUMP_DIR" 2>/dev/null || true
    exit $EXIT_CODE
    ;;
  *)
    echo "[INFO] Docker entrypoint: Executing python $EDL_DIR/edl.py $*"
    set +e
    python "$EDL_DIR/edl.py" "$@"
    EXIT_CODE=$?
    set -e
    chown -R "${EDL_DUMP_UID}:${EDL_DUMP_UID}" "$EDL_DUMP_DIR" 2>/dev/null || true
    exit $EXIT_CODE
    ;;
esac
