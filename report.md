execution date: Fri Nov 13 06:03:40 UTC 2020
 
microk8s snap version: microk8s          v1.19.3    x1     -                -                  classic
 
ubuntu version:
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.1 LTS
Release:	20.04
Codename:	focal
 
docker version:
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
 
kata-runtime version:
kata-runtime  : 1.12.0-rc0
   commit   : <<unknown>>
   OCI specs: 1.0.1-dev
kata-runtime check:
System is capable of running Kata Containers

### test use of kata-runtime with alpine: 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
e7f18560d7c5        alpine              "sh"                2 seconds ago       Up Less than a second                           kata-alpine
dc0d1b00045f        busybox             "uname -a"          13 seconds ago      Exited (0) 10 seconds ago                       silly_mestorf
[
    {
        "Id": "e7f18560d7c51c417f2bc956aaa5f840b84d23d2da553865268d551f92acdcf4",
        "Created": "2020-11-13T05:53:30.62884417Z",
        "Path": "sh",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 8133,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2020-11-13T05:53:32.552790942Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0",
        "ResolvConfPath": "/var/lib/docker/containers/e7f18560d7c51c417f2bc956aaa5f840b84d23d2da553865268d551f92acdcf4/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/e7f18560d7c51c417f2bc956aaa5f840b84d23d2da553865268d551f92acdcf4/hostname",
        "HostsPath": "/var/lib/docker/containers/e7f18560d7c51c417f2bc956aaa5f840b84d23d2da553865268d551f92acdcf4/hosts",
        "LogPath": "/var/lib/docker/containers/e7f18560d7c51c417f2bc956aaa5f840b84d23d2da553865268d551f92acdcf4/e7f18560d7c51c417f2bc956aaa5f840b84d23d2da553865268d551f92acdcf4-json.log",
        "Name": "/kata-alpine",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "docker-default",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": true,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Capabilities": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "kata-runtime",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "KernelMemory": 0,
            "KernelMemoryTCP": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": false,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/asound",
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/4e3fce728b938d330c55030ca86aa4428537a782d3481ff7dfd3b123c10f0b81-init/diff:/var/lib/docker/overlay2/c3ad96f122088853e76045aae68e34fa23417449bf91849a784e1f00e3d596b2/diff",
                "MergedDir": "/var/lib/docker/overlay2/4e3fce728b938d330c55030ca86aa4428537a782d3481ff7dfd3b123c10f0b81/merged",
                "UpperDir": "/var/lib/docker/overlay2/4e3fce728b938d330c55030ca86aa4428537a782d3481ff7dfd3b123c10f0b81/diff",
                "WorkDir": "/var/lib/docker/overlay2/4e3fce728b938d330c55030ca86aa4428537a782d3481ff7dfd3b123c10f0b81/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "e7f18560d7c5",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": true,
            "OpenStdin": true,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "sh"
            ],
            "Image": "alpine",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {}
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "731f27ca76672309d56a5de78b3b422a224c1cbe323efe6902c326ca777b730b",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/731f27ca7667",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "3c1e8d482b98bbbdd568d06ecc18df128078c6e7a85e2b5f06a922f9812cb8de",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "64b739e484e04bc2370ed5eaffe62e5932cc033c5eae3c6f42f68b45944100fa",
                    "EndpointID": "3c1e8d482b98bbbdd568d06ecc18df128078c6e7a85e2b5f06a922f9812cb8de",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]
            "Runtime": "kata-runtime",

### check container runtimes on host instance: 
-rwxr-xr-x 1 root root 9.7M Sep  9 15:40 /bin/runc
-rwxr-xr-x 1 root root 31M Oct 22 16:51 /bin/kata-runtime

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
pod/nginx-test created

### test microk8s with helloworld-go & autoscale-go: 
service/helloworld-go created
deployment.apps/helloworld-go-deployment created
service/autoscale-go created
deployment.apps/autoscale-go-deployment created
NAME                                       READY   STATUS              RESTARTS   AGE
nginx-test                                 0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-7gtsx   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-nhbg2   0/1     Pending             0          0s
helloworld-go-deployment-86f5466d4-dbjcj   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-4jtch   0/1     Pending             0          0s

waiting for ready pods...

NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-7gtsx   1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-dbjcj   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-4jtch   1/1     Running   0          2m
autoscale-go-deployment-5894658957-nhbg2   1/1     Running   0          2m
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP        2m33s
helloworld-go   NodePort    10.152.183.42    <none>        80:30839/TCP   2m1s
autoscale-go    NodePort    10.152.183.206   <none>        80:31847/TCP   2m

calling helloworld-go...

Hello World: Kata Containers!

calling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...

Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.64 milliseconds.

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
pod/nginx-test created

### test microk8s + kata with helloworld-go & autoscale-go: 
service/helloworld-go created
deployment.apps/helloworld-go-deployment created
service/autoscale-go created
deployment.apps/autoscale-go-deployment created
NAME                                       READY   STATUS              RESTARTS   AGE
nginx-test                                 0/1     ContainerCreating   0          2s
helloworld-go-deployment-86f5466d4-jp8nm   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-bs4dh   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-llgjs   0/1     Pending             0          1s
autoscale-go-deployment-5894658957-p7qhf   0/1     ContainerCreating   0          1s
NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m2s
helloworld-go-deployment-86f5466d4-bs4dh   1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-jp8nm   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-p7qhf   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-llgjs   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP        2m35s
helloworld-go   NodePort    10.152.183.195   <none>        80:30144/TCP   2m2s
autoscale-go    NodePort    10.152.183.163   <none>        80:30064/TCP   2m1s
Hello World: Kata Containers!
Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.55 milliseconds.

### check proper symlink from microk8s runc:
lrwxrwxrwx 1 root root 30 Nov 13 05:57 /snap/microk8s/current/bin/runc -> squashfs-root/bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Oct 22 16:51 /bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Nov 13 05:57 /snap/microk8s/current/bin/kata-runtime
