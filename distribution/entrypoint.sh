#!/bin/sh
set -e

# Milvus Lite is not supported on ppc64le, so we disable it for Power arch
ARCH=$(uname -m)
if [ "$ARCH" = "ppc64le" ]; then
  unset ENABLE_MILVUS_LITE
  echo "Architecture: $ARCH - Milvus Lite disabled (not supported on ppc64le)"
elif [ -z "$ENABLE_MILVUS_LITE" ]; then
  export ENABLE_MILVUS_LITE=true
  echo "Architecture: $ARCH - Enabling Milvus Lite by default (ENABLE_MILVUS_LITE=true)"
else
  echo "Architecture: $ARCH - Using existing ENABLE_MILVUS_LITE=$ENABLE_MILVUS_LITE"
fi

# Resolve config path
if [ -n "$RUN_CONFIG_PATH" ] && [ -f "$RUN_CONFIG_PATH" ]; then
  CONFIG="$RUN_CONFIG_PATH"
elif [ -n "$DISTRO_NAME" ]; then
  CONFIG="$DISTRO_NAME"
else
  CONFIG="/opt/app-root/config.yaml"
fi

# Optionally wrap with opentelemetry-instrument when OTEL_SERVICE_NAME is set.
# Logs export is intentionally omitted by default; set OTEL_LOGS_EXPORTER=otlp to enable.
if [ -n "$OTEL_SERVICE_NAME" ]; then
  exec opentelemetry-instrument \
    --traces_exporter=otlp \
    --metrics_exporter=otlp \
    --service_name="$OTEL_SERVICE_NAME" \
    -- \
    llama stack run "$CONFIG" "$@"
fi

exec llama stack run "$CONFIG" "$@"
