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

# Lucky is packaged in its own feed repository.
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main" "" "luci-app-lucky"

# SSR Plus+ and its common dependencies.
UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"

# Remove management / AC controller packages if inherited from feeds.
find ./ ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d \( -iname "gecoosac" -o -iname "luci-app-gecoosac" \) -prune -exec rm -rf {} + 2>/dev/null || true

if [ -f "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh" ]; then
	source "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh"
fi
