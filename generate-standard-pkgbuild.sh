#!/bin/sh

source_x86_64="https://github.com/gohugoio/hugo/releases/download/v${VERSION_NUMBER}/hugo_${VERSION_NUMBER}_linux-amd64.tar.gz"
source_aarch64="https://github.com/gohugoio/hugo/releases/download/v${VERSION_NUMBER}/hugo_${VERSION_NUMBER}_linux-arm64.tar.gz"

wget "https://github.com/gohugoio/hugo/releases/download/v${VERSION_NUMBER}/hugo_${VERSION_NUMBER}_checksums.txt" -O checksums.txt

sha256sums_x86_64="$(grep "hugo_${VERSION_NUMBER}_linux-amd64.tar.gz" checksums.txt | cut -d ' ' -f 1)"
sha256sums_aarch64="$(grep "hugo_${VERSION_NUMBER}_linux-arm64.tar.gz" checksums.txt | cut -d ' ' -f 1)"

cat <<EOF
# Maintainer: xeptore
# Contributor: Porous3247 <pqtb3v7t at jasonyip1 dot anonaddy dot me>
pkgname=gohugo-bin
pkgver=${VERSION_NUMBER}
pkgrel=3
pkgdesc="Hugo - The world's fastest framework for building websites"
arch=('x86_64' 'aarch64')
url='https://gohugo.io/'
license=('Apache')
depends=('glibc')
conflicts=('hugo')
provides=('hugo')
source_x86_64=('${source_x86_64}')
source_aarch64=('${source_aarch64}')
sha256sums_x86_64=('${sha256sums_x86_64}')
sha256sums_aarch64=('${sha256sums_aarch64}')

package() {
  cd "\${srcdir}"
  install -Dm644 README.md -t "\${pkgdir}/usr/share/doc/hugo"
  install -Dm644 LICENSE -t "\${pkgdir}/usr/share/licenses/hugo"
  install -Dm755 "hugo" -t "\${pkgdir}/usr/bin"
}
EOF
