#!/bin/bash
#
# Create custom ISO for SNO deployment
#

set -e

if [[ ! -f ./install-config.yaml ]] ; then
    >&2 echo "./install-config.yaml not found. See README.md for script usage."
    exit 1
fi

# Hack to get cluster name from install-config.yaml
CLUSTER_NAME=$(grep -A 1 'metadata:' install-config.yaml \
                 | tail -n 1 \
                 | cut -d ':' -f 2 \
                 | xargs)

if [[ -d ./$CLUSTER_NAME ]] ; then
    >&2 echo "./$CLUSTER_NAME exists from previous run. Remove it before" \
             "running again!"
    exit 1
fi

# Download openshift-install if it's not present
if [[ ! -f ./openshift-install ]] ; then
    echo "./openshift-install not present; Downloading openshift-install..."
    curl -L -o openshift-install-linux.tar.gz "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz"
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
    curl -L -o coreos-installer "https://mirror.openshift.com/pub/openshift-v4/clients/coreos-installer/latest/coreos-installer_amd64"
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
mkdir "$CLUSTER_NAME"
cp install-config.yaml "$CLUSTER_NAME"
./openshift-install --dir="$CLUSTER_NAME" create single-node-ignition-config

echo "Copying RHCOS image..."
cp rhcos.x86_64.iso "${CLUSTER_NAME}/rhcos_${CLUSTER_NAME}.x86_64.iso"

echo "Embedding igntion config into RHCOS image..."
./coreos-installer \
    iso \
    ignition \
    embed \
    -fi "${CLUSTER_NAME}/bootstrap-in-place-for-live-iso.ign" \
    "${CLUSTER_NAME}/rhcos_${CLUSTER_NAME}.x86_64.iso"

echo "Complete!"
