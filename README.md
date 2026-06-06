# Athena OpenWrt CI

GitHub Actions build config for JDCloud AX1800 Pro / Athena / `jdcloud_re-ss-01`.

## Target

- Source: `https://github.com/VIKINGYFY/immortalwrt.git`
- Branch: `main`
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

## Build

Push to `main`, or run the `Athena` workflow manually.

The firmware is uploaded as a workflow artifact and also published as a GitHub Release.
