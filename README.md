# SNO (Single-Node OpenShift) Bootstrap

Generate custom ISO with embedded ignition config to bootstrap a SNO
deployment. `install-config.yaml` in, custom ISO out.

Repo automates [these
steps](https://docs.openshift.com/container-platform/4.10/installing/installing_sno/install-sno-installing-sno.html#generating-the-discovery-iso-manually_install-sno-installing-sno-with-the-assisted-installer)
outlined in the OpenShift documentation.

**This script was built for RHEL 8. I haven't tested other RHEL versions, other
distros, or MacOS.**

## Generate ISO

No prerequisites are required to run `create-iso.sh`. The script will download
*openshift-install*, *coreos-installer*, and the RHCOS live image. If you run
the script multiple times, it will used the previously downloaded copies of the
installers/ISO.

Prior to starting you'll need to know:

* Your JSON pull secret
* Your SSH public key (optional)

To generate the ISO:

```bash
$ cp install-config.template.yaml install-config.yaml
# Edit install-config.yaml; Replace sections marked "REPLACE_ME"
$ ./create-iso.sh
```
