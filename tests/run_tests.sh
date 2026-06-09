#!/usr/bin/env bash

set -euo pipefail

# Test suite for btrfs-auto-snapshot
# This script uses sudo internally for commands that require root privileges.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BTRFS_AUTO_SNAP="${PROJECT_ROOT}/btrfs-auto-snapshot"

# Temporary files and mount points
IMG_FILE="btrfs_test.img"
MOUNT_POINT="mnt_test"
MOCK_MOUNTS="mock_mounts"
LOOP_DEV=""

log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $*"
}

cleanup() {
    log "Cleaning up..."
    if [ -n "${LOOP_DEV}" ]; then
        if mountpoint -q "${MOUNT_POINT}"; then
            sudo umount "${MOUNT_POINT}"
        fi
        sudo losetup -d "${LOOP_DEV}" || true
    fi
    [ -d "${MOUNT_POINT}" ] && rmdir "${MOUNT_POINT}"
    [ -f "${IMG_FILE}" ] && rm "${IMG_FILE}"
    [ -f "${MOCK_MOUNTS}" ] && rm "${MOCK_MOUNTS}"
    log "Cleanup complete."
}

trap cleanup EXIT

# 0. Check for sudo
if ! command -v sudo >/dev/null 2>&1; then
    log "ERROR: 'sudo' is required for these tests but not found in PATH."
    exit 1
fi

# 1. Setup
log "Setting up Btrfs loopback device..."
truncate -s 512M "${IMG_FILE}"
LOOP_DEV=$(sudo losetup -fP --show "${IMG_FILE}")
sudo mkfs.btrfs "${LOOP_DEV}"
mkdir -p "${MOUNT_POINT}"
sudo mount "${LOOP_DEV}" "${MOUNT_POINT}"

# Create mock mounts file for isolation
grep "${MOUNT_POINT}" /proc/mounts > "${MOCK_MOUNTS}"
export BTRFS_MOUNTS_FILE="${MOCK_MOUNTS}"

# 2. Basic Tests
log "Running basic tests..."

# Test 1: Single snapshot
log "Test 1: Create a single snapshot"
sudo -E "${BTRFS_AUTO_SNAP}" -l hourly "${MOUNT_POINT}"
if [ -d "${MOUNT_POINT}/.btrfs" ] && [ "$(sudo ls -1 "${MOUNT_POINT}/.btrfs" | wc -l)" -eq 1 ]; then
    log "PASS: Single snapshot created."
else
    log "FAIL: Single snapshot not found."
    exit 1
fi

# Test 2: Rotation
log "Test 2: Test rotation (keep 3)"
for i in {1..5}; do
    sudo -E "${BTRFS_AUTO_SNAP}" -l hourly -k 3 "${MOUNT_POINT}"
    sleep 1 # Ensure different timestamps
done

SNAP_COUNT=$(sudo ls -1 "${MOUNT_POINT}/.btrfs" | grep "hourly" | wc -l)
if [ "${SNAP_COUNT}" -eq 3 ]; then
    log "PASS: Rotation works (kept 3 snapshots)."
else
    log "FAIL: Rotation failed (expected 3, found ${SNAP_COUNT})."
    exit 1
fi

# Test 3: Multiple labels
log "Test 3: Multiple labels (hourly and daily)"
sudo -E "${BTRFS_AUTO_SNAP}" -l daily -k 2 "${MOUNT_POINT}"
sudo -E "${BTRFS_AUTO_SNAP}" -l daily -k 2 "${MOUNT_POINT}"
sudo -E "${BTRFS_AUTO_SNAP}" -l daily -k 2 "${MOUNT_POINT}"

HOURLY_COUNT=$(sudo ls -1 "${MOUNT_POINT}/.btrfs" | grep "hourly" | wc -l)
DAILY_COUNT=$(sudo ls -1 "${MOUNT_POINT}/.btrfs" | grep "daily" | wc -l)

if [ "${HOURLY_COUNT}" -eq 3 ] && [ "${DAILY_COUNT}" -eq 2 ]; then
    log "PASS: Multiple labels handled correctly."
else
    log "FAIL: Multiple labels failed (hourly: ${HOURLY_COUNT}, daily: ${DAILY_COUNT})."
    exit 1
fi

# Test 4: Subvolumes
log "Test 4: Nested subvolumes"
sudo btrfs subvolume create "${MOUNT_POINT}/subvol1"
sudo bash -c "echo 'data' > ${MOUNT_POINT}/subvol1/file.txt"

sudo -E "${BTRFS_AUTO_SNAP}" -l hourly -k 1 "${MOUNT_POINT}/subvol1"

if [ -d "${MOUNT_POINT}/subvol1/.btrfs" ]; then
    log "PASS: Snapshot of subvolume created."
else
    log "FAIL: Snapshot of subvolume not found."
    exit 1
fi

# Test 5: All subvolumes (//)
log "Test 5: Snapshot all subvolumes (//)"
# Clear .btrfs first to be sure
sudo rm -rf "${MOUNT_POINT}/.btrfs"
sudo rm -rf "${MOUNT_POINT}/subvol1/.btrfs"

sudo -E "${BTRFS_AUTO_SNAP}" -l adhoc -k 1 //

if [ -d "${MOUNT_POINT}/.btrfs" ] && [ -d "${MOUNT_POINT}/subvol1/.btrfs" ]; then
    log "PASS: Snapshot all (//) worked."
else
    log "FAIL: Snapshot all (//) failed."
    exit 1
fi

log "All tests passed successfully!"
