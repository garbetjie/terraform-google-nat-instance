#!/usr/bin/env bash

set -e -o pipefail

# Execute startup scripts.
for name in iptables sysctl proxy; do
  curl -H 'Metadata-Flavor: Google' "http://metadata.google.internal/computeMetadata/v1/instance/attributes/startup-script-${name}-sh" | bash
done
