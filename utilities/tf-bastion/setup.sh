#!/bin/bash

## INSTALL AWS CLI
apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version


## INSTALL HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh


## INSTALL KUBECTL 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
chmod +x kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Configure Autocomplete
apt-get install -y bash-completion 
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

# install kubectx
echo "deb [trusted=yes] http://ftp.de.debian.org/debian buster main" >> /etc/apt/sources.list
sudo apt-get update
sudo apt install kubectx

# install terraform 1.5.5
# Ref - https://askubuntu.com/questions/983351/how-to-install-terraform-in-ubuntu
wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
unzip terraform_1.5.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo echo 'alias tf=terraform' >> ~/.bashrc
echo 'alias tf=terraform' >> ~/.bashrc
terraform --version 