#!/bin/bash
#
# Create custom ISO for SNO deployment
#

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
