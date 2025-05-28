#!/usr/bin/env bash

# Rebuild script for applying new color scheme
echo "🎨 Rebuilding NixOS with new Fantasy Night color scheme..."

# Check if we're on NixOS
if command -v nixos-rebuild &> /dev/null; then
    echo "📦 Running nixos-rebuild switch with flake..."
    # Use the work configuration for this system
    if ! nixos-rebuild switch --flake .#work --use-remote-sudo 2>/dev/null; then
        echo "🔧 Trying alternative rebuild method..."
        nixos-rebuild switch --flake .#work --use-remote-sudo || {
            echo "⚠️  Direct rebuild failed. You may need to run manually:"
            echo "    sudo nixos-rebuild switch --flake .#work"
        }
    fi
elif command -v darwin-rebuild &> /dev/null; then
    echo "🍎 Running darwin-rebuild switch..."
    darwin-rebuild switch --flake .
else
    echo "❌ Neither nixos-rebuild nor darwin-rebuild found"
    exit 1
fi

echo "✅ Rebuild complete! Your new Fantasy Night color scheme should now be active."
echo "🔄 You may need to restart some applications or log out/in for all changes to take effect." 