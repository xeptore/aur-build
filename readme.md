# Hugo AUR Build

Builds the latest release of [Hugo](https://gohugo.io) static website generator on schedule, and publishes to the [AUR](https://aur.archlinux.org/).

## Installation

Packages are available for install on the AUR:

- Standard Edition: [`gohugo-bin`](https://aur.archlinux.org/packages/gohugo-bin)
- Extended Edition: [`gohugo-extended-bin`](https://aur.archlinux.org/packages/gohugo-extended-bin)

You can install it using any AUR helper you prefer, e.g., [`yay`](https://github.com/Jguer/yay).

## Features

- Automatically versioned, and published based on upstream release
- Support for `x86_64`, and `aarch64` architectures
- Installs command line completions for `zsh`, `bash`, and `fish`
- Installs man pages

## Limitations

- Only builds, and publishes the latest stable (non-prerelease, and non-draft) release of the upstream Hugo project repository
