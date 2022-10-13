# Kong Ingress Controller

## Deploy Kong

Minimal kong deployment:

```
kubectl apply -f https://bit.ly/k4k8s
```

## Create test service (nginx)

For testing now creating an nginx deployment and service to `default` namespace:

```
kubectl create deployment nginx --image=nginx

kubectl create service clusterip nginx --tcp=80:80
```

## Expose test service

For local access of nginx service creating ingress expose (via Kong):

```yaml
# kong/nginx-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
spec:
  ingressClassName: kong
  rules:
  - host: nginx.hvgdev.website
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
```
And deploy thath:

```
kubectl apply -f kong/nginx-ingress.yaml
```

## Testing

Finding the external IP address of the `kong` service (via MetalLB):

```
$ kubectl get services --namespace kong
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kong-proxy                LoadBalancer   10.43.88.93     172.28.0.1    80:30314/TCP,443:32582/TCP   59m
kong-validation-webhook   ClusterIP      10.43.101.103   <none>        443/TCP                      59m
```
> `kong` external IP: `172.28.0.1` 🐵

## Testing kong access

According to the above, kong is probably accesible at `172.28.0.1` via ports `80` and `443`:

**Kong over HTTP**

```
$ curl 172.28.0.1
{"message":"no Route matched with those values"}
```

**Kong over HTTPS**

```
$ curl -k https://172.28.0.1
{"message":"no Route matched with those values"}
```

🙈 OK `konk` are accesible ✔️

## Testing the nginx service via `kong` with hostname

Based on the ingress deployment, nginx is probably available on http host `nginx.hvgdev.website`:

```
http get 172.28.0.1 host:nginx.hvgdev.website --print hH

GET / HTTP/1.1
Accept-Encoding: gzip, deflate
Accept: */*
Connection: keep-alive
User-Agent: HTTPie/3.2.1
host: nginx.hvgdev.website

HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: 615
Connection: keep-alive
Server: nginx/1.23.1
Date: Thu, 13 Oct 2022 16:15:03 GMT
Last-Modified: Tue, 19 Jul 2022 14:05:27 GMT
ETag: "62d6ba27-267"
Accept-Ranges: bytes
X-Kong-Upstream-Latency: 0
X-Kong-Proxy-Latency: 1
Via: kong/3.0.0
```

🎉 Awesome ✔️

DONE
The `kong` ingress controller working properly.




