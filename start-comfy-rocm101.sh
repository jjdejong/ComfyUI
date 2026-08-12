#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
VENV="$ROOT/venv-therock-rocm101"
SITE="$VENV/lib/python3.13/site-packages"

export VIRTUAL_ENV="$VENV"
export PATH="$VENV/bin:$PATH"
export LD_LIBRARY_PATH="$SITE/_rocm_sdk_core/lib:$SITE/_rocm_sdk_libraries/lib:$SITE/_rocm_sdk_devel/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export HIP_VISIBLE_DEVICES="${HIP_VISIBLE_DEVICES:-0}"
export PYTORCH_ALLOC_CONF="${PYTORCH_ALLOC_CONF:-garbage_collection_threshold:0.8,max_split_size_mb:512}"
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
unset TORCH_DISABLE_NATIVE_JIT
export AMD_LOG_LEVEL=0

exec "$VENV/bin/python" "$ROOT/main.py" \
  --use-pytorch-cross-attention \
  --bf16-vae \
  --disable-mmap \
  --cache-ram 8 16 \
  --vram-headroom 8 \
  --preview-method taesd \
  --listen 0.0.0.0 \
  --port 8188 \
  "$@"
