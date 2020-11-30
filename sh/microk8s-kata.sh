#!/bin/bash

#https://github.com/kata-containers/documentation/blob/master/how-to/containerd-kata.md

set -e
trap 'catch $? $LINENO' EXIT
catch() {
  if [ "$1" != "0" ]; then
    echo "Error $1 occurred on line $2"
    if [[ ! -z "$GITHUB_WORKFLOW" ]]
    then
      # delete cloud instance in case of failure when run scheduled on GitHub (to save costs...)
      delete_gce_instance $KATA_INSTANCE $KATA_IMAGE || true
      true
    fi
  fi
}

REPORT='report.md'

OS=$(uname -a)
if [[ "$OS" == 'Linux'* ]]
then
   lsb_release -a
fi

ON_GCE=$((curl -s -i metadata.google.internal | grep 'Google') || true)

# variables below can be inherited from environment
if [[ -z ${GCP_PROJECT+x} && ! "$ON_GCE" == *'Google'* ]]    ; then echo "ERROR: gcp project not set" && false ; fi ; echo "gcp project: $GCP_PROJECT"
if [[ -z ${GCP_ZONE+x} ]]                                    ; then GCP_ZONE='us-central1-c'                   ; fi ; echo "gcp zone: $GCP_ZONE"

if [[ -z ${KATA_GCE_CREATE+x} ]]                             ; then KATA_GCE_CREATE='true'                     ; fi ; echo "kata gce create: $KATA_GCE_CREATE"
if [[ -z ${KATA_GCE_DELETE+x} ]]                             ; then KATA_GCE_DELETE='false'                    ; fi ; echo "kata gce delete: $KATA_GCE_DELETE"

if [[ -z ${KATA_INSTALL+x} ]]                                ; then KATA_INSTALL='true'                        ; fi ; echo "kata install: $KATA_INSTALL"
if [[ -z ${KATA_IMAGE_FAMILY+x} ]]                           ; then KATA_IMAGE_FAMILY='ubuntu-2004-lts'        ; fi ; echo "kata image family: $KATA_IMAGE_FAMILY"
if [[ -z ${KATA_INSTANCE+x} ]]                               ; then KATA_INSTANCE='microk8s-kata'              ; fi ; echo "kata host instance: $KATA_INSTANCE"

#if [[ -z ${KATA_VERSION+x} ]]                               ; then export KATA_VERSION='2.x'                  ; fi ; echo "mk8s version: $KATA_VERSION"

if [[ -z ${MK8S_VERSION+x} ]]                                ; then export MK8S_VERSION='1.19'                 ; fi ; echo "mk8s version: $MK8S_VERSION"

create_gce_instance() 
{
  local GCE_INSTANCE="$1"
  local GCE_IMAGE="$2"
  echo -e "\n### setup instance: $GCE_INSTANCE - image: $GCE_IMAGE"
  gcloud compute instances list \
      --project=$GCP_PROJECT
  if [[ ! $(gcloud compute instances list --project=$GCP_PROJECT) == *"$GCE_INSTANCE"* ]]
  then 
    gcloud compute instances create \
        --min-cpu-platform 'Intel Broadwell' \
        --machine-type 'n1-standard-4' \
        --image $GCE_IMAGE \
        --zone $GCP_ZONE \
        --project=$GCP_PROJECT \
        --quiet \
        $GCE_INSTANCE
  fi
  echo -e "\n### started instance:" | tee -a "$REPORT"
  gcloud compute instances list --project=$GCP_PROJECT | tee -a "$REPORT"
  while [[ ! $(gcloud compute ssh $GCE_INSTANCE --command='uname -a' --zone $GCP_ZONE --project=$GCP_PROJECT) == *'Linux'* ]]
  do
    echo -e "instance not ready for ssh..."
    sleep 5 
  done
  gcloud compute ssh $GCE_INSTANCE \
      --command='uname -a'  \
      --zone $GCP_ZONE \
      --project=$GCP_PROJECT
}

delete_gce_instance()
{
  local GCE_INSTANCE="$1"
  local GCE_IMAGE="$2"
  echo -e "\n### delete gce instance: $GCE_INSTANCE"
  gcloud compute instances delete \
      --zone $GCP_ZONE \
      --project=$GCP_PROJECT \
      --quiet \
      $GCE_INSTANCE   
  
  echo -e "\n### delete gce image: $GCE_IMAGE"     
  gcloud compute images delete \
      --project=$GCP_PROJECT \
      --quiet \
      $GCE_IMAGE
}

KATA_IMAGE="$KATA_IMAGE_FAMILY-kata"

