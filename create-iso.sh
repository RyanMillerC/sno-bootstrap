#!/bin/bash
#
# Create custom ISO for SNO deployment
#

set -e

# Fix RHEL 9
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

if [[ ! -f ./install-config.yaml ]] ; then
    >&2 echo "ERROR: ./install-config.yaml not found. See README.md for" \
             "script usage."
    exit 1
fi

# Hack to get cluster name from install-config.yaml
CLUSTER_NAME=$(grep -A 1 'metadata:' install-config.yaml \
                 | tail -n 1 \
                 | cut -d ':' -f 2 \
                 | xargs)
OUTPUT_DIR="./output/${CLUSTER_NAME}"
OCP_VERSION="latest"

if [[ -d $OUTPUT_DIR ]] ; then
    >&2 echo "ERROR: $OUTPUT_DIR exists from previous run. Remove it before" \
             "running again!"
    exit 1
fi

# Download openshift-install if it's not present
if [[ ! -f ./openshift-install ]] ; then
    echo "./openshift-install not present; Downloading openshift-install..."
    curl -L -o openshift-install-linux.tar.gz \
        "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OCP_VERSION/openshift-install-linux.tar.gz"
    echo "Unpacking openshift-install..."
    tar -zxf openshift-install-linux.tar.gz openshift-install
    rm openshift-install-linux.tar.gz
    chmod +x openshift-install
else
    echo "./openshift-install present; Using existing executable"
fi

# Download RHCOS ISO if it's not present
if [[ ! -f ./rhcos.x86_64.iso ]] ; then
    echo "./rhcos.x86_64.iso not present; Downloading RHCOS image..."
    curl -L -o rhcos.x86_64.iso \
        "https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/$OCP_VERSION/rhcos-live.x86_64.iso"
else
    echo "./rhcos.x86_64.iso present; Using existing RHCOS image"
fi

echo "Generating ignition config from install-config.yaml..."
mkdir -p "$OUTPUT_DIR"
cp install-config.yaml "$OUTPUT_DIR"
./openshift-install --dir="$OUTPUT_DIR" create single-node-ignition-config

echo "Copying RHCOS image..."
cp rhcos.x86_64.iso "${OUTPUT_DIR}/rhcos_${CLUSTER_NAME}.x86_64.iso"

echo "Embedding igntion config into RHCOS image..."
podman run \
  --privileged \
  --pull always \
  --rm \
  -v /dev:/dev \
  -v /run/udev:/run/udev \
  -v $PWD:/data \
  -w /data \
  quay.io/coreos/coreos-installer:release \
  iso \
  ignition \
  embed \
  -fi \
  "${OUTPUT_DIR}/bootstrap-in-place-for-live-iso.ign" \
  "${OUTPUT_DIR}/rhcos_${CLUSTER_NAME}.x86_64.iso"

echo "Complete!"
echo
echo "Installer Output (kubeconfig is here!): $OUTPUT_DIR"
echo "ISO Path: ${OUTPUT_DIR}/rhcos_${CLUSTER_NAME}.x86_64.iso"
echo
echo "Boot machine using the ISO above. After booting, monitor progress with:"
echo "$ ./openshift-install --dir=\"${OUTPUT_DIR}\" wait-for bootstrap-complete"
