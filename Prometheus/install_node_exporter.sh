#!/bin/bash

# Node Exporter version
NODE_EXPORTER_VERSION="1.8.2"

# Detect system architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    NODE_EXPORTER_ARCH="linux-amd64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    NODE_EXPORTER_ARCH="linux-arm64"
elif [[ "$ARCH" == "armv7l" || "$ARCH" == "armv6l" ]]; then
    NODE_EXPORTER_ARCH="linux-armv7"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download and install Node Exporter
echo "Downloading Node Exporter version $NODE_EXPORTER_VERSION for $NODE_EXPORTER_ARCH..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.${NODE_EXPORTER_ARCH}.tar.gz -O /tmp/node_exporter.tar.gz

echo "Extracting Node Exporter..."
tar -xvf /tmp/node_exporter.tar.gz -C /tmp

# Move the binary to /usr/local/bin
echo "Installing Node Exporter..."
sudo mv /tmp/node_exporter-${NODE_EXPORTER_VERSION}.${NODE_EXPORTER_ARCH}/node_exporter /usr/local/bin/

# Clean up the temporary files
rm -rf /tmp/node_exporter*

# Create a system user for Node Exporter
echo "Creating a system user for Node Exporter..."
sudo useradd -rs /bin/false node_exporter

# Create systemd service file
echo "Creating systemd service file for Node Exporter..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Reload systemd and start Node Exporter service
echo "Starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Check status
echo "Checking Node Exporter service status..."
sudo systemctl status node_exporter --no-pager

echo "Node Exporter installation complete. You can verify by visiting http://localhost:9100/metrics"