if [[ $KATA_GCE_CREATE == 'true' ]]
then
  if [[ "$ON_GCE" == *'Google'* ]]
    then
      echo '\n### running on GCE'
    else 
      echo -e '\n### not on GCE' 
      
      if [[ ! $(gcloud compute instances list --project=$GCP_PROJECT) == *"$KATA_INSTANCE"* ]]
      then
        echo -e "\n### cleanup previous image: $KATA_IMAGE"
        if [[ -n $(gcloud compute images describe --project=$GCP_PROJECT $KATA_IMAGE) ]]
        then
          gcloud compute images delete \
              --project=$GCP_PROJECT \
              --quiet \
              $KATA_IMAGE
        fi 

        echo -e "\n### image: $(gcloud compute images list | grep $KATA_IMAGE_FAMILY)"
        IMAGE_PROJECT=$(gcloud compute images list | grep $KATA_IMAGE_FAMILY | awk '{ print $2 }')

        echo -e "\n### create image: $KATA_IMAGE"
        gcloud compute images create \
            --source-image-project $IMAGE_PROJECT \
            --source-image-family $KATA_IMAGE_FAMILY \
            --licenses=https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx \
            --project=$GCP_PROJECT \
            $KATA_IMAGE

        echo -e "\n### describe image: $KATA_IMAGE"    
        gcloud compute images describe --project=$GCP_PROJECT $KATA_IMAGE
      fi

      create_gce_instance "$KATA_INSTANCE" "$KATA_IMAGE"
      
      gcloud compute ssh $KATA_INSTANCE --command='sudo rm -rf /var/lib/apt/lists/* && sudo apt update -y && (sudo apt upgrade -y && sudo apt upgrade -y) && sudo apt autoremove  -y' --zone $GCP_ZONE --project=$GCP_PROJECT
      gcloud compute scp $0  $KATA_INSTANCE:$(basename $0) --zone $GCP_ZONE --project=$GCP_PROJECT
      gcloud compute ssh $KATA_INSTANCE --command="sudo chmod ugo+x ./$(basename $0)" --zone $GCP_ZONE --project=$GCP_PROJECT
      gcloud compute ssh $KATA_INSTANCE --command="bash ./$(basename $0)" --zone $GCP_ZONE --project=$GCP_PROJECT
      
      if [[ ! -z "$GITHUB_WORKFLOW" ]]
      then
        gcloud compute scp $KATA_INSTANCE:$REPORT $REPORT --zone $GCP_ZONE --project=$GCP_PROJECT
        cat README.template.md > README.md
        echo '```' >> README.md
        cat $REPORT >> README.md || true
        echo '```' >> README.md
      fi
      
      if [[ $KATA_GCE_DELETE == 'true' ]]
      then
        delete_gce_instance $KATA_INSTANCE $KATA_IMAGE
      fi
  fi
fi

#gcloud compute ssh microk8s-kata --zone 'us-central1-c' --project=$GCP_PROJECT

if [[ ! "$ON_GCE" == *'Google'* ]]
then
  exit 0
fi

#now running on GCE....

echo -e "\n### check gce instance:"
lscpu
lscpu | grep 'GenuineIntel'

if [[ -z $(which jq) ]]
then
  echo -e "\n### install jq:"
  sudo snap install jq
  snap list | grep 'jq'
fi

# due to https://github.com/containers/podman/pull/7126 and https://github.com/containers/podman/pull/7077
# some podman commands fail if --runtime= is not specified. So, we currently add it to all commands until 7126 gets published in upcoming official release
if [[ -z "$KATA_VERSION" ]]
then
  KATA_PATH='/bin/kata-runtime'
else
  KATA_PATH='/snap/kata-containers/current/usr/bin/kata-runtime'
fi

if [[ ! -f $KATA_PATH ]]
then
  if [[ -z "$KATA_VERSION" ]]
  then
    echo -e "\n### install kata containers: v1.x"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/kata-containers/tests/master/cmd/kata-manager/kata-manager.sh) install-docker-system"
  else
    echo -e "\n### install kata containers: v2.x"
    sudo snap install --edge --classic kata-containers
    sudo snap list | grep 'kata-containers' | grep ' 2.'
  fi
fi

echo -e "\n### kata-runtime env:"
$KATA_PATH kata-env

echo -e "\n### kata-runtime version: $($KATA_PATH --version)"

#kata-check fail since Nov, 12th 20202 due to publication on version 1.12. See https://github.com/kata-containers/runtime/issues/3069
$KATA_PATH kata-check -n || true
$KATA_PATH kata-check -n | grep 'System is capable of running Kata Containers' || true

