btrfs-auto-snapshot
===================

BTRFS Automatic Snapshot Service for Linux

A BTRFS implementation of the zfs-auto-snapshot found at https://github.com/hunleyd/btrfs-auto-snapshot.git. This utility creates, rotates, and destroys periodic BTRFS snapshots labelling each uniquely (@btrfs-auto-snap_hourly, @btrfs-auto-snap_daily, et al).

This program strives to be a posixly correct Bourne shell script. It depends only on the BTRFS utilities and cron, and can be run in the dash shell.
