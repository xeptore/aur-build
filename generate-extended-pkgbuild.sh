#!/bin/bash

set -e -o pipefail

if [[ ! -v VERSION_NUMBER ]]; then
  echo "'VERSION_NUMBER' variable must be set in the environment." 1>&2
  exit 1
fi

source_x86_64="https://github.com/gohugoio/hugo/releases/download/v${VERSION_NUMBER}/hugo_extended_${VERSION_NUMBER}_linux-amd64.tar.gz"
source_aarch64="https://github.com/gohugoio/hugo/releases/download/v${VERSION_NUMBER}/hugo_extended_${VERSION_NUMBER}_linux-arm64.tar.gz"

wget -q "https://github.com/gohugoio/hugo/releases/download/v${VERSION_NUMBER}/hugo_${VERSION_NUMBER}_checksums.txt" -O checksums.txt

sha256sums_x86_64="$(grep "hugo_extended_${VERSION_NUMBER}_linux-amd64.tar.gz" checksums.txt | cut -d ' ' -f 1)"
sha256sums_aarch64="$(grep "hugo_extended_${VERSION_NUMBER}_linux-arm64.tar.gz" checksums.txt | cut -d ' ' -f 1)"

pkgname='gohugo-extended-bin'

wget -q https://aur.archlinux.org/rpc/v5/info/${pkgname} --header='accept: application/json' -O pkg-info.json

pkgrel="$(jq -r '.results[0].Version' pkg-info.json | sed -n 's/^.*-//p')"
echo "Got pkgrel $pkgrel on the AUR."

self_latest_version="$(jq -r '.results[0].Version' pkg-info.json | sed -n 's/-[[:digit:]]$//p')"
echo "Got version $self_latest_version on the AUR."
if [[ "$self_latest_version" != "${VERSION_NUMBER}" ]]; then
  echo 'Resetting pkgrel...'
  pkgrel='1'
elif [[ ! -v NO_PKGREL_INCREMENT ]]; then
  echo 'Incrementing pkgrel...'
  pkgrel=$((pkgrel + 1))
fi

cat >PKGBUILD <<EOF
# Maintainer: xeptore
# Contributor: Porous3247 <pqtb3v7t at jasonyip1 dot anonaddy dot me>

pkgname=${pkgname}
pkgver=${VERSION_NUMBER}
pkgrel=${pkgrel}
pkgdesc="Hugo - The world's fastest framework for building websites (Extended Edition)"
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

build() {
  cd "\${srcdir}"
  ./hugo gen man --dir man
  ./hugo completion bash > hugo.bash-completion
  ./hugo completion fish > hugo.fish
  ./hugo completion zsh > hugo.zsh
}

package() {
  cd "\${srcdir}"
  install -Dm755 hugo "\${pkgdir}/usr/bin/hugo"
  install -Dm644 LICENSE "\${pkgdir}/usr/share/licenses/hugo/LICENSE"
  install -Dm644 man/*.1 -t "\${pkgdir}"/usr/share/man/man1/
  install -Dm644 hugo.bash-completion "\${pkgdir}/usr/share/bash-completion/completions/hugo"
  install -Dm644 hugo.fish "\${pkgdir}/usr/share/fish/vendor_completions.d/hugo.fish"
  install -Dm644 hugo.zsh "\${pkgdir}/usr/share/zsh/site-functions/_hugo"
}
EOF