if [[ -z $(which podman) ]]
then
  echo -e "\n### install podman: "
  source /etc/os-release
  sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
  wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | sudo apt-key add -
  sudo apt update -y && sudo apt upgrade -y && sudo apt install -y podman
fi

KATA_PARAMS='
#microk8s-kata
kata = [
            "/usr/bin/kata-runtime",
            "/usr/sbin/kata-runtime",
            "/usr/local/bin/kata-runtime",
            "/usr/local/sbin/kata-runtime",
            "/sbin/kata-runtime",
            "/bin/kata-runtime",
            "/usr/bin/kata-qemu",
            "/usr/bin/kata-fc",
]'
#echo "kata params: $KATA_PARAMS"

#cat /etc/containers/containers.conf | grep '#microk8s-kata' || echo "$KATA_PARAMS" | sudo tee -a /etc/containers/containers.conf
#cat /etc/containers/containers.conf


echo -e "\n### podman version: "
podman version

echo -e "\n### check existing container runtimes on Ubuntu host:" | tee -a "$REPORT"
ls -lh /bin/runc | tee -a "$REPORT"
ls -lh "$KATA_PATH" | tee -a "$REPORT"

echo -e "\n### check active OCI runtime: " | tee -a "$REPORT"
podman info --runtime="$KATA_PATH"
podman info --runtime="$KATA_PATH" --format=json | jq '.host.ociRuntime.name' | grep 'runc' | tee -a "$REPORT"

echo -e "\n### test use of kata-runtime with alpine: " | tee -a "$REPORT"

echo -e "\n### podman runc tests: runc"
podman run --rm --runtime='/bin/runc' alpine ls -l | grep 'etc' | grep 'root'
podman run --rm --runtime='/bin/runc' alpine cat /etc/hosts | grep 'localhost'

echo -e "\n### podman tests: kata-runtime"
ls -l "$KATA_PATH"
#to debug issue with podman on v2.0
if [[ -n "$KATA_VERSION" ]]
then
  set -x
fi
sudo -E podman run --rm --runtime="$KATA_PATH" alpine grep -m 1 kataShared /etc/mtab && echo 'kata-runtime successfully detected!'
sudo -E podman run --rm --runtime="$KATA_PATH" alpine ls -l | grep 'etc' | grep 'root'
sudo -E podman run --rm --runtime="$KATA_PATH" alpine cat /etc/hosts | grep 'localhost'

# stop and rm old container(s) if any (for script idempotence)
sudo podman stop 'kata-alpine' --runtime="$KATA_PATH" > /dev/null 2>&1 || true
sudo podman rm --force --runtime="$KATA_PATH" 'kata-alpine' > /dev/null 2>&1 || true

KATA_ALPINE_ID=$(sudo -E podman run -itd --rm --runtime="$KATA_PATH" --name='kata-alpine' alpine sh)
echo -e "\n### started kata-alpine container:  $KATA_ALPINE_ID"

echo -e "\n### list running containers: "
sudo podman ps -a --runtime="$KATA_PATH" | tee -a "$REPORT"
sudo podman ps -a --runtime="$KATA_PATH" | grep 'kata-alpine' > /dev/null

echo -e "\n### inspect kata-alpine container: "
sudo podman inspect --runtime="$KATA_PATH" "$KATA_ALPINE_ID"
sudo podman inspect --runtime="$KATA_PATH" "$KATA_ALPINE_ID" | grep 'Name' | grep 'kata-alpine' | tee -a "$REPORT"
sudo podman inspect --runtime="$KATA_PATH" "$KATA_ALPINE_ID" | grep 'Id' | tee -a "$REPORT"
sudo podman inspect --runtime="$KATA_PATH" "$KATA_ALPINE_ID" | grep 'OCIRuntime' | grep 'kata-runtime' | tee -a "$REPORT"

KATA_ALPINE_ID2=$(sudo sudo podman stop 'kata-alpine' --runtime="$KATA_PATH")
echo -e "\n### stopped kata-alpine: $KATA_ALPINE_ID2 "
[[ "$KATA_ALPINE_ID2" == "$KATA_ALPINE_ID" ]]

if [[ -z $(which microk8s) ]]
then
  echo -e "\n### install microk8s:" | tee -a "$REPORT"
  sudo snap install microk8s --classic --channel="$MK8S_VERSION"
  SNAP_VERSION=$(sudo snap list | grep 'microk8s')
  sudo microk8s status --wait-ready | tee -a "$REPORT"
fi

echo -e "\n### check container runtime on microk8s snap:" | tee -a "$REPORT"
ls -lh /snap/microk8s/current/bin/runc | tee -a "$REPORT"

