# 🚀 SOTA Kubernetes Best Practices for Code-Swarm & OpenSIN

## Overview

This repository contains production-ready Kubernetes configurations for deploying **Code-Swarm** (multi-agent swarm orchestration system) and related OpenSIN services on **free tier infrastructure**.

## 🎯 Infrastructure Options (All Free!)

| Option | Provider | Resources | Perfect For |
|--------|----------|-----------|-------------|
| **k3s on OCI A1.Flex** | Oracle Cloud | 4x ARM CPU, 24GB RAM | ✅ **Recommended** (Zero cost, full Kubernetes) |
| **Minikube** | Local | Variable | Development only |
| **Kind** | Local | Docker-based | Testing only |

## 📦 What's Included

### 1. k3s Installation (`k3s/`)
- **Single-node k3s setup** for OCI A1.Flex VM
- **ARM64 optimized** (perfect for Oracle ARM instances)
- **Air-gapped installation** support
- **Automatic failback** and health checks

### 2. Helm Charts (`helm/code-swarm/`)
- **API Gateway** (FastAPI + gRPC on ports 8000/50051)
- **Agent Workers** (SIN-Zeus, SIN-Solo, coder-sin-swarm)
- **Simone-MCP** integration (AST-level code operations)
- **WebSocket streaming** for real-time status
- **ConfigMaps & Secrets** management

### 3. Auto-Scaling (`templates/hpa-*.yaml`)
- **Horizontal Pod Autoscaler (HPA)** for all deployments
- **CPU/Memory-based** scaling rules
- **Custom metrics** support (agent task queue depth)

### 4. Service Mesh (`istio/`)
- **Istio Ambient Mode** (zero-trust, no sidecars)
- **mTLS** between services
- **Rate limiting** at mesh level
- **Observability** (traces, metrics, logs)

### 5. Monitoring (`monitoring/`)
- **Prometheus** + **Grafana** stack
- **OpenTelemetry** collector
- **Agent metrics** (task completion, latency, errors)
- **System metrics** (CPU, RAM, network)

### 6. CI/CD Pipeline (`.github/workflows/`)
- **GitHub Actions** for automated deployments
- **Helm chart publishing** to GitHub Container Registry
- **Multi-environment** promotion (dev → staging → prod)

## 🚀 Quick Start: k3s on Oracle Cloud (Free Tier)

```bash
# 1. SSH into your OCI A1.Flex VM (Ubuntu)
ssh ubuntu@<your-vm-ip>

# 2. Download and install k3s (single command!)
curl -sfL https://get.k3s.io | sh -

# 3. Verify installation
kubectl get nodes
# Should show: "Ready" status for your node

# 4. Get kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml > ~/k3s.yaml
chmod 600 ~/k3s.yaml

# 5. Deploy Code-Swarm from your local machine
export KUBECONFIG=~/k3s.yaml

# Clone this repo
git clone https://github.com/OpenSIN-Code/kubernetes-sota-practices.git
cd kubernetes-sota-practices

# Install Helm chart
helm install code-swarm ./helm/code-swarm \
  --namespace code-swarm \
  --create-namespace \
  --set api_gateway.replicas=2 \
  --set agent_workers.replicas=3

# Verify deployment
kubectl get pods -n code-swarm
```

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud OCI A1.Flex                  │
│                        (Free Tier VM)                        │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    k3s Cluster                           │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │ │
│  │  │ API Gateway │  │ Agent Pods  │  │ Simone-MCP      │  │ │
│  │  │ (FastAPI)   │  │ (Workers)   │  │ (AST Operations)│  │ │
│  │  │  Port:8000  │  │  Scaling    │  │  Port:8234      │  │ │
│  │  │  Port:50051 │  │  HPA        │  │                 │  │ │
│  │  └──────┬──────┘  └──────┬──────┘  └────────┬────────┘  │ │
│  │         │                │                   │          │ │
│  │  ┌──────┴────────────────┴───────────────────┴──────┐   │ │
│  │  │              Istio Service Mesh                   │   │ │
│  │  │         (mTLS, Rate Limiting, Observability)      │   │ │
│  │  └───────────────────────────────────────────────────┘   │ │
│  │                                                          │ │
│  │  ┌───────────────────────────────────────────────────┐   │ │
│  │  │              Monitoring Stack                      │   │ │
│  │  │    Prometheus + Grafana + OpenTelemetry           │   │ │
│  │  └───────────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `API_GATEWAY_PORT` | 8000 | FastAPI HTTP port |
| `GRPC_PORT` | 50051 | gRPC port |
| `SIMONE_MCP_URL` | http://localhost:8234 | Simone-MCP server URL |
| `RATE_LIMIT_RPS` | 50 | Requests per second per IP |
| `MAX_AGENTS` | 10 | Maximum agent replicas |

### Helm Values

```yaml
# values.yaml
api_gateway:
  replicas: 2
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi

agent_workers:
  replicas: 3
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70

simone_mcp:
  enabled: true
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
```

## 📈 Monitoring

### Access Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Open: http://localhost:9090
```

### Access Grafana
```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Default credentials: admin/prom-operator
# Open: http://localhost:3000
```

### Key Metrics

| Metric | Description |
|--------|-------------|
| `code_swarm_agents_active` | Number of active agent workers |
| `code_swarm_tasks_completed_total` | Total tasks completed |
| `code_swarm_task_duration_seconds` | Task completion time |
| `code_swarm_websocket_connections` | Active WebSocket connections |
| `simone_mcp_operations_total` | Simone-MCP AST operations |

## 🔒 Security

- **mTLS** enabled for all inter-pod communication
- **NetworkPolicies** restrict traffic between namespaces
- **Secrets** encrypted at rest (k3s built-in)
- **RBAC** for kubectl access (developer, admin roles)
- **Rate limiting** at API gateway and Istio mesh level

## 📚 Documentation

- [k3s Installation Guide](k3s/INSTALL.md)
- [Helm Chart Reference](helm/code-swarm/README.md)
- [HPA Configuration](templates/hpa.yaml)
- [Istio Setup](istio/README.md)
- [Monitoring Stack](monitoring/README.md)
- [CI/CD Pipeline](.github/workflows/deploy.yml)

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🏆 SOTA Practices Applied

- ✅ **GitOps** - Infrastructure as Code with Helm
- ✅ **Zero-Trust Security** - Istio ambient mode with mTLS
- ✅ **Auto-Scaling** - HPA with custom metrics
- ✅ **Observability** - Prometheus + Grafana + OpenTelemetry
- ✅ **High Availability** - Multi-replica deployments
- ✅ **Cost Optimization** - Free tier infrastructure (OCI A1.Flex)
- ✅ **GitHub Actions** - Automated CI/CD pipeline

---

**Built with ❤️ for the OpenSIN community**