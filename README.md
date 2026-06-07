# Athena OpenWrt CI

GitHub Actions build config for JDCloud AX1800 Pro / Athena / `jdcloud_re-ss-01`.

## Target

- Source: `https://github.com/VIKINGYFY/immortalwrt.git`
- Branch: `owrt`
- Platform: `qualcommax/ipq60xx`
- Device: `jdcloud_re-ss-01`
- Default LAN IP: `192.168.20.1`

## Included Packages

- `mwan3`
- `luci-app-mwan3`
- `iptables-mod-ipopt`
- `kmod-ipt-ipopt`
- `lucky`
- `luci-app-lucky`
- `luci-app-ssr-plus`
- `shadowsocksr-libev`
- `xray-core`

## Update Check

The firmware includes `/usr/bin/athena-upgrade-check`.

It checks the latest GitHub Release every day at 04:20 and writes a notice to `/tmp/athena-upgrade.notice` when a new `jdcloud_re-ss-01` sysupgrade image is available. It only checks and notifies; it does not flash firmware automatically.

## Build

Push to `main`, or run the `Athena` workflow manually.

The firmware is uploaded as a workflow artifact and also published as a GitHub Release.