echo -e "\n### TEST WITH INITIAL RUNC\n" | tee -a "$REPORT"

sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/nginx-runc.yaml"

echo -e "\n### test microk8s with helloworld-runc & autoscale-runc: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/helloworld-runc.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/autoscale-runc.yaml" | tee -a "$REPORT"

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"

echo -e "\nwaiting for ready pods...\n" >> "$REPORT"
sleep 120s
# wait --for=condition=available : currently unstable with MicroK8s
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/helloworld-runc-deployment -n default | tee -a "$REPORT"  || true
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/autoscale-runc-deployment -n default | tee -a "$REPORT" || true

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"
sudo microk8s kubectl get services -n default | tee -a "$REPORT"

#echo -e "\n### lscpu:" | tee -a "$REPORT"
#sudo microk8s kubectl exec --stdin --tty nginx-runc -- lscpu
#sudo microk8s kubectl exec --stdin --tty nginx-runc -- lscpu | grep 'Vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-runc -- lscpu | grep 'Model name' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-runc -- lscpu | grep 'Virtualization' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-runc -- lscpu | grep 'Hypervisor vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-runc-- lscpu | grep 'Virtualization type' | tee -a "$REPORT" || true

echo -e "\ncalling helloworld-runc...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service helloworld-runc -n default --no-headers | awk '{print $3}')" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service helloworld-runc -n default --no-headers | awk '{print $3}')" | grep -m 1 'Hello World: Runc Containers!'

#source: https://knative.dev/docs/serving/autoscaling/autoscale-go/
#curl "http://autoscale-runc.default.1.2.3.4.xip.io?sleep=100&prime=10000&bloat=5"
echo -e "\ncalling autoscale-runc with request for biggest prime under 10 000 and 5 MB memory...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service autoscale-runc -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service autoscale-runc -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | grep 'The largest prime less than 10000 is 9973'

echo -e "\n### extend microk8s snap with kata-runtime:"
sudo microk8s stop
if [[ -d microk8s-squash ]]
then
  sudo rm -rf microk8s-squash
fi
mkdir microk8s-squash
cd microk8s-squash
MK8S_SNAP=$(mount | grep 'var/lib/snapd/snaps/microk8s' | awk '{printf $1}')
ls -l "$MK8S_SNAP"
sudo unsquashfs "$MK8S_SNAP"
sudo mv squashfs-root/bin/runc squashfs-root/bin/runc.bak
sudo cp /bin/runc squashfs-root/bin/runc
sudo cp "$KATA_PATH" squashfs-root/bin/kata-runtime
echo -e "\ncontainers runtimes in new snap: " | tee -a "$REPORT"
ls -l squashfs-root/bin/runc.bak
ls -l squashfs-root/bin/runc
ls -l squashfs-root/bin/kata-runtime
#sudo ln -s squashfs-root/bin/kata-runtime squashfs-root/bin/runc
sudo mksquashfs squashfs-root/ "$(basename $MK8S_SNAP)" -noappend -always-use-fragments | tee -a "$REPORT"
cd
ls -lh "microk8s-squash/$(basename $MK8S_SNAP)"

export CONTAINERD_TOML='/var/snap/microk8s/current/args/containerd.toml'
export KATA_HANDLER_BEFORE='[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      # runtime_type is the runtime type to use in containerd e.g. io.containerd.runtime.v1.linux
      runtime_type = "io.containerd.runc.v1"'
      
#https://github.com/kata-containers/documentation/blob/master/how-to/containerd-kata.md
export KATA_HANDLER_AFTER='[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      # runtime_type is the runtime type to use in containerd e.g. io.containerd.runtime.v1.linux
      runtime_type = "io.containerd.runc.v1"
      
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/bin/kata-runtime"'

if [[ ! -f  "$CONTAINERD_TOML.bak" ]]
then 
  echo -e "\n### backup containerd config: "
  sudo cp "$CONTAINERD_TOML" "$CONTAINERD_TOML.bak"
fi

if [[ -z $(sudo cat $CONTAINERD_TOML | grep 'kata-runtme') ]]
then
  echo -e "\n### extend containerd config: " | tee -a "$REPORT"
  sudo cat "$CONTAINERD_TOML" | sed "s!$KATA_HANDLER_BEFORE!$KATA_HANDLER_AFTER!" | sudo tee "$CONTAINERD_TOML" || true
fi

echo -e "\n### re-install microk8s including kata-runtime: " | tee -a "$REPORT"
set -x
sudo microk8s start
sudo microk8s status --wait-ready
sudo snap remove microk8s
sudo snap install --classic --dangerous "microk8s-squash/$(basename $MK8S_SNAP)" | tee -a "$REPORT"

