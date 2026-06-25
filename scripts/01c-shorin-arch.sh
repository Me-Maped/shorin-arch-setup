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
    log "Receiving GPG key from keyserver..."
    if pacman-key --keyserver hkp://keys.openpgp.org --recv-keys "$KEY_FPR" 2>/dev/null; then
        pacman-key --lsign-key "$KEY_FPR" >/dev/null 2>&1
        success "GPG key received and signed."
    else
        warn "Failed to receive GPG key from keyserver."
        warn "You can manually import it later:"
        warn "  sudo pacman-key --keyserver hkp://keys.openpgp.org --recv-keys $KEY_FPR"
        warn "  sudo pacman-key --lsign-key $KEY_FPR"
    fi
fi

# ------------------------------------------------------------------------------
# 3. Refresh database
# ------------------------------------------------------------------------------
exe pacman -Sy
success "Shorin Arch repository configured."

log "Module 01c completed."
