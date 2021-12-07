sudo apt update
sudo apt install -y conntrack docker.io

curl -Lo /tmp/kubeedge.tar.gz https://github.com/kubeedge/kubeedge/releases/download/v1.1.0/kubeedge-v1.1.0-linux-amd64.tar.gz
tar xvfz /tmp/kubeedge.tar.gz -C /tmp

sudo mkdir -p /etc/kubeedge/conf
# Move all files into place
sudo mv /tmp/kubeedge-v1.1.0-linux-amd64/edge/edgecore /etc/kubeedge
sudo mv /tmp/kubeedge-v1.1.0-linux-amd64/edge/conf/* /etc/kubeedge/conf

sudo sed -i "s/fb4ebb70-2783-42b8-b3ef-63e2fd6d242e/$(hostname)/g" /etc/kubeedge/conf/edge.yaml
sudo sed -i 's/interface-name:.*/interface-name: enp0s8/g' /etc/kubeedge/conf/edge.yaml
sudo sed -i 's#wss://0.0.0.0:10000#wss://192.168.56.2:30000#g' /etc/kubeedge/conf/edge.yaml

sudo mkdir -p /etc/kubeedge/certs/
sudo cp manifests/edgecore/certs/* /etc/kubeedge/certs/

sudo tee /etc/systemd/system/edgecore.service <<EOF
[Unit]
Description=edgecore.service

[Service]
Type=simple
ExecStart=/etc/kubeedge/edgecore

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl restart edgecore
sudo systemctl enable edgecore
# Check the status of the edgecore
sudo systemctl status edgecore