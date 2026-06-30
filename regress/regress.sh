#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  regress.sh [build-for-test args...] [--] [run_regress_gfarm2fs_with_mount.sh args...]

Environment:
  BUILD_SCRIPT    build_gfarm2fs_for_test.sh path (default: same directory as this script)
  RUN_SCRIPT      run_regress_gfarm2fs_with_mount.sh path (default: same directory as this script)
  GFARM2FS_CMD    gfarm2fs command to run; defaults to the built test binary
EOF
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
build_script=${BUILD_SCRIPT:-"$script_dir/build_gfarm2fs_for_test.sh"}
run_script=${RUN_SCRIPT:-"$script_dir/run_regress_gfarm2fs_with_mount.sh"}

build_args=()
run_args=()
seen_sep=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --)
      seen_sep=1
      shift
      continue
      ;;
  esac

  if [[ $seen_sep -eq 0 ]]; then
    build_args+=("$1")
  else
    run_args+=("$1")
  fi
  shift
done

build_dir="$("$build_script" "${build_args[@]}")"
gfarm2fs_cmd=${GFARM2FS_CMD:-"$build_dir/gfarm2fs"}

if [[ ! -x "$gfarm2fs_cmd" ]]; then
  echo "regress.sh: gfarm2fs command not found or not executable: $gfarm2fs_cmd" >&2
  exit 1
fi

GFARM2FS_CMD="$gfarm2fs_cmd" "$run_script" "${run_args[@]}"
