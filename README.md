# Unraid OpenRGB Plugin

This repository contains an Unraid plugin that installs a bundled OpenRGB
runtime and runs it in server mode.

## What it does

- Adds `OpenRGB` under `Settings > User Utilities` at `/Settings/OpenRGB`.
- Stores persistent settings in `/boot/config/plugins/openrgb/openrgb.cfg`.
- Defaults to the latest official OpenRGB x86_64 Linux AppImage release URL.
- Installs a release bundle containing the extracted official OpenRGB runtime.
- Uses the official OpenRGB logo for plugin branding.
- Starts OpenRGB as a background server with `--server`.
- Optionally loads `i2c-dev` and relaxes permissions for `/dev/i2c-*`,
  `/dev/hidraw*`, and `/dev/usb/hiddev*`.
- Starts OpenRGB through Unraid's native `event/started` plugin hook.

## Install

Copy `openrgb.plg` to your Unraid server and install it:

```bash
installplg /boot/config/plugins/openrgb.plg
```

The release plugin URL is:

```text
https://github.com/SkippyTheLost/unraid-openrgb/releases/latest/download/openrgb.plg
```

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

The GitHub release workflow downloads and extracts the official AppImage while
building `openrgb-<version>.tgz`. Unraid downloads that bundle and runs its
included `AppRun`, so plugin installation does not require FUSE or AppImage
extraction.

## Build and release

On Linux, build the release bundle with:

```bash
bash scripts/build-release.sh
```

The output is written to `dist/openrgb-2026.06.28.9.tgz`. To publish a release,
ensure the version in `openrgb.plg`, both build scripts, and the workflow match,
then push a tag with that exact version:

```bash
git tag 2026.06.28.9
git push origin 2026.06.28.9
```

GitHub Actions publishes both `openrgb.plg` and the matching versioned bundle
as release assets.
