#!/bin/bash

set -e
trap 'catch $? $LINENO' EXIT
catch() {
  if [ "$1" != "0" ]; then
    echo "Error $1 occurred on $2"
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
if [[ -z ${KATA_HOST+x} ]]                                   ; then KATA_HOST='ubuntu-2004-lts'                ; fi ; echo "kata host os: $KATA_HOST"
if [[ -z ${KATA_INSTANCE+x} ]]                               ; then KATA_INSTANCE='microk8s-kata'              ; fi ; echo "kata host instance: $KATA_INSTANCE"

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

KATA_IMAGE="$KATA_HOST-kata"

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

        echo -e "\n### image: $(gcloud compute images list | grep $KATA_HOST)"
        IMAGE_PROJECT=$(gcloud compute images list | grep $KATA_HOST | awk '{ print $2 }')

        echo -e "\n### create image: $KATA_IMAGE"
        gcloud compute images create \
            --source-image-project $IMAGE_PROJECT \
            --source-image-family $KATA_HOST \
            --licenses=https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx \
            --project=$GCP_PROJECT \
            $KATA_IMAGE

        echo -e "\n### describe image: $KATA_IMAGE"    
        gcloud compute images describe --project=$GCP_PROJECT $KATA_IMAGE
      fi

      create_gce_instance "$KATA_INSTANCE" "$KATA_IMAGE"
      
      gcloud compute ssh $KATA_INSTANCE --command="sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove  -y" --zone $GCP_ZONE --project=$GCP_PROJECT
      gcloud compute ssh $KATA_INSTANCE --command='(sudo groupadd docker || true) && sudo usermod -a -G docker ${USER}'  --zone $GCP_ZONE --project=$GCP_PROJECT
      #gcloud compute ssh $KATA_INSTANCE --command='sudo groupadd docker && sudo usermod -a -G docker ${USER} && sudo groupadd microk8s && sudo usermod -a -G microk8s ${USER}'  --zone $GCP_ZONE --project=$GCP_PROJECT
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

if [[ -z $(which kata-runtime) ]]
then
  echo -e "\n### install kata containers:"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/kata-containers/tests/master/cmd/kata-manager/kata-manager.sh) install-docker-system"
  #sudo snap install --edge --classic kata-containers
  #sudo snap list | grep 'kata-containers'
fi

echo -e "\n### check install:"
kata-runtime kata-env

echo -e "\n### kata-runtime version: $(kata-runtime --version)"

#kata-check fail since Nov, 12th 20202 due to publication on version 1.12. See https://github.com/kata-containers/runtime/issues/3069
kata-runtime kata-check -n || true
kata-runtime kata-check -n | grep 'System is capable of running Kata Containers' || true

if [[ -z $(which docker) ]]
then
  echo -e "\n### install docker: "
  sudo apt install docker -y
fi

echo -e "\n### docker version: "
docker version

echo -e "\n### check existing container runtimes on Ubuntu host:" | tee -a "$REPORT"
ls -lh /bin/runc | tee -a "$REPORT"
ls -lh /bin/kata-runtime | tee -a "$REPORT"

echo -e "\n### check available docker runtimes: " | tee -a "$REPORT"
docker info
docker info | grep 'Runtimes' | grep 'kata-runtime' | grep 'runc' | tee -a "$REPORT"

echo -e "\n### test use of kata-runtime with alpine: " | tee -a "$REPORT"

docker run --rm --runtime='kata-runtime' alpine ls -l | grep 'etc' | grep 'root'
docker run --rm --runtime='kata-runtime' alpine cat /etc/hosts | grep 'localhost'

docker run -itd --rm --runtime='kata-runtime' --name='kata-alpine' alpine sh

docker ps -a | tee -a "$REPORT"
docker inspect $(sudo docker ps -a | grep 'kata-alpine' | awk '{print $1}')
docker inspect $(sudo docker ps -a | grep 'kata-alpine' | awk '{print $1}') | grep 'Name' | grep 'kata-alpine' | tee -a "$REPORT"
docker inspect $(sudo docker ps -a | grep 'kata-alpine' | awk '{print $1}') | grep 'Id' | tee -a "$REPORT"
docker inspect $(sudo docker ps -a | grep 'kata-alpine' | awk '{print $1}') | grep 'Runtime' | grep 'kata-runtime' | tee -a "$REPORT"

docker stop 'kata-alpine'

if [[ -z $(which microk8s) ]]
then
  echo -e "\n### install microk8s:" | tee -a "$REPORT"
  sudo snap install microk8s --classic --channel="$MK8S_VERSION"
  SNAP_VERSION=$(sudo snap list | grep 'microk8s')
  sudo microk8s status --wait-ready | tee -a "$REPORT"
fi

echo -e "\n### check container runtime on microk8s snap:" | tee -a "$REPORT"
ls -lh /snap/microk8s/current/bin/runc | tee -a "$REPORT"

echo -e "\n### TEST WITH RUNC\n" | tee -a "$REPORT"

sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/nginx-test.yaml"

echo -e "\n### test microk8s with helloworld-go & autoscale-go: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/helloworld-go.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/autoscale-go.yaml" | tee -a "$REPORT"

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"

echo -e "\nwaiting for ready pods...\n" >> "$REPORT"
sleep 120s
# wait --for=condition=available : currently unstable with MicroK8s
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/helloworld-go-deployment -n default | tee -a "$REPORT"  || true
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/autoscale-go-deployment -n default | tee -a "$REPORT" || true

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"
sudo microk8s kubectl get services -n default | tee -a "$REPORT"

