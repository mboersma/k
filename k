#!/usr/bin/env bash
set +x

KX_PATH="$HOME/.kx"
mkdir -p "$KX_PATH/cache"

# Attempt to load the server version from cache
if [ ! -z "$KUBECONFIG" ]; then
  KUBECONFIG_HASH=$(echo "$KUBECONFIG" | sha256sum | cut -c1-5)
  VERSION_CACHE_FILE="$KX_PATH/cache/$KUBECONFIG_HASH"
  TARGET_VERSION=$(cat "$VERSION_CACHE_FILE" 2> /dev/null)
fi

# Get the server version from the server if not cached
if [ -z "$TARGET_VERSION" ]; then
  TARGET_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion')
fi

# Fill the cache if possible
if [ ! -z "$KUBECONFIG" ]; then
  echo "$TARGET_VERSION" > "$VERSION_CACHE_FILE"
fi

TARGET=$KX_PATH/kubectl-$TARGET_VERSION

if [ ! -f $TARGET ]; then
  cd "$KX_PATH"
  curl -LO "https://storage.googleapis.com/kubernetes-release/release/$TARGET_VERSION/bin/darwin/amd64/kubectl"
  mv $KX_PATH/kubectl $TARGET
  chmod +x $TARGET
fi

$TARGET "$@"