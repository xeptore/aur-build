#!/bin/bash

set -e -o pipefail

if [[ ! -v VERSION ]]; then
  echo "'VERSION' variable must be set in the environment." 1>&2
  exit 1
fi

source_x86_64="https://github.com/docker/docker-credential-helpers/archive/refs/tags/v${VERSION}.tar.gz"
license_file_url="https://raw.githubusercontent.com/docker/docker-credential-helpers/v${VERSION}/LICENSE"

wget -q "$source_x86_64" -O source.tar.gz
wget -q "$license_file_url" -O LICENSE

sha256sums_x86_64="$(sha256sum source.tar.gz | cut -d ' ' -f 1)"
sha256sums_license="$(sha256sum LICENSE | cut -d ' ' -f 1)"

pkgname='docker-credential-pass'

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
# Contributor: Magnus Bjerke Vik <mbvett@gmail.com>

pkgname=${pkgname}
pkgver=${VERSION}
pkgrel=${pkgrel}
pkgdesc='Store docker credentials using the Standard Unix Password Manager (pass)'
arch=(x86_64)
url='https://github.com/docker/docker-credential-helpers'
license=('MIT')
depends=('pass')
makedepends=('go')
_gourl='github.com/docker/docker-credential-helpers'
source_x86_64=(
  'docker-credential-helpers-v${VERSION}.tar.gz::${source_x86_64}'
  'LICENSE::${license_file_url}'
)
sha256sums_x86_64=(
  '${sha256sums_x86_64}'
  '${sha256sums_license}'
)
noextract=('docker-credential-helpers-v${VERSION}.tar.gz')

prepare() {
  mkdir -p "\${srcdir}/src/\${_gourl}"
  tar -x --strip-components=1 -C "\${srcdir}/src/\${_gourl}" -f "\${srcdir}/docker-credential-helpers-v${VERSION}.tar.gz"
}

build() {
  cd "\${srcdir}/src/\${_gourl}"
  GO111MODULE=off GOPATH="\${srcdir}" go install -v -x ./credentials
  GO111MODULE=off GOPATH="\${srcdir}" make pass
}

package() {
  cd "\${srcdir}/src/\${_gourl}"
  install -D -m 0755 bin/build/docker-credential-pass "\${pkgdir}/usr/bin/docker-credential-pass"
  install -D -m 0644 LICENSE "\${pkgdir}/usr/share/licenses/\${pkgname}/LICENSE"
}
EOF
