### execution date: Sat Nov 28 09:03:55 UTC 2020
 
### microk8s snap version:
microk8s          v1.19.3     1791   1.19/stable      canonical*         classic
 
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
 
### kata-runtime version:
kata-runtime  : 1.12.0-rc0
   commit   : <<unknown>>
   OCI specs: 1.0.1-dev
 
### kata-runtime check:
System is capable of running Kata Containers
 

### check existing container runtimes on Ubuntu host:
-rwxr-xr-x 1 root root 9.7M Sep  9 15:40 /bin/runc
-rwxr-xr-x 1 root root 31M Oct 22 16:51 /bin/kata-runtime

### check active OCI runtime: 

### test use of kata-runtime with alpine: 
CONTAINER ID  IMAGE                            COMMAND  CREATED        STATUS                     PORTS   NAMES
f65953d4f017  docker.io/library/alpine:latest  sh       2 seconds ago  Up Less than a second ago          kata-alpine
        "Name": "kata-alpine",
        "Id": "f65953d4f01710fe885aa9c566e3eb1af941a0979e2b3ded74aa3a7152215a1d",
        "OCIRuntime": "kata-runtime",

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
nginx-test                                 0/1     ContainerCreating   0          2s
helloworld-go-deployment-86f5466d4-87277   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-c8z4v   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-h5cw5   0/1     ContainerCreating   0          0s
autoscale-go-deployment-5894658957-8xjgc   0/1     ContainerCreating   0          0s

waiting for ready pods...

NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m2s
autoscale-go-deployment-5894658957-8xjgc   1/1     Running   0          2m
autoscale-go-deployment-5894658957-h5cw5   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-87277   1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-c8z4v   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1    <none>        443/TCP        2m33s
helloworld-go   NodePort    10.152.183.43   <none>        80:31776/TCP   2m1s
autoscale-go    NodePort    10.152.183.91   <none>        80:31498/TCP   2m

calling helloworld-go...

Hello World: Kata Containers!

calling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...

Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.14 milliseconds.

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
nginx-test                                 0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-l7t2q   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-vkf6r   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-hcdcr   0/1     ContainerCreating   0          0s
autoscale-go-deployment-5894658957-sdx8d   0/1     ContainerCreating   0          0s

waiting for ready pods...

NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-l7t2q   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-hcdcr   1/1     Running   0          2m
autoscale-go-deployment-5894658957-sdx8d   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-vkf6r   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP        2m35s
helloworld-go   NodePort    10.152.183.172   <none>        80:30885/TCP   2m2s
autoscale-go    NodePort    10.152.183.107   <none>        80:30385/TCP   2m1s

calling helloworld-go...

Hello World: Kata Containers!

calling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...

Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.14 milliseconds.

### check proper symlink from microk8s runc:
lrwxrwxrwx 1 root root 30 Nov 28 08:58 /snap/microk8s/current/bin/runc -> squashfs-root/bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Oct 22 16:51 /bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Nov 28 08:58 /snap/microk8s/current/bin/kata-runtime
