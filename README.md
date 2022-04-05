# SNO (Single-Node OpenShift) Bootstrap

Generate custom ISO with embedded ignition config to bootstrap a SNO
deployment. Basically: `install-config.yaml -> custom.iso`.

## Generate ISO

```bash
$ cp install-config.template.yaml install-config.yaml
# Edit install-config.yaml; Replace sections marked "REPLACE_ME"
$ ./create-iso.sh
```
