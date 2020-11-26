### execution date: Thu Nov 26 01:34:33 UTC 2020
 
### microk8s snap version:
microk8s          v1.19.3    1791   1.19/stable      canonical*         classic
 
### ubuntu version:
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.1 LTS
Release:	20.04
Codename:	focal
 
### docker version:
Client: Docker Engine - Community
 Version:           19.03.13
 API version:       1.40
 Go version:        go1.13.15
 Git commit:        4484c46d9d
 Built:             Wed Sep 16 17:02:52 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.13
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       4484c46d9d
  Built:            Wed Sep 16 17:01:20 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.3.7
  GitCommit:        8fba4e9a7d01810a393d5d25a3621dc101981175
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
 
### kata-runtime version:
kata-runtime  : 1.12.0-rc0
   commit   : <<unknown>>
   OCI specs: 1.0.1-dev
 
### kata-runtime check:
System is capable of running Kata Containers
 

### check existing container runtimes on Ubuntu host:
-rwxr-xr-x 1 root root 9.7M Sep  9 15:40 /bin/runc
-rwxr-xr-x 1 root root 31M Oct 22 16:51 /bin/kata-runtime

### check available docker runtimes: 
 Runtimes: kata-runtime runc

### test use of kata-runtime with alpine: 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
c970b27f359c        alpine              "sh"                2 seconds ago       Up Less than a second                          kata-alpine
758b44d2f301        busybox             "uname -a"          11 seconds ago      Exited (0) 8 seconds ago                       fervent_galois
        "Name": "/kata-alpine",
        "Id": "c970b27f359c9892a20135057bba9077eadae2764812983ef2792a98edad9f9d",
            "Runtime": "kata-runtime",

### install microk8s:
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    ha-cluster           # Configure high availability on the current node
  disabled:
    ambassador           # Ambassador API Gateway and Ingress
    cilium               # SDN, fast with full network policy
    dashboard            # The Kubernetes dashboard
    dns                  # CoreDNS
    fluentd              # Elasticsearch-Fluentd-Kibana logging and monitoring
    gpu                  # Automatic enablement of Nvidia CUDA
    helm                 # Helm 2 - the package manager for Kubernetes
    helm3                # Helm 3 - Kubernetes package manager
    host-access          # Allow Pods connecting to Host services smoothly
    ingress              # Ingress controller for external access
    istio                # Core Istio service mesh services
    jaeger               # Kubernetes Jaeger operator with its simple config
    knative              # The Knative framework on Kubernetes.
    kubeflow             # Kubeflow for easy ML deployments
    linkerd              # Linkerd is a service mesh for Kubernetes and other frameworks
    metallb              # Loadbalancer for your Kubernetes cluster
    metrics-server       # K8s Metrics Server for API access to service metrics
    multus               # Multus CNI enables attaching multiple network interfaces to pods
    prometheus           # Prometheus operator for monitoring and logging
    rbac                 # Role-Based Access Control for authorisation
    registry             # Private image registry exposed on localhost:32000
    storage              # Storage class; allocates storage from host directory

### check container runtime on microk8s snap:
-rwxr-xr-x 1 root root 15M Nov  6 12:06 /snap/microk8s/current/bin/runc

### TEST WITH RUNC


### test microk8s with helloworld-go & autoscale-go: 
service/helloworld-go created
deployment.apps/helloworld-go-deployment created
service/autoscale-go created
deployment.apps/autoscale-go-deployment created
NAME                                       READY   STATUS              RESTARTS   AGE
nginx-test                                 0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-l92ls   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-mzzf8   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-r7ckh   0/1     ContainerCreating   0          0s
autoscale-go-deployment-5894658957-5dxtx   0/1     ContainerCreating   0          0s

waiting for ready pods...

NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-5dxtx   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-l92ls   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-r7ckh   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-mzzf8   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1    <none>        443/TCP        2m33s
helloworld-go   NodePort    10.152.183.11   <none>        80:30610/TCP   2m1s
autoscale-go    NodePort    10.152.183.53   <none>        80:31060/TCP   2m

calling helloworld-go...

Hello World: Kata Containers!

calling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...

Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.20 milliseconds.

### re-install microk8s incl kata-runtime: 
microk8s v1.19.3 installed
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    ha-cluster           # Configure high availability on the current node
  disabled:
    ambassador           # Ambassador API Gateway and Ingress
    cilium               # SDN, fast with full network policy
    dashboard            # The Kubernetes dashboard
    dns                  # CoreDNS
    fluentd              # Elasticsearch-Fluentd-Kibana logging and monitoring
    gpu                  # Automatic enablement of Nvidia CUDA
    helm                 # Helm 2 - the package manager for Kubernetes
    helm3                # Helm 3 - Kubernetes package manager
    host-access          # Allow Pods connecting to Host services smoothly
    ingress              # Ingress controller for external access
    istio                # Core Istio service mesh services
    jaeger               # Kubernetes Jaeger operator with its simple config
    knative              # The Knative framework on Kubernetes.
    kubeflow             # Kubeflow for easy ML deployments
    linkerd              # Linkerd is a service mesh for Kubernetes and other frameworks
    metallb              # Loadbalancer for your Kubernetes cluster
    metrics-server       # K8s Metrics Server for API access to service metrics
    multus               # Multus CNI enables attaching multiple network interfaces to pods
    prometheus           # Prometheus operator for monitoring and logging
    rbac                 # Role-Based Access Control for authorisation
    registry             # Private image registry exposed on localhost:32000
    storage              # Storage class; allocates storage from host directory

### TEST WITH KATA-RUNTIME


### test microk8s with helloworld-go & autoscale-go: 
service/helloworld-go created
deployment.apps/helloworld-go-deployment created
service/autoscale-go created
deployment.apps/autoscale-go-deployment created
NAME                                       READY   STATUS              RESTARTS   AGE
nginx-test                                 0/1     ContainerCreating   0          2s
helloworld-go-deployment-86f5466d4-vzxsf   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-z9vcq   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-2wlf5   0/1     Pending             0          1s
autoscale-go-deployment-5894658957-s7444   0/1     Pending             0          1s

waiting for ready pods...

NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m2s
autoscale-go-deployment-5894658957-2wlf5   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-s7444   1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-vzxsf   1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-z9vcq   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP        2m34s
helloworld-go   NodePort    10.152.183.193   <none>        80:30864/TCP   2m1s
autoscale-go    NodePort    10.152.183.46    <none>        80:31948/TCP   2m1s

calling helloworld-go...

Hello World: Kata Containers!

calling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...

Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.21 milliseconds.

### check proper symlink from microk8s runc:
lrwxrwxrwx 1 root root 30 Nov 26 01:29 /snap/microk8s/current/bin/runc -> squashfs-root/bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Oct 22 16:51 /bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Nov 26 01:29 /snap/microk8s/current/bin/kata-runtime
