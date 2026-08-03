# Kyyn releases

This public repository hosts Kyyn's official prebuilt application artifacts.
Download a version from the [Releases](https://github.com/drshade/kyyn-releases/releases)
page and verify it with the accompanying SHA-256 files or unified checksum.

The Kyyn engine is built and tested in its private source repository. Release
notes and manifests identify the exact private source revision used for each
build, while this repository provides stable anonymous download URLs.

GitHub automatically adds “Source code” archives to every release. Those
archives contain only this distribution repository and are **not** the source
used to build Kyyn. The actual application artifacts are the explicitly named
Kyyn archives, packages, checksums and installers attached to each release.

Release builds run here on standard public-repository runners. The manually
triggered workflow checks out only an exact `v*` tag from the private repository
using a contents-read token, verifies it resolves to the separately supplied full
commit OID, and uploads only the finalized binary artifact set. The source
checkout and token are never uploaded.

The workflow requires `KYYN_SOURCE_TOKEN` (contents-read access to only
`drshade/kyyn`) and `HOMEBREW_TAP_TOKEN` (contents-write access to only
`drshade/homebrew-kyyn`). Publication is `workflow_dispatch`-only: pushes and
pull requests in this public repository cannot publish.
