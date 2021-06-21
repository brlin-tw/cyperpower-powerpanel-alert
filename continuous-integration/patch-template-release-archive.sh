#!/usr/bin/env sh
# Patch template release archive for project only differences
#
# Copyright 2021 林博仁(Buo-ren, Lin) <Buo.Ren.Lin@gmail.com>
# SPDX-License-Identifier: CC-BY-SA-4.0

# Ensure script terminates when problems occurred
set \
    -o errexit \
    -o nounset
set -x
PRODUCT_IDENTIFIER="${PRODUCT_IDENTIFIER:-${DRONE_REPO#*/}}"

apk add \
    git \
	gzip \
	sed \
	tar

git_describe="$(
    git describe \
        --always \
        --tags \
        --dirty
)"
product_version="${git_describe#v}"
product_release_id="${PRODUCT_IDENTIFIER}"-"${product_version}"

# Updating tar requires uncompressed tarball
gunzip \
    --force \
	--verbose \
	"${product_release_id}".tar.gz
tar \
	--append \
	--verbose \
	--file "${product_release_id}".tar \
	--transform="flags=r;s|(.*)\\.shipped$|${product_release_id}/\\1|x" \
	.*.shipped
gzip \
	--verbose \
	"${product_release_id}".tar

echo
echo Product release archive patched successfully.
