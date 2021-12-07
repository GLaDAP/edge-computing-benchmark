sudo tee -a /etc/modules-load.d/containerd.conf <<'EOF'
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
sudo swapoff -a

# Install containerd

export CONTAINERD_VER=1.3.1
curl -Lo /tmp/containerd.tar.gz "https://storage.googleapis.com/cri-containerd-release/cri-containerd-${CONTAINERD_VER}.linux-amd64.tar.gz"
sudo tar -C / -xzf /tmp/containerd.tar.gz
sudo systemctl start containerd
sudo systemctl enable containerd
rm /tmp/containerd.tar.gz

# Install kubeadm
sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet=1.16.3-00 kubeadm=1.16.3-00 kubectl=1.16.3-00
sudo apt-mark hold kubelet kubeadm kubectl

# Install K8s cluster
sudo kubeadm init --kubernetes-version=1.16.3 --skip-token-print

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Untaint the master in order to be able to run the cloudcore:
kubectl taint nodes node-role.kubernetes.io/master- --all

kubectl apply -f manifests/calico.yaml

kubectl create -f https://raw.githubusercontent.com/kubeedge/kubeedge/v1.1.0/build/crds/devices/devices_v1alpha1_device.yaml
kubectl create -f https://raw.githubusercontent.com/kubeedge/kubeedge/v1.1.0/build/crds/devices/devices_v1alpha1_devicemodel.yaml

curl -sLO https://raw.githubusercontent.com/kubeedge/kubeedge/v1.1.0/build/tools/certgen.sh
chmod +x certgen.sh
sudo sed -i 's/RANDFILE/#RANDFILE/g' /etc/ssl/openssl.cnf
sudo ./certgen.sh buildSecret | tee ./manifests/cloudcore/06-secret.yaml

kubectl apply -f manifests/cloudcore/
kubectl apply -f manifests/edgecore/

mkdir -p manifests/edgecore/certs
kubectl -n kubeedge get secret cloudcore -o jsonpath={.data."edge\.crt"} | base64 -d > manifests/edgecore/certs/edge.crt
kubectl -n kubeedge get secret cloudcore -o jsonpath={.data."edge\.key"} | base64 -d > manifests/edgecore/certs/edge.key
kubectl -n kubeedge get secret cloudcore -o jsonpath={.data."rootCA\.crt"} | base64 -d > manifests/edgecore/certs/rootCA.crt

