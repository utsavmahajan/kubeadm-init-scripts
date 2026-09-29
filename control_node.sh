clear

# Init Kubeadm
sudo kubeadm init \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --pod-network-cidr=10.244.0.0/16


#To start using your cluster, you need to run the following as a regular user:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# CNI Installation

# 1)Install the Tigera Operator and custom resource definitions.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/v1_crd_projectcalico_org.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/tigera-operator.yaml

# 2)Download the custom resources necessary to configure Calico.
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/custom-resources-bpf.yaml
sudo sed -i 's|cidr: 192.168.0.0/16|cidr: 10.244.0.0/16|' /home/ubuntu/custom-resources-bpf.yaml
grep -n "cidr:" /home/ubuntu/custom-resources-bpf.yaml

# 3) Create the manifest to install Calico.
kubectl create -f custom-resources-bpf.yaml

# 4) Waiting
sleep 320
kubectl get tigerastatus

# Getting The join Command
kubeadm token create --print-join-command