echo -e "\n### restart microk8s: "
sudo microk8s start
sudo microk8s status --wait-ready | tee -a "$REPORT"
set +x

echo -e "\n### TEST WITH KATA-RUNTIME AND UPDATED RUNC\n" | tee -a "$REPORT"

echo -e "\n### deploy K8s runtime class for kata: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/kata-runtime-class.yaml" | tee -a "$REPORT"
sudo microk8s kubectl get runtimeclass -o wide
sudo microk8s kubectl get runtimeclass | grep 'kata-runtime' && echo 'kara-runtime detected as K8s runtime class'


echo -e "\n### deploy nginx servers: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/nginx-runc.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/nginx-kata.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/nginx-untrusted.yaml" | tee -a "$REPORT"

echo -e "\n### test microk8s with helloworld-runc & autoscale-runc: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/helloworld-runc.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/autoscale-runc.yaml" | tee -a "$REPORT"

echo -e "\n### test microk8s with helloworld-kata & autoscale-kata: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/helloworld-kata.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/autoscale-kata.yaml" | tee -a "$REPORT"


sudo microk8s kubectl get pods -n default | tee -a "$REPORT"

echo -e "\nwaiting for ready pods...\n" >> "$REPORT"
sleep 120s
# wait --for=condition=available : currently unstable with MicroK8s
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/helloworld-runc-deployment -n default | tee -a "$REPORT"  || true
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/autoscale-runc-deployment -n default | tee -a "$REPORT" || true

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"
sudo microk8s kubectl get services -n default | tee -a "$REPORT"

#sudo microk8s kubectl exec --stdin --tty shell-demo -- /bin/bash
#sudo microk8s kubectl exec nginx-runc-deployment-d9fff6df7-9hcbb -- uname -a
#sudo microk8s kubectl exec nginx-runc-deployment-d9fff6df7-9hcbb -- uname -a

#echo -e "\n### lscpu:" | tee -a "$REPORT"
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Model name' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Virtualization' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Hypervisor vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Virtualization type' | tee -a "$REPORT" || true

echo -e "\ncalling helloworld-runc...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service helloworld-runc -n default --no-headers | awk '{print $3}')" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service helloworld-runc -n default --no-headers | awk '{print $3}')" | grep -m 1 'Hello World: Runc Containers!'

echo -e "\ncalling helloworld-kata...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service helloworld-kata -n default --no-headers | awk '{print $3}')" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service helloworld-kata -n default --no-headers | awk '{print $3}')" | grep -m 1 'Hello World: Kata Containers!'

#source: https://knative.dev/docs/serving/autoscaling/autoscale-go/
#curl "http://autoscale-go.default.1.2.3.4.xip.io?sleep=100&prime=10000&bloat=5"
echo -e "\ncalling autoscale-runc with request for biggest prime under 10 000 and 5 MB memory...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service autoscale-runc -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service autoscale-runc -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | grep 'The largest prime less than 10000 is 9973'

echo -e "\ncalling autoscale-kata with request for biggest prime under 10 000 and 5 MB memory...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service autoscale-kata -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service autoscale-kata -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | grep 'The largest prime less than 10000 is 9973'

echo -e "\n### check microk8s runtimes:" | tee -a "$REPORT"
#[[ -L /snap/microk8s/current/bin/runc ]]
ls -l /snap/microk8s/current/bin/runc | tee -a "$REPORT"
ls -l /snap/microk8s/current/bin/kata-runtime | tee -a "$REPORT"
cmp /bin/runc /snap/microk8s/current/bin/runc && echo 'microk8s runc version identical to runc on host' | tee -a "$REPORT"
cmp "$KATA_PATH" /snap/microk8s/current/bin/kata-runtime && echo 'microk8s kata-runtime version identical to kata-runtime on host' | tee -a "$REPORT"

echo -e "\n### prepare execution report:"

echo -e "### execution date: $(date --utc)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo -e "### microk8s snap version:" >> "$REPORT.tmp"
echo -e "$SNAP_VERSION" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### ubuntu version:" >> "$REPORT.tmp"
echo "$(lsb_release -a)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### podman version:" >> "$REPORT.tmp"
echo "$(podman version)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### containerd version:" >> "$REPORT.tmp"
echo "$(containerd --version)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### kata-runtime version:" >> "$REPORT.tmp"
"$KATA_PATH" --version >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### kata-runtime check:" >> "$REPORT.tmp"
"$KATA_PATH" kata-check -n >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

cat $REPORT >> "$REPORT.tmp"
rm "$REPORT"
mv "$REPORT.tmp" $REPORT

echo "### execution report:" 
cat $REPORT