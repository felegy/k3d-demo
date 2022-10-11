# k3d-demo

## k3d install

**Windows**: `choco install k3d -y`

**Linux / MacOS**: `brew install k3d`

<https://k3d.io/v5.4.6/#install-script>

**Github**: <https://github.com/k3d-io/k3d>

**Site**: <https://k3d.io>

## k3d cluster deploy

**Create docker network**

```powershell
#!/usr/bin/env pwsh
docker network create `
  --driver=bridge `
  --subnet=172.28.0.0/16 `
  --ip-range=172.28.5.0/24 `
  k3d
```

```bash
#!/usr/bin/env bash
docker network create \
  --driver=bridge \
  --subnet=172.28.0.0/16 \
  --ip-range=172.28.5.0/24 \
  k3d
```

**Deploy cluster**

```powershell
#!/usr/bin/env pwsh
k3d cluster create `
  --network k3d `
  --servers 2 `
  --agents 3 `
  --no-lb `
  --k3s-arg "--disable=traefik@servers:0" `
  --k3s-arg "--disable=traefik@servers:1" `
  --k3s-arg "--disable=servicelb@servers:0" `
  --k3s-arg "--disable=servicelb@servers:1"
```

```bash
#!/usr/bin/env bash
k3d cluster create \
  --network k3d \
  --servers 2 \
  --agents 3 \
  --no-lb \
  --k3s-arg "--disable=traefik@servers:0" \
  --k3s-arg "--disable=traefik@servers:1" \
  --k3s-arg "--disable=servicelb@servers:0" \
  --k3s-arg "--disable=servicelb@servers:1"
```
## Get cluster config

```
cp $(k3d kubeconfig write) ./.kube/config
```

> **Now start devcontainer**
> 
> In VScode:
> 
> `> Dev Containers: Reopen in Contsainer`

## Check cluster

```
kubectl get nodes
```

**The command output** (like this):

```
k3d-k3s-default-agent-0    Ready    <none>                      28m   v1.24.4+k3s1
k3d-k3s-default-agent-1    Ready    <none>                      28m   v1.24.4+k3s1
k3d-k3s-default-agent-2    Ready    <none>                      28m   v1.24.4+k3s1
k3d-k3s-default-server-0   Ready    control-plane,etcd,master   29m   v1.24.4+k3s1
k3d-k3s-default-server-1   Ready    control-plane,etcd,master   28m   v1.24.4+k3s1
```

