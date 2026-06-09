#!/bin/bash
# SPDX-License-Identifier: MIT

set -e

UPDATE_PACKAGE() {
	local PKG_NAME="$1"
	local PKG_REPO="$2"
	local PKG_BRANCH="$3"
	local PKG_SPECIAL="${4:-}"
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME="${PKG_REPO#*/}"

	echo "Updating package: $PKG_NAME"

	for NAME in "${PKG_LIST[@]}"; do
		find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" -prune -exec rm -rf {} + 2>/dev/null || true
		find ./ -maxdepth 3 -type d -iname "*$NAME*" -prune -exec rm -rf {} + 2>/dev/null || true
	done

	git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"

	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find "./$REPO_NAME" -mindepth 1 -maxdepth 4 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf "./$REPO_NAME"
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f "$REPO_NAME" "$PKG_NAME"
	fi
}

# LuCI integration for Lucky is kept, but the runtime binary is pinned in Files/.
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main" "" "luci-app-lucky"

# SSR Plus+ and common dependencies.
UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"

# HWRT SSR Plus+ backups can contain Hysteria2 nodes without local_port.
SSR_INIT="$(find ./helloworld -path "*/luci-app-ssr-plus/root/etc/init.d/shadowsocksr" -type f | head -n 1)"
if [ -n "$SSR_INIT" ]; then
	python3 - <<'PY' "$SSR_INIT"
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

helper = r'''
get_node_local_port() {
	local port="$(uci_get_by_name "$1" local_port)"
	[ -n "$port" ] || port="$(uci_get_by_type global default_node_local_port 1234)"
	[ -n "$port" ] || port="1234"
	echo "$port"
}
'''

if "get_node_local_port()" not in text:
	text = text.replace(
		'uci_get_by_cfgid() {\n'
		'\tlocal ret=$(uci show $NAME.@$1[0].$2 | awk -F \'.\' \'{print $2}\' 2>/dev/null)\n'
		'\techo ${ret:=$3}\n'
		'}\n',
		'uci_get_by_cfgid() {\n'
		'\tlocal ret=$(uci show $NAME.@$1[0].$2 | awk -F \'.\' \'{print $2}\' 2>/dev/null)\n'
		'\techo ${ret:=$3}\n'
		'}\n' + helper
	)

text = text.replace(
	'\tlocal tcp_port=$(uci_get_by_name $GLOBAL_SERVER local_port)\n',
	'\tlocal tcp_port=$(get_node_local_port $GLOBAL_SERVER)\n'
)
text = text.replace(
	'\tlocal local_port=$(uci_get_by_name $GLOBAL_SERVER local_port)\n',
	'\tlocal local_port=$(get_node_local_port $GLOBAL_SERVER)\n'
)

path.write_text(text)
PY
fi

find ./ ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d \( -iname "gecoosac" -o -iname "luci-app-gecoosac" \) -prune -exec rm -rf {} + 2>/dev/null || true

if [ -f "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh" ]; then
	source "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh"
fi
