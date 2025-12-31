#!/bin/bash
set -ouex pipefail

# This script runs ONCE during the GitHub build process.

echo "🐻 Configuring UrsaOS System Defaults..."

# 1. Ensure the ublue-os just directory exists
mkdir -p /usr/share/ublue-os/just

# 2. Create a dedicated justfile for UrsaOS
# We use > (overwrite/create) instead of >> (append) to avoid errors
cat <<EOF >/usr/share/ublue-os/just/60-ursa.just

# --- UrsaOS Setup Commands ---

# Install Nix and bootstrap TimothyBear11/nixdots
install-nix:
    echo "🐻 Phase 1: Installing Nix Package Manager..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    echo "🐻 Phase 2: Cloning TimothyBear11/nixdots..."
    if [ -d "\$HOME/nixdots" ]; then \
        mv \$HOME/nixdots \$HOME/nixdots.bak.\$(date +%s); \
    fi
    git clone https://github.com/TimothyBear11/nixdots.git \$HOME/nixdots
    
    echo "🐻 Phase 3: Activating Home Manager (Impure)..."
    # Note: You may need to open a new shell or source the nix profile before this works
    # We use the full path to nix to be safe
    /nix/var/nix/profiles/default/bin/nix run home-manager/master -- switch --flake \$HOME/nixdots/#tbear --impure
    
    echo "🐠 Phase 4: Switching Shell to Fish..."
    sudo usermod -s /usr/bin/fish \$(whoami)
    
    echo "🎉 UrsaOS Setup Complete! Please reboot to see your shells."
EOF

echo "✅ UrsaOS Justfile created at /usr/share/ublue-os/just/60-ursa.just"
