#!/bin/bash

# ==============================================================================
# 01c-shorin-arch.sh - Configure Shorin Arch Repository
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00-utils.sh"

check_root

log "Starting: Shorin Arch Repository configuration..."

KEY_FPR="8ED9ABE61CDBAABAC4B6A694C9218E60C13B4BA8"

# ------------------------------------------------------------------------------
# 1. Add repository to pacman.conf
# ------------------------------------------------------------------------------
if grep -q "\[shorin-arch\]" /etc/pacman.conf; then
    success "shorin-arch repository already exists."
else
    log "Adding shorin-arch repository to pacman.conf..."
    echo "" >> /etc/pacman.conf
    cat <<EOT >> /etc/pacman.conf
[shorin-arch]
Server = https://repo.shorin.xyz/archlinux/\$arch
EOT
    success "Repository added."
fi

# ------------------------------------------------------------------------------
# 2. Import and sign GPG key
# ------------------------------------------------------------------------------
if pacman-key --list-keys "$KEY_FPR" >/dev/null 2>&1; then
    success "GPG key already present."
else
    log "Downloading and importing GPG key..."
    if curl -sL --max-time 15 "https://repo.shorin.xyz/archlinux/shorin-arch.pub" | pacman-key --add - 2>/dev/null; then
        pacman-key --lsign-key "$KEY_FPR" >/dev/null 2>&1
        success "GPG key imported and signed."
    else
        warn "Failed to download GPG key from repo.shorin.xyz."
        warn "You can manually import it later:"
        warn "  curl -sL https://repo.shorin.xyz/archlinux/shorin-arch.pub | sudo pacman-key --add -"
        warn "  sudo pacman-key --lsign-key $KEY_FPR"
    fi
fi

# ------------------------------------------------------------------------------
# 3. Refresh database
# ------------------------------------------------------------------------------
exe pacman -Sy
success "Shorin Arch repository configured."

log "Module 01c completed."
