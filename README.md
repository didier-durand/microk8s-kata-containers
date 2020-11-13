
<img src="img/kata-logo.png" height="125"><img src="img/microk8s-logo.png" height="125"><img src="img/oci-logo.png" height="125"><img src="img/containerd-logo.png" height="125">

# Kata Containers on MicroK8s

![workflow badge](https://github.com/didier-durand/microk8s-kata-containers/workflows/Kata%20Containers%20on%20MicroK8s/badge.svg)
![workflow badge](https://github.com/didier-durand/microk8s-kata-containers/workflows/MicroK8s%20Services%20Images/badge.svg)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

* [Goal](README.md#goal)
* [Kata Containers - Rationale](README.md#kata-containers---rationale)
* [Specific Setup](README.md#specific-setup)
* [Workflow Steps](README.md#workflow-steps)
* [How to Fork & Run](README.md#how-to-fork--run)
* [Execution Report](README.md#execution-report)


## Goal

[**Nota Bene:** This repository is **Work In Progress (WIP)**: currently, we abruptly replace *"[runc](https://github.com/opencontainers/runc)"* binary, initially packaged with MicroK8s, with a symbolic link (symlink) to *"[kata-runtime](https://github.com/kata-containers/runtime)"*  binary, installed on the Ubuntu instance from project's GitHub repository and added to the MicroK8s [snap](https://en.wikipedia.org/wiki/Snap_(package_manager)) in early steps of this workflow. This initial (very) direct shortcut is possible because both binaries fully respect the [OCI runtime specification](https://opencontainers.org/). Next version of this repo will properly adapt the configuration of [containerd](https://containerd.io/) (via changes in containerd.toml) and implement the K8s [RuntimeClass](https://kubernetes.io/docs/concepts/containers/runtime-class/) to be able to dynamically choose the runtime on per container basis: proper directives in Deployment yaml manifests will allow simultaneous use of *"runc"* and *"kata-runtime"* in parallel by different containers having different execution requirements.]

This repository encompasses a fully scripted Github workflow (via [microk8s-kata.yml](.github/workflows/microk8s-kata.yml) calling [microk8s-kata.sh](sh/microk8s-kata.sh)) to test the transparent use of the runtime for Kata Containers (Katas) on MicroK8s. It must run on a quite specific Google Cloud Engine (GCE) instance since so-called *"[nested virtualization](https://pve.proxmox.com/wiki/Nested_Virtualization)"* is required by Katas when running on the cloud due to its embedded virtual machine coming on top of the cloud hypervisor managing the Linux host. Some sample containerized services (see [helloworld.go](src/go/helloworld/helloworld.go) and [autoscale.go](src/go/autoscale/autoscale.go) built automatically with this [side job](.github/workflows/build-docker-images.yml)) are deployed from Docker Hub and executed as Kubernetes services on MicroK8s.

The workflow tests the proper execution of sample containers with 'kata-runtime' after running them initially on standard 'runc' to validate global setup: beyond run of traditional helloworld-go, autoscale-go is called with parameters ensuring that thorough computations and resource allocation are properly executed by the replacing runtime.

[MicroK8s](https://microk8s.io/) by Canonical was chosen on purpose for this project: its source code is extremely close to the upstream version of Kubernetes. Consequently, it allows to build a fully-featured production-grade Kubernetes cluster that can be run autonomously - on a single Limux instance - with very sensible default configuration allowing a quick setup, quite representative of a productive system. The source code of Micro8s is extremely close to the upstream version of Kubernetes.

To automatically confirm the validity of this workflow overtime when new versions of the various components (Kata Containers, MicroK8s, Docker, Ubuntu, etc.) get published, cron schedules it on a recurring basis: execution logs can be seen in [Actions tab](https://github.com/didier-durand/microk8s-kata-containers/actions). Excerpts of last execution are gathered [further down in this page](README.md#execution-report).

**Forking and re-using on your own is strongly encouraged!** All comments for improvements and extensions will be welcome. Finally, if you like this repo, please give a Github star so that it gets more easily found by others.

## Kata Containers - Rationale

As per [Katas' website](https://katacontainers.io/): *"Kata Containers is an open source community working to build a secure container runtime with lightweight virtual machines that feel and perform like containers, but provide stronger workload isolation using hardware virtualization technology as a second layer of defense."*

This added lightweight virtual machine comes with a dedicated Linux kernel, providing isolation of network, I/O and memory and utilizes hardware-enforced isolation through Intel's [VT-x features](https://en.wikipedia.org/wiki/X86_virtualization#Intel_virtualization_(VT-x)) for virtualization. 

<img src="img/kata-vs-docker.jpg" height="500">

The use of a per-container dedicated kernel and lightweight virtual machines, provided by either [Qemu](https://www.qemu.org/) or [Amazon's Firecracker](https://firecracker-microvm.github.io/), creates a much stronger isolation between the containers themselves and with the host. For example, if a container misbehaves and messes up with the kernel resources by overconsuming or corrupting them, it's only **HIS** dedicated kernel that gets damaged, not the unique kernel shared between all containers and host, as when you're using regular containers. The picture above shows the clear differences between the two architectures. So, Kata Containers are probably the best option currently available for additional security and reliability with untrusted workloads of all kinds (recent versions, external source code, etc.). 

As you would expect, this further level of isolation through additional virtualization comes with a performance / cost penalty but this [comparative study](https://object-storage-ca-ymq-1.vexxhost.net/swift/v1/6e4619c416ff4bd19e1c087f27a43eea/www-assets-prod/presentation-media/kata-containers-and-gvisor-a-quantitave-comparison.pdf) between the performances of raw host performances, *"runc"*, [Google's gVisor](https://gvisor.dev/) containers and Kata Containers demonstrates that the overhead remains quite acceptable in many situations for the additional security that is delivered. Look at slides 19 to 26 of the linked pdf to get the exact numbers.

## Specific Setup

Two specific points have to be part of this workflow:

1. [Katas on GCE](https://github.com/kata-containers/documentation/blob/master/install/gce-installation-guide.md) implies use of [nested virtualization](https://en.wikipedia.org/wiki/Virtualization#Nested_virtualization): this requires to create a [specific GCE image](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances) to activate the [Intel VT-x instruction set](https://en.wikipedia.org/wiki/X86_virtualization#Intel_virtualization_(VT-x)). This is obtained by the addition of a specific option *"--licenses="* to the command *"gcloud compute images create"*. See [microk8s-kata.sh](sh/microk8s-kata.sh) for details.

2. The underlying hardware must minimally be of the Intel's [Broadwell architecture generation](https://en.wikipedia.org/wiki/Broadwell_(microarchitecture)) to provide the VT-x instructions. This is guaranteed by adding *"--min-cpu-platform 'Intel Broadwell'"* to the command *"gcloud compute instances create"*. See [microk8s-kata.sh](sh/microk8s-kata.sh) for details.

## Workflow Steps

The major steps in this workflow are: 

1. Check that GCE instance is proper ('GenuineIntel') - according to the above requirement for Broadwell - via lscpu after it has been created.
2. Install Kata Containers runtime directly from the Github repository of the project.
3. Check that this added runtime can run on the instance: command *"kata-runtime kata-check"* MUST produce output *"System is capable of running Kata Containers"*
4. Install Docker and check via *"docker info"* that it sees both its standard runtime *"runc"* and the newly added *"kata-runtime"*
5. Run the latest version of [Alpine Linux](https://en.wikipedia.org/wiki/Alpine_Linux) image with selection of kata-runtime (*"--runtime='kata-runtime"*) and verify through *"docker info"* that the running Alpine is effectively using kata-runtime.
6. Install MicroK8s via snap and check that it works properly via the deployment of [helloworld-go.yml](kubernetes/helloworld-go.yml) and [autoscale-go.yml](kubernetes/autoscale-go.yml) service manifests, built from from GoLang source code in [src/go directory](src/go). Stop MicroK8s when validation is successful.
7. Open the MicroK8s .snap file to add kata-runtime and repackage a new version (now unsigned) of the .snap file. Please, note use of *"unsquashfs"* and *"mksquashfs"* to achieve this refurbishing since the [snap archive format](https://en.wikipedia.org/wiki/Snap_(package_manager)) is based on read-only and compressed [SquashFS](https://en.wikipedia.org/wiki/SquashFS) Linux file system.
8. Remove old MicroK8s installation and re-install a fresh instance based with newly created snap version: *"--dangerous"* option is now required since the tweaked .snap is no longer signed by its official provider, Canonical.
9. Deploy again helloworld-go and autoscale-go on fresh MicroK8s to validate that they work fine with kata-runtime: autoscale-go request is parametrized to make sure that some amount computing resources are consumed to achieve a better validation.

## How to Fork & Run

To start with, you need a Google Cloud account including a project where the GCE APIs have been enabled. Obtain the id of your project from 
GCP dashboard. Additionally, you need to create in this project a service account (SA) and give it proper GKE credentials: right to create, administer and delete GCE images & instances (if your cannot  make the SA a "Project Owner" to simplify the security aspects...). Save the private key of the SA in json format.

Then, fork our repository and define the required [Github Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) in your fork: 

1. your GCP project id will be {{ secrets.GCP_PROJECT }}
2. The private key of your service account in json format will be ${{ secrets.GCP_SA_KEY }} 

To easily use the workflow from Github, you can launch it with the [manual dispatch feature of Github](https://github.blog/changelog/2020-07-06-github-actions-manual-triggers-with-workflow_dispatch/) that you can see as a launch button (the green one in the picture below) in the Action tab of your fork.

<img src="img/microk8s-kata-launch-button.jpg" height="250">

The workflow will execute all the steps described above and terminate gracefully after all validation tests described are completed: it will then delete the GCE instance and the associated image triggering the nested virtualization.

If you also want to make use of the [side workflow](.github/workflows/build-docker-images.yml) allowing to build the test container images from their GoLang sources, you'll need to add 2 additional secrets : {{ secrets.DOCKER_USERID }} & {{ secrets.DOCKER_PASSWORD }} corresponding to the login parameters of your [Docker Hub account](https://hub.docker.com/).

## Execution Report

Below are some relevant excerpts of the last execution log:



```
execution date: Fri Nov 13 05:05:46 UTC 2020
 
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
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
0904b0f6f199        alpine              "sh"                2 seconds ago       Up Less than a second                          kata-alpine
ef8c7be19c9a        busybox             "uname -a"          11 seconds ago      Exited (0) 8 seconds ago                       keen_jang
[
    {
        "Id": "0904b0f6f19928ec2608a282d264caad5e7a5681a8ad837d8d58f09217b66571",
        "Created": "2020-11-13T04:56:27.76189265Z",
        "Path": "sh",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 8131,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2020-11-13T04:56:29.545401938Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0",
        "ResolvConfPath": "/var/lib/docker/containers/0904b0f6f19928ec2608a282d264caad5e7a5681a8ad837d8d58f09217b66571/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/0904b0f6f19928ec2608a282d264caad5e7a5681a8ad837d8d58f09217b66571/hostname",
        "HostsPath": "/var/lib/docker/containers/0904b0f6f19928ec2608a282d264caad5e7a5681a8ad837d8d58f09217b66571/hosts",
        "LogPath": "/var/lib/docker/containers/0904b0f6f19928ec2608a282d264caad5e7a5681a8ad837d8d58f09217b66571/0904b0f6f19928ec2608a282d264caad5e7a5681a8ad837d8d58f09217b66571-json.log",
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
                "LowerDir": "/var/lib/docker/overlay2/f6ce9a76c37aaa242a97e18efd2d45dc671b8cbfaefbecea28c3723ef767b9a3-init/diff:/var/lib/docker/overlay2/39c8d331e08db4e01e987048938fba3d67be4a285203222e40896600d9a9a105/diff",
                "MergedDir": "/var/lib/docker/overlay2/f6ce9a76c37aaa242a97e18efd2d45dc671b8cbfaefbecea28c3723ef767b9a3/merged",
                "UpperDir": "/var/lib/docker/overlay2/f6ce9a76c37aaa242a97e18efd2d45dc671b8cbfaefbecea28c3723ef767b9a3/diff",
                "WorkDir": "/var/lib/docker/overlay2/f6ce9a76c37aaa242a97e18efd2d45dc671b8cbfaefbecea28c3723ef767b9a3/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "0904b0f6f199",
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
            "SandboxID": "603fd7b4a5542e83210f6a6c4f9c4e9c56b6d073df1797cf3400fb2b1b83d7c0",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/603fd7b4a554",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "d78b8498a9ce82510f94d134224e39c61996712caead6357b217b6e6d09e672a",
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
                    "NetworkID": "87388c0a11da5a999b282ac665ba853690aa1c2320df5b0aa141ee994b069852",
                    "EndpointID": "d78b8498a9ce82510f94d134224e39c61996712caead6357b217b6e6d09e672a",
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
helloworld-go-deployment-86f5466d4-jw229   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-tm4qs   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-rclsc   0/1     Pending             0          0s
autoscale-go-deployment-5894658957-94kpv   0/1     Pending             0          0s

waiting for ready pods...

NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-rclsc   1/1     Running   0          2m
autoscale-go-deployment-5894658957-94kpv   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-tm4qs   1/1     Running   0          2m1s
helloworld-go-deployment-86f5466d4-jw229   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP        2m33s
helloworld-go   NodePort    10.152.183.157   <none>        80:30107/TCP   2m1s
autoscale-go    NodePort    10.152.183.13    <none>        80:30088/TCP   2m

calling helloworld-go...

Hello World: Kata Containers!

calling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...

Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.21 milliseconds.

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
nginx-test                                 0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-xg494   0/1     ContainerCreating   0          1s
helloworld-go-deployment-86f5466d4-2pgbr   0/1     ContainerCreating   0          1s
autoscale-go-deployment-5894658957-g5f2x   0/1     Pending             0          0s
autoscale-go-deployment-5894658957-kkkhr   0/1     Pending             0          0s
NAME                                       READY   STATUS    RESTARTS   AGE
nginx-test                                 1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-g5f2x   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-xg494   1/1     Running   0          2m1s
autoscale-go-deployment-5894658957-kkkhr   1/1     Running   0          2m
helloworld-go-deployment-86f5466d4-2pgbr   1/1     Running   0          2m1s
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.152.183.1     <none>        443/TCP        2m34s
helloworld-go   NodePort    10.152.183.221   <none>        80:31766/TCP   2m1s
autoscale-go    NodePort    10.152.183.209   <none>        80:30487/TCP   2m
Hello World: Kata Containers!
Allocated 5 Mb of memory.
The largest prime less than 10000 is 9973.
Slept for 100.15 milliseconds.

### check proper symlink from microk8s runc:
lrwxrwxrwx 1 root root 30 Nov 13 05:00 /snap/microk8s/current/bin/runc -> squashfs-root/bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Oct 22 16:51 /bin/kata-runtime
-rwxr-xr-x 1 root root 31560112 Nov 13 05:00 /snap/microk8s/current/bin/kata-runtime
```
