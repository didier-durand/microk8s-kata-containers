execution date: Fri Nov 13 01:26:43 UTC 2020
 
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
 
kata-runtime version: kata-runtime  : 1.12.0-rc0
   commit   : <<unknown>>
   OCI specs: 1.0.1-dev
kata-runtime env:
[Meta]
  Version = "1.0.24"

[Runtime]
  Debug = false
  Trace = false
  DisableGuestSeccomp = true
  DisableNewNetNs = false
  SandboxCgroupOnly = false
  Path = "/usr/bin/kata-runtime"
  [Runtime.Version]
    OCI = "1.0.1-dev"
    [Runtime.Version.Version]
      Semver = "1.12.0-rc0"
      Major = 1
      Minor = 12
      Patch = 0
      Commit = ""
  [Runtime.Config]
    Path = "/usr/share/defaults/kata-containers/configuration.toml"

[Hypervisor]
  MachineType = "pc"
  Version = "QEMU emulator version 5.0.0\nCopyright (c) 2003-2020 Fabrice Bellard and the QEMU Project developers"
  Path = "/usr/bin/qemu-vanilla-system-x86_64"
  BlockDeviceDriver = "virtio-scsi"
  EntropySource = "/dev/urandom"
  SharedFS = "virtio-9p"
  VirtioFSDaemon = "/usr/bin/virtiofsd"
  Msize9p = 8192
  MemorySlots = 10
  PCIeRootPort = 0
  HotplugVFIOOnRootBus = false
  Debug = false
  UseVSock = false

[Image]
  Path = "/usr/share/kata-containers/kata-containers-image_clearlinux_1.12.0-rc0_agent_5cfb8ec960.img"

[Kernel]
  Path = "/usr/share/kata-containers/vmlinuz-5.4.60.89-51.container"
  Parameters = "systemd.unit=kata-containers.target systemd.mask=systemd-networkd.service systemd.mask=systemd-networkd.socket scsi_mod.scan=none"

[Initrd]
  Path = ""

[Proxy]
  Type = "kataProxy"
  Path = "/usr/libexec/kata-containers/kata-proxy"
  Debug = false
  [Proxy.Version]
    Semver = "1.12.0-rc0-adde733"
    Major = 1
    Minor = 12
    Patch = 0
    Commit = "<<unknown>>"

[Shim]
  Type = "kataShim"
  Path = "/usr/libexec/kata-containers/kata-shim"
  Debug = false
  [Shim.Version]
    Semver = "<<unknown>>"
    Major = 0
    Minor = 0
    Patch = 0
    Commit = "<<unknown>>"

[Agent]
  Type = "kata"
  Debug = false
  Trace = false
  TraceMode = ""
  TraceType = ""

[Host]
  Kernel = "5.4.0-1029-gcp"
  Architecture = "amd64"
  VMContainerCapable = true
  SupportVSocks = true
  [Host.Distro]
    Name = "Ubuntu"
    Version = "20.04"
  [Host.CPU]
    Vendor = "GenuineIntel"
    Model = "Intel(R) Xeon(R) CPU @ 2.20GHz"

[Netmon]
  Path = "/usr/libexec/kata-containers/kata-netmon"
  Debug = false
  Enable = false
  [Netmon.Version]
    Semver = "1.12.0-rc0"
    Major = 1
    Minor = 12
    Patch = 0
    Commit = "<<unknown>>"
kata-runtime check:
System is capable of running Kata Containers
-rwxr-xr-x 1 root root 31560112 Nov 13 01:21 /snap/microk8s/current/bin/kata-runtime
