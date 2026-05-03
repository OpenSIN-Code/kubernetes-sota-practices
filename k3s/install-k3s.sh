#!/bin/bash
# k3s Installation Script for Oracle Cloud A1.Flex VM (ARM64)
# Usage: curl -sfL https://get.k3s.io | sh -

set -e

echo "=========================================="
echo "🚀 k3s Installation for OCI A1.Flex VM"
echo "=========================================="

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo "⚠️  Warning: This script is optimized for ARM64 (A1.Flex)"
    echo "   Detected: $ARCH"
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Not running as root. Using k3s without installer..."
    echo "   For full installation, run: sudo $0"
fi

# Version to install (k3s v1.31+ for Kubernetes 1.31)
K3S_VERSION="v1.31.4+k3s1"

# Installation method: use k3sup for production or direct k3s installer
INSTALL_METHOD="${INSTALL_METHOD:-direct}"

case "$INSTALL_METHOD" in
    direct)
        echo "📥 Installing k3s directly..."
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" sh -
        ;;
    k3sup)
        echo "📥 Installing k3sup first..."
        curl -sfL https://get.k3s.io | sh -
        # For single-node, k3sup is overkill but available
        ;;
    *)
        echo "❌ Unknown installation method: $INSTALL_METHOD"
        echo "   Valid options: direct, k3sup"
        exit 1
esac

# Wait for k3s to be ready
echo "⏳ Waiting for k3s to start..."
sleep 10

# Verify installation
echo "✅ Verifying k3s installation..."
kubectl get nodes

# Show cluster info
echo ""
echo "=========================================="
echo "🎉 k3s Installation Complete!"
echo "=========================================="
echo ""
echo "📋 Cluster Info:"
kubectl cluster-info
echo ""
echo "📊 Nodes:"
kubectl get nodes -o wide
echo ""
echo "🔧 kubectl config location: /etc/rancher/k3s/k3s.yaml"
echo ""
echo "📝 Next steps:"
echo "   1. Copy kubeconfig to your local machine:"
echo "      ssh ubuntu@<vm-ip> 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/k3s.yaml"
echo ""
echo "   2. Install Helm on your local machine:"
echo "      brew install helm"
echo ""
echo "   3. Deploy Code-Swarm:"
echo "      export KUBECONFIG=~/k3s.yaml"
echo "      helm install code-swarm oci://ghcr.io/opensin-code/helm/code-swarm"
echo ""
echo "=========================================="

# Optional: Install additional tools
install_additional_tools() {
    echo "🔧 Installing additional tools..."

    # Install kubectl plugins
    echo "   - k9s (terminal UI)"
    curl -sS https://webinstall.dev/k9s | bash

    # Install Helm plugins
    echo "   - Helm diff plugin"
    helm plugin install https://github.com/databus23/helm-diff

    echo "✅ Additional tools installed"
}

# Ask user if they want additional tools
if [ "$INSTALL_ADDITIONAL_TOOLS" = "true" ]; then
    install_additional_tools
fi

echo "🚀 k3s is ready to use!"