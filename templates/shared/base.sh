#!/usr/bin/env bash
set -x

echo "==> Base"

echo "==> getting the aws metadata token"
export TOKEN=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

echo "==> check token was set"
echo $TOKEN


echo "==> libc6 issue workaround"
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections

function install_from_url {
  cd /tmp && {
    curl -sfLo "$${1}.zip" "$${2}"
    unzip -qq "$${1}.zip"
    sudo mv "$${1}" "/usr/local/bin/$${1}"
    sudo chmod +x "/usr/local/bin/$${1}"
    rm -rf "$${1}.zip"
  }
}

source /etc/profile.d/ips.sh

echo "--> Updating apt-cache"
ssh-apt update



echo "--> Setting iptables for bridge networking"
echo 1 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "--> Making iptables settings for bridge networking config change"
sudo tee /etc/sysctl.d/nomadtables > /dev/null <<EOF
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo "--> Adding Hashicorp repo"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "--> Adding Microsoft repo"
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg


echo "--> updated version of Nodejs"
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -

sudo apt update

echo "--> Installing common dependencies"
sudo apt-get install -y \
  build-essential \
  nodejs \
  curl \
  emacs \
  git \
  jq \
  tmux \
  unzip \
  vim \
  wget \
  tree \
  nfs-kernel-server \
  nfs-common \
  python3-pip \
  ruby-full \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  openjdk-17-jdk-headless \
  prometheus-node-exporter \
  golang-go \
  alien \
  waypoint \
  qemu-system \
  code \
  &>/dev/null


echo "--> Disabling checkpoint"
sudo tee /etc/profile.d/checkpoint.sh > /dev/null <<"EOF"
export CHECKPOINT_DISABLE=1
EOF
source /etc/profile.d/checkpoint.sh

if [ ${enterprise} == 0 ]
then
sudo apt-get install -y \
  vault \
  consul \
  nomad  \
  &>/dev/null

else
sudo apt-get install -y \
  vault-enterprise \
  consul-enterprise \
  nomad-enterprise  \
  &>/dev/null

fi

# echo "--> Install Envoy"
#  curl -L https://getenvoy.io/cli | sudo bash -s -- -b /usr/local/bin
#  getenvoy run standard:1.16.0 -- --version
#  sudo cp ~/.getenvoy/builds/standard/1.16.0/linux_glibc/bin/envoy /usr/bin/


echo "==> Base is done!"
