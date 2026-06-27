# Unraid OpenRGB Plugin

This repository contains a single-file Unraid plugin that installs a small
Settings page and runs OpenRGB in server mode.

## What it does

- Adds `Settings > OpenRGB` in the Unraid web UI at `/Settings/OpenRGB`.
- Stores persistent settings in `/boot/config/plugins/openrgb/openrgb.cfg`.
- Defaults to the latest official OpenRGB x86_64 Linux AppImage release URL.
- Downloads and installs the official OpenRGB Linux AppImage during plugin install.
- Uses the official OpenRGB logo for plugin branding.
- Starts OpenRGB as a background server with `--server`.
- Optionally loads `i2c-dev` and relaxes permissions for `/dev/i2c-*`,
  `/dev/hidraw*`, and `/dev/usb/hiddev*`.
- Starts OpenRGB at boot from `/boot/config/go`.

## Install

Copy `openrgb.plg` to your Unraid server and install it:

```bash
installplg /boot/config/plugins/openrgb.plg
```

For distribution, update the `pluginURL` entity near the top of
`openrgb.plg` to point at the raw URL for your hosted copy.

## Configure

1. Open `Settings > OpenRGB`.
2. Set `Enable OpenRGB` to `Yes`.
3. Click `Start` or `Apply`.

The default port is `6742`, which is OpenRGB's usual SDK/server port.

If an older install still appears inline on `/Settings`, reinstall the plugin
so `/usr/local/emhttp/plugins/openrgb/OpenRGB.page` is regenerated with the
standalone page metadata.

The default AppImage is OpenRGB `1.0rc2` x86_64:

```text
https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage
```

## Manual service commands

```bash
/etc/rc.d/rc.openrgb install
/etc/rc.d/rc.openrgb start
/etc/rc.d/rc.openrgb stop
/etc/rc.d/rc.openrgb restart
/etc/rc.d/rc.openrgb status
```

Logs are written to:

```bash
/var/log/openrgb.log
```

## Notes

OpenRGB hardware access depends on the motherboard, controller, kernel
drivers, and device permissions. Some devices require i2c access, while others
use hidraw. The plugin enables the common device paths, but OpenRGB support is
still hardware-specific.

The service script caches the AppImage on `/boot`, copies it to `/usr/local`,
extracts it there, and runs the extracted `AppRun`. Direct AppImage execution
is not used because Unraid systems commonly lack FUSE support for AppImages,
and `/boot` may be mounted with `noexec`.
