# SNO (Single-Node OpenShift) Bootstrap

Generate custom ISO with embedded ignition config to bootstrap a SNO
deployment. `install-config.yaml` in, custom ISO out.

Repo automates [these
steps](https://docs.openshift.com/container-platform/4.10/installing/installing_sno/install-sno-installing-sno.html#generating-the-discovery-iso-manually_install-sno-installing-sno-with-the-assisted-installer)
outlined in the OpenShift documentation.

## Generate ISO

Prior to starting you'll need to know:

* Your JSON pull secret
* Your SSH public key (optional)

To generate the ISO:

```bash
$ cp install-config.template.yaml install-config.yaml
# Edit install-config.yaml; Replace sections marked "REPLACE_ME"
$ ./create-iso.sh
```
