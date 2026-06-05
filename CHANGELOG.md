# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial SIN-Code-Bundle integration (ceo-audit workflow v3)
- OpenCode MCP server registration under `OpenSIN-Code/kubernetes-sota-practices`
- Repository-level `SIN_GITHUB_FALLBACK_TOKEN` secret for the App commenter fallback
- Production-ready Kubernetes manifests for Code-Swarm and OpenSIN services
- k3s on OCI A1.Flex, Minikube, and Kind deployment paths (all free tier)
- Helm charts, Istio service mesh configs, and Prometheus/Grafana monitoring
- `scripts/` bootstrap and tear-down helpers for the three deployment targets

### Security
- All commits verified via `git-immortal-commit` (annotated tags)
- Network policies restrict east-west traffic in the `code-swarm` namespace

