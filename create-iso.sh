#!/bin/bash
#
# Create custom ISO for SNO deployment
#

set -e

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

if [[ -d $OUTPUT_DIR ]] ; then
    >&2 echo "ERROR: $OUTPUT_DIR exists from previous run. Remove it before" \
             "running again!"
    exit 1
fi

# Download openshift-install if it's not present
if [[ ! -f ./openshift-install ]] ; then
    echo "./openshift-install not present; Downloading openshift-install..."
    curl -L -o openshift-install-linux.tar.gz \
        "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz"
    echo "Unpacking openshift-install..."
    tar -zxf openshift-install-linux.tar.gz openshift-install
    rm openshift-install-linux.tar.gz
    chmod +x openshift-install
else
    echo "./openshift-install present; Using existing executable"
fi

# Download coreos-installer if it's not present
if [[ ! -f ./coreos-installer ]] ; then
    echo "./coreos-installer not present; Downloading coreos-installer..."
    curl -L -o coreos-installer \
        "https://mirror.openshift.com/pub/openshift-v4/clients/coreos-installer/latest/coreos-installer_amd64"
    chmod +x coreos-installer
else
    echo "./coreos-installer present; Using existing executable"
fi

# Download RHCOS ISO if it's not present
if [[ ! -f ./rhcos.x86_64.iso ]] ; then
    echo "./rhcos.x86_64.iso not present; Downloading RHCOS image..."
    curl -L -o rhcos.x86_64.iso \
        "https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-live.x86_64.iso"
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
./coreos-installer \
    iso \
    ignition \
    embed \
    -fi "${OUTPUT_DIR}/bootstrap-in-place-for-live-iso.ign" \
    "${OUTPUT_DIR}/rhcos_${CLUSTER_NAME}.x86_64.iso"

echo "Complete!"
echo
echo "Installer Output (kubeconfig is here!): $OUTPUT_DIR"
echo "ISO Path: ${OUTPUT_DIR}/rhcos_${CLUSTER_NAME}.x86_64.iso"
echo
echo "Boot machine using the ISO above. After booting, monitor progress with:"
echo "$ ./openshift-install --dir=\"${OUTPUT_DIR}\" wait-for bootstrap-complete"
