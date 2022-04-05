#!/bin/bash
#
# Create custom ISO for SNO deployment
#

# Download openshift-install if it's not present
if [[ ! -d ./openshift-install ]] ; then
    echo "./openshift-install not present; Downloading openshift-install..."
    mkdir ./openshift-install
    cd ./openshift-install
    curl -s -o openshift-install-linux.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz
    echo "Unpacking openshift-install..."
    tar -zxf openshift-install-linux.tar.gz
    chmod +x openshift-install
    cd ..
else
    echo "./openshift-install present; Using existing executable"
fi

# Download coreos-installer if it's not present
if [[ ! -d ./coreos-installer ]] ; then
    echo "./coreos-installer not present; Downloading coreos-installer..."
    curl -s -o coreos-installer https://mirror.openshift.com/pub/openshift-v4/clients/coreos-installer/latest/coreos-installer_amd64
    chmod +x coreos-installer
else
    echo "./coreos-install present; Using existing executable"
fi

# Download RHCOS ISO if it's not present
if [[ ! -f ./rhcos.x86_64.iso ]] ; then
    echo "./rhcos.x86_64.iso not present; Downloading RHCOS image..."
    ISO_URL=$(./openshift-install/openshift-install coreos print-stream-json \
        | grep location | grep x86_64 | grep iso | cut -d\" -f4)
    curl -L -s -o rhcos.x86_64.iso "$ISO_URL"
else
    echo "./rhcos.x86_64.iso present; Using existing RHCOS image"
fi
