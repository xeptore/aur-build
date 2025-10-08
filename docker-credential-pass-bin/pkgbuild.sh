#!/bin/bash

set -Eexuo pipefail

if [[ ! -v VERSION ]]; then
  echo "'VERSION' variable must be set in the environment." 1>&2
  exit 1
fi

source_x86_64="https://github.com/docker/docker-credential-helpers/releases/download/v${VERSION}/docker-credential-pass-v${VERSION}.linux-amd64"
license_file_url="https://raw.githubusercontent.com/docker/docker-credential-helpers/v${VERSION}/LICENSE"

wget -q "https://github.com/docker/docker-credential-helpers/releases/download/v${VERSION}/checksums.txt" -O checksums.txt
wget -q "$license_file_url" -O LICENSE

sha256sums_x86_64="$(grep "docker-credential-pass-v${VERSION}.linux-amd64" checksums.txt | cut -d ' ' -f 1)"
sha256sums_license="$(sha256sum LICENSE | cut -d ' ' -f 1)"
pkgname='docker-credential-pass-bin'

wget -q https://aur.archlinux.org/rpc/v5/info/${pkgname} --header='accept: application/json' -O pkg-info.json

pkgrel="$(jq -r '.results[0].Version' pkg-info.json | sed -n 's/^.*-//p')"
echo "Got pkgrel $pkgrel on the AUR."

self_latest_version="$(jq -r '.results[0].Version' pkg-info.json | sed -n 's/-[[:digit:]]\+$//p')"
echo "Got version $self_latest_version on the AUR."
if [[ "$self_latest_version" != "${VERSION}" ]]; then
  echo 'Resetting pkgrel...'
  pkgrel='1'
elif [[ ! -v NO_PKGREL_INCREMENT ]]; then
  echo 'Incrementing pkgrel...'
  pkgrel=$((pkgrel + 1))
fi

cat >PKGBUILD <<EOF
# Maintainer: Joel Noyce Barnham <joelnbarnham@gmail.com>
# Contributor: xeptore <hello [ at ] xeptore [ dot ] dev>

pkgname=${pkgname}
pkgver=${VERSION}
pkgrel=${pkgrel}
pkgdesc='Store docker credentials using the Standard Unix Password Manager (pass)'
arch=('x86_64')
url='https://github.com/docker/docker-credential-helpers'
license=('MIT')
depends=('pass')
makedepends=()
provides=("${pkgname%-bin}")
conflicts=("${pkgname%-bin}")
source_x86_64=(
  'docker-credential-pass-v${VERSION}.linux-amd64::${source_x86_64}'
  'LICENSE::${license_file_url}'
)
sha256sums_x86_64=(
  '${sha256sums_x86_64}'
  '${sha256sums_license}'
)

package() {
  install -D -m 0755 "\${srcdir}/docker-credential-pass-v\${pkgver}.linux-amd64" "\${pkgdir}/usr/bin/docker-credential-pass"
  install -D -m 0644 "\${srcdir}/LICENSE" "\${pkgdir}/usr/share/licenses/\${pkgname}/LICENSE"
}
EOF
