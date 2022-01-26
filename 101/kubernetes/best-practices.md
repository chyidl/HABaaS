# Kubernetes Best Practices

## How and why to build small container images

```
1. Alpine Linux is a small and lightweight Linux distribution that is very popular with Docker users because it's compatible with a lot of apps, while still keeping containers small.
```

## Resource requests and limits
* **Requests**
> Requests are what the container is guaranteed to get.

* **Limits**
> make sure a container never goes above a certain value.

```
the limit can never be lower than the request.
```

||CPU|Memory|
|:--|:--|:---|
|Requests| 0.1 Cores| None|
| Limits| None| None|

  - cpu
    > CPU resources are defined in millicores.
  - Memory
    > Memory resources are defined in bytes.


* **ResourceQuotas** -- Namespace
```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: demo
spec:
  hard:
    requests.cpu: 500m
    requests.memory: 100Mib
    limits.cpu: 700m
    limits.memory: 500Mib
```

* **LimitRanges**
> help prevent people from creating super tiny or super large containers inside the Namespace.
```
apiVersion: v1
kind: LimitRange
metadata:
  name: demo
spec:
  limits:

# set up the default limits for a container in a pod
- default:
    cpu: 600m
    memory: 100Mib

# 
  defaultRequest:
    cpu: 100m
    memory: 50Mib
  max:
    cpu: 1000m
    memory: 200Mib
  min:
    cpu: 10m
    memory: 10Mib
  type: Container
```

* The lifecycle of a Kubernetes Pod
```

```
