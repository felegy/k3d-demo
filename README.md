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
  --ip-range=172.28.1.0/24 `
  k3d
```

```bash
#!/usr/bin/env bash
docker network create \
  --driver=bridge \
  --subnet=172.28.0.0/16 \
  --ip-range=172.28.1.0/24 \
  k3d
```
**Seed secrets**

```bash
echo "postgres" > ./.pg/root_passwd.secret
echo "k3d" > ./.pg/k3d_passwd.secret
echo "kong" > ./.pg/kong_passwd.secret
echo "harbor" > ./.pg/harbor_passwd.secret
```

> **Now start devcontainer**
> 
> In VScode:
> 
> `> Dev Containers: Reopen in Contsainer`


**Deploy cluster**

```console
$ k3d cluster create --config .\k3d-config.yaml --registry-config .\registries.yaml

INFO[0000] Using config file .\k3d-config.yaml (k3d.io/v1alpha5#simple)
INFO[0000] Prep: Network
INFO[0000] Re-using existing network 'k3d' (39106b5a4763412dcaf8a343c6846f1b0de46adc350280d6840eaa6428a7d8ea)
INFO[0000] Created image volume k3d-k3s-default-images
INFO[0000] Starting new tools node...
INFO[0000] Creating initializing server node
INFO[0000] Creating node 'k3d-k3s-default-server-0'
INFO[0000] Starting Node 'k3d-k3s-default-tools'
INFO[0001] Creating node 'k3d-k3s-default-server-1'
INFO[0002] Creating node 'k3d-k3s-default-server-2'
...
...
INFO[0019] Cluster 'k3s-default' created successfully!
```

## Get cluster config

```console
$ cp $(k3d kubeconfig write) ./.kube/config
```

## Check cluster

```console
$ kubectl get nodes

NAME                       STATUS   ROLES                  AGE   VERSION
k3d-k3s-default-agent-2    Ready    <none>                 18m   v1.25.12+k3s1
k3d-k3s-default-server-1   Ready    control-plane,master   18m   v1.25.12+k3s1
k3d-k3s-default-server-2   Ready    control-plane,master   18m   v1.25.12+k3s1
k3d-k3s-default-server-0   Ready    control-plane,master   18m   v1.25.12+k3s1
k3d-k3s-default-agent-0    Ready    <none>                 18m   v1.25.12+k3s1
k3d-k3s-default-agent-1    Ready    <none>                 18m   v1.25.12+k3s1
```
