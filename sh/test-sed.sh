#!/bin/bash


CONTAINERD_TOML='data/containerd.toml'
KATA_HANDLER_BEFORE='[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-container-runtime]'   
#https://github.com/kata-containers/documentation/blob/master/how-to/containerd-kata.md
KATA_HANDLER_AFTER='
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata-runtime]
      runtime_type = "io.containerd.kata-runtime.v1"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata-runtime.options]
        BinaryName = "kata-runtime"
        
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-container-runtime]'

#cat "$CONTAINERD_TOML"    
cat "$CONTAINERD_TOML" | sed -e "s!$KATA_HANDLER_BEFORE!foo-foo-foo!"