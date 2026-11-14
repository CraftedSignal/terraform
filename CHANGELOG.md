# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

- Allow Google provider v8 while retaining support for v7.31 and later v7 releases.
- Initialized the `gcp` provider package with a production platform module.
- Added a production GCP example, package documentation, generated module docs, CI, Dependabot, release automation, and security scanning.
- Avoid rendering a disabled GKE `confidential_nodes` block so existing non-confidential clusters do not plan replacement.
