After you made your variables file with api keys and everything you need, you can proceed to use like this.

## validate your template

```bash
packer validate -var-file=variables.pkrvars.hcl ubuntu-server.pkr.hcl
```

## build your template

```bash
packer build -var-file=variables.pkrvars.hcl ubuntu-server.pkr.hcl
```