#echo -e "\n### lscpu:" | tee -a "$REPORT"
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Model name' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Virtualization' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Hypervisor vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Virtualization type' | tee -a "$REPORT" || true

echo -e "\ncalling helloworld-go...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service helloworld-go -n default --no-headers | awk '{print $3}')" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service helloworld-go -n default --no-headers | awk '{print $3}')" | grep -m 1 'Hello World: Kata Containers!'

#source: https://knative.dev/docs/serving/autoscaling/autoscale-go/
#curl "http://autoscale-go.default.1.2.3.4.xip.io?sleep=100&prime=10000&bloat=5"
echo -e "\ncalling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service autoscale-go -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service autoscale-go -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | grep 'The largest prime less than 10000 is 9973'

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
sudo cp /bin/kata-runtime squashfs-root/bin/kata-runtime
sudo mv squashfs-root/bin/runc squashfs-root/bin/runc.bak
sudo ln -s squashfs-root/bin/kata-runtime squashfs-root/bin/runc
sudo mksquashfs squashfs-root/ "$(basename $MK8S_SNAP)" -noappend -always-use-fragments | tee -a "$REPORT"
cd
ls -lh "microk8s-squash/$(basename $MK8S_SNAP)"

echo -e "\n### re-install microk8s incl kata-runtime: " | tee -a "$REPORT"
sudo microk8s start
sudo microk8s status --wait-ready
sudo snap remove microk8s
sudo snap install --classic --dangerous "microk8s-squash/$(basename $MK8S_SNAP)" | tee -a "$REPORT"

echo -e "\n### restart microk8s: "
sudo microk8s start
sudo microk8s status --wait-ready | tee -a "$REPORT"

echo -e "\n### TEST WITH KATA-RUNTIME\n" | tee -a "$REPORT"

sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/nginx-test.yaml"

echo -e "\n### test microk8s with helloworld-go & autoscale-go: " | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/helloworld-go.yaml" | tee -a "$REPORT"
sudo microk8s kubectl apply -f "https://raw.githubusercontent.com/didier-durand/microk8s-kata-containers/main/kubernetes/autoscale-go.yaml" | tee -a "$REPORT"

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"

echo -e "\nwaiting for ready pods...\n" >> "$REPORT"
sleep 120s
# wait --for=condition=available : currently unstable with MicroK8s
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/helloworld-go-deployment -n default | tee -a "$REPORT"  || true
#sudo microk8s kubectl wait --for=condition=available --timeout=1000s deployment.apps/autoscale-go-deployment -n default | tee -a "$REPORT" || true

sudo microk8s kubectl get pods -n default | tee -a "$REPORT"
sudo microk8s kubectl get services -n default | tee -a "$REPORT"

#echo -e "\n### lscpu:" | tee -a "$REPORT"
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Model name' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Virtualization' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Hypervisor vendor' | tee -a "$REPORT" || true
#sudo microk8s kubectl exec --stdin --tty nginx-test -- lscpu | grep 'Virtualization type' | tee -a "$REPORT" || true

echo -e "\ncalling helloworld-go...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service helloworld-go -n default --no-headers | awk '{print $3}')" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service helloworld-go -n default --no-headers | awk '{print $3}')" | grep -m 1 'Hello World: Kata Containers!'

#source: https://knative.dev/docs/serving/autoscaling/autoscale-go/
#curl "http://autoscale-go.default.1.2.3.4.xip.io?sleep=100&prime=10000&bloat=5"
echo -e "\ncalling autoscale-go with request for biggest prime under 10 000 and 5 MB memory...\n" >> "$REPORT"
curl -v "http://$(sudo microk8s kubectl get service autoscale-go -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | tee -a "$REPORT"
curl -s "http://$(sudo microk8s kubectl get service autoscale-go -n default --no-headers | awk '{print $3}')?sleep=100&prime=10000&bloat=5" | grep 'The largest prime less than 10000 is 9973'

echo -e "\n### check proper symlink from microk8s runc:" | tee -a "$REPORT"
ls -l /snap/microk8s/current/bin/runc | tee -a "$REPORT"
[[ -L /snap/microk8s/current/bin/runc ]]
ls -l /bin/kata-runtime | tee -a "$REPORT"
ls -l /snap/microk8s/current/bin/kata-runtime | tee -a "$REPORT"
cmp /bin/kata-runtime /snap/microk8s/current/bin/kata-runtime

echo -e "\n### prepare execution report:"

echo -e "### execution date: $(date --utc)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo -e "### microk8s snap version:" >> "$REPORT.tmp"
echo -e "$SNAP_VERSION" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### ubuntu version:" >> "$REPORT.tmp"
echo "$(lsb_release -a)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### docker version:" >> "$REPORT.tmp"
echo "$(docker version)" >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### kata-runtime version:" >> "$REPORT.tmp"
kata-runtime --version >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

echo "### kata-runtime check:" >> "$REPORT.tmp"
kata-runtime kata-check -n >> "$REPORT.tmp"
echo " " >> "$REPORT.tmp"

cat $REPORT >> "$REPORT.tmp"
rm "$REPORT"
mv "$REPORT.tmp" $REPORT

echo "### execution report:" 
cat $REPORT