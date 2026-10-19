# AWS Platform Lab

A hands-on platform engineering project built around the
[AWS Containers Retail Sample Application](https://github.com/aws-containers/retail-store-sample-app).

The goal of this project is to design, provision, operate,
observe, secure, and troubleshoot a cloud-native application
platform running on Amazon EKS.

Rather than focusing on application development, this project
focuses on the infrastructure and platform capabilities required
to operate containerized applications in AWS.

The entire environment is designed to be reproducible,
ephemeral, and managed through Infrastructure as Code and GitOps.

---

## 1. Project Goals

The primary objective is to deepen my practical knowledge of
AWS, Terraform, Kubernetes, Helm, ArgoCD, containerization,
and observability.

I want to move beyond deploying infrastructure and applications
toward understanding how cloud-native platforms behave,
how their components interact, and how to troubleshoot them
effectively.

### Core Learning Objectives

**AWS & Infrastructure**
- Design AWS networking and infrastructure.
- Implement IAM roles, policies, and trust relationships.
- Use short-lived credentials and secure authentication.
- Provision infrastructure using reusable Terraform modules.
- Manage remote Terraform state and state locking.
- Integrate EKS workloads with AWS managed services.
- Understand infrastructure dependencies and lifecycle management.

**Kubernetes & Containerization**
- Deploy and manage containerized microservices.
- Understand Kubernetes networking, scheduling, and storage.
- Implement resource management and autoscaling.
- Configure workload identity and access control.
- Troubleshoot common Kubernetes failures.
- Apply container and Kubernetes security best practices.

**Helm & GitOps**
- Develop and customize Helm charts.
- Manage application configuration across environments.
- Bootstrap ArgoCD on a newly provisioned EKS cluster.
- Implement declarative application delivery.
- Detect and reconcile configuration drift.
- Explore progressive delivery and rollback strategies.

**Observability & Reliability**
- Collect application and infrastructure metrics.
- Centralize application logs.
- Implement distributed tracing.
- Build dashboards and configure alerts.
- Define and evaluate SLIs and SLOs.
- Investigate incidents and perform root cause analysis.

**Platform Engineering**
- Automate platform provisioning and destruction.
- Build repeatable deployment workflows.
- Improve developer experience through automation.
- Document architectural decisions and operational procedures.
- Evaluate trade-offs between security, cost, and reliability.

---

## 2. Target Architecture

The platform uses AWS managed services for infrastructure
dependencies and Amazon EKS for running the application workloads.

```text
                       GitHub
                          |
                    GitHub Actions
                          |
                   Build / Test / Scan
                          |
                      Amazon ECR
                          |
                    GitOps Config
                          |
                        ArgoCD
                          |
                          v
                   Amazon EKS
                          |
                 AWS Load Balancer
                          |
                    Retail Store
                          |
       +------------------+------------------+
       |                  |                  |
   Catalog/Orders        Cart             Other APIs
       |                  |                  |
       v                  v                  v
   Amazon RDS        DynamoDB          ElastiCache
       |
       v
   AWS Managed Storage


   Platform Components
   -------------------
   Terraform
   Helm
   ArgoCD
   External Secrets Operator
   EKS Pod Identity
   Prometheus
   Grafana
   Loki
   Tempo
   OpenTelemetry
   Karpenter (Advanced Phase)
```

The exact application-to-database mappings will follow the
selected Retail Store version and its supported configurations.

### Infrastructure Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| Cloud | AWS | Infrastructure platform |
| Networking | Amazon VPC | Network isolation and routing |
| Kubernetes | Amazon EKS | Container orchestration |
| Compute | EC2 Managed Node Groups | Kubernetes worker nodes |
| Identity | AWS IAM / EKS Pod Identity | Authentication and authorization |
| Database | Amazon RDS | Managed relational databases |
| NoSQL | Amazon DynamoDB | Managed NoSQL storage |
| Cache | Amazon ElastiCache | Managed caching |
| Container Registry | Amazon ECR | Container images |
| Secrets | AWS Secrets Manager | Secret storage |
| Infrastructure as Code | Terraform | Infrastructure provisioning |
| Package Management | Helm | Kubernetes application packaging |
| GitOps | ArgoCD | Declarative continuous delivery |
| CI | GitHub Actions | Build, test, and image publishing |
| Metrics | Prometheus | Metrics collection |
| Visualization | Grafana | Dashboards |
| Logging | Loki | Log aggregation |
| Tracing | Tempo | Distributed tracing |
| Telemetry | OpenTelemetry | Telemetry instrumentation and collection |

---

## 3. Architecture Principles

The platform follows several principles.

### Infrastructure as Code

AWS infrastructure is provisioned and managed through Terraform.

Manual changes should be minimized and managed infrastructure
should be reproducible from version-controlled configuration.

### GitOps

Git is the source of truth for Kubernetes application configuration.

ArgoCD continuously reconciles the desired application state
with the actual state running in Kubernetes.

### Separation of Responsibilities

- Terraform manages AWS infrastructure.
- Helm packages Kubernetes applications.
- ArgoCD manages Kubernetes application delivery.
- GitHub Actions builds, tests, and publishes application images.

### Ephemeral Infrastructure

The lab environment is designed to be destroyed and recreated.

Application data is disposable.

The Terraform state S3 bucket remains persistent, while the
lab environment can be removed after each learning session.

### Security by Design

The platform aims to implement:

- Temporary AWS credentials
- Least-privilege IAM policies
- IAM Roles and trust policies
- EKS Pod Identity
- Kubernetes RBAC
- NetworkPolicies
- Container security controls
- Secure secret management

### Observability by Design

Applications and infrastructure should expose sufficient
telemetry to understand their behavior and diagnose failures.

---

## 4. Repository Structure

The planned repository structure is:

```text
retail-platform-lab/
|
├── README.md
├── Makefile
├── .gitignore
|
├── terraform/
│   ├── bootstrap/
│   ├── modules/
│   │   ├── networking/
│   │   ├── eks/
│   │   ├── iam/
│   │   ├── databases/
│   │   └── cache/
│   └── environments/
│       └── lab/
|
├── gitops/
│   ├── bootstrap/
│   ├── applications/
│   ├── platform/
│   └── workloads/
|
├── helm/
│   └── retail-store/
|
├── observability/
│   ├── dashboards/
│   ├── alerts/
│   └── otel/
|
├── scripts/
│   ├── bootstrap.sh
│   ├── destroy.sh
│   └── verify-cleanup.sh
|
├── scenarios/
│   ├── iam/
│   ├── kubernetes/
│   ├── networking/
│   └── terraform/
|
├── docs/
│   ├── architecture/
│   ├── decisions/
│   ├── runbooks/
│   └── incidents/
|
└── .github/
    └── workflows/
```

The structure may evolve as the project progresses.

---

## 5. Prerequisites

The following tools are required:

- AWS account
- AWS CLI v2
- Terraform
- kubectl
- Helm
- Git
- Make
- Docker
- GitHub account

Optional tools:

- k9s
- stern
- jq
- yq
- k6

The project uses:

```text
AWS Region: eu-central-1
Environment: lab
EKS Cluster: retail-platform-lab
AWS CLI Profile: retail-lab
```

These settings can be changed through configuration.

---

## 6. AWS Authentication

Local development uses short-lived AWS credentials.

The preferred authentication method is AWS CLI
browser-based login.

Configure the AWS CLI profile:

```bash
aws login --profile retail-lab
```

Select the AWS Region:

```text
eu-central-1
```

Verify authentication:

```bash
aws sts get-caller-identity --profile retail-lab
```

Export the profile:

```bash
export AWS_PROFILE=retail-lab
export AWS_REGION=eu-central-1
```

Terraform will use the configured AWS credentials.

Static AWS access keys must not be committed to Git.

For GitHub Actions, the platform will use GitHub OIDC
federation with AWS IAM roles.

---

## 7. Terraform State Management

Terraform state is stored remotely in Amazon S3.

The state bucket is persistent and is not destroyed
with the lab infrastructure.

### Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket       = "<state-bucket-name>"
    key          = "lab/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

The S3 bucket uses:

- Bucket versioning
- Server-side encryption
- Block Public Access
- Terraform state locking

The backend bucket must exist before initializing
the main Terraform configuration.

### Bootstrap the Backend

```bash
terraform -chdir=terraform/bootstrap init
terraform -chdir=terraform/bootstrap apply
```

After the bucket has been created, configure the
main Terraform backend using the generated bucket name.

---

## 8. Infrastructure Provisioning

The target workflow uses a Makefile to simplify
repetitive commands.

> The following commands describe the intended interface.
> They become available as the corresponding implementation
> phases are completed.

### Initialize Terraform

```bash
make tf-init
```

### Review Infrastructure Changes

```bash
make tf-plan
```

### Provision AWS Infrastructure

```bash
make aws-up
```

The infrastructure will include:

- VPC
- Public and private subnets
- Security groups
- Amazon EKS
- Managed Node Groups
- IAM roles and policies
- Amazon RDS
- DynamoDB
- ElastiCache
- Amazon ECR
- AWS Secrets Manager integration

Infrastructure changes should always be reviewed
before applying them.

---

## 9. Kubernetes Access

After Terraform provisions the EKS cluster:

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name retail-platform-lab
```

Verify connectivity:

```bash
kubectl get nodes
```

The authenticated IAM identity must have
the required EKS cluster permissions.

---

## 10. GitOps Bootstrap

ArgoCD must be installed before it can manage
other Kubernetes applications.

The initial installation uses Helm.

```text
Terraform Apply
      |
      v
AWS Infrastructure
      |
      v
Amazon EKS
      |
      v
Helm Installs ArgoCD
      |
      v
Root Application
      |
      v
ArgoCD Reconciliation
      |
      +---- Platform Components
      |
      +---- Retail Store
      |
      +---- Observability
```

### Bootstrap ArgoCD

```bash
make bootstrap
```

The bootstrap process will:

1. Configure Kubernetes access.
2. Install ArgoCD using Helm.
3. Wait for ArgoCD to become ready.
4. Register the GitOps root application.
5. Deploy platform controllers.
6. Verify controller readiness.
7. Deploy Retail Store applications.

The root application follows the App of Apps pattern.

Once bootstrapped, Kubernetes application
configuration is managed through Git.

---

## 11. Application Deployment

The platform runs the AWS Containers Retail Sample App.

Application services include:

- UI
- Catalog
- Cart
- Orders
- Checkout

The Retail Store application provides microservices
with different infrastructure dependencies.

The application is used as an existing workload,
allowing development effort to focus on
platform engineering rather than business logic.

### Deployment Strategy

Helm charts define application resources and configuration.

ArgoCD manages the deployment lifecycle.

Application changes are delivered through GitOps.

---

## 12. CI/CD Pipeline

The planned CI/CD pipeline uses GitHub Actions.

```text
Code Change
     |
     v
Pull Request
     |
     v
Lint / Tests
     |
     v
Container Build
     |
     v
Security Scan
     |
     v
Amazon ECR
     |
     v
GitOps Configuration Update
     |
     v
ArgoCD Sync
     |
     v
Amazon EKS
```

GitHub Actions will authenticate to AWS using OIDC.

Long-lived AWS credentials will not be stored
in GitHub Actions secrets.

---

## 13. Observability

The platform will implement three pillars
of observability:

### Metrics

Prometheus collects infrastructure and
application metrics.

Grafana visualizes key performance indicators.

Example metrics:

- CPU and memory utilization
- Pod restarts
- HTTP request rate
- HTTP error rate
- Request latency
- Node utilization

### Logs

Loki centralizes application logs.

Logs help investigate application errors,
crashes, and infrastructure failures.

### Traces

OpenTelemetry collects distributed traces.

Tempo stores traces for investigation.

Distributed tracing helps identify
latency across microservice dependencies.

### Reliability

The platform will also explore:

- Service Level Indicators (SLIs)
- Service Level Objectives (SLOs)
- Alerting
- Error budgets
- Incident investigation

---

## 14. Autoscaling

Autoscaling experiments will include:

- Kubernetes HPA
- Karpenter
- Resource requests and limits
- Node scheduling
- Node consolidation
- Load testing

Load tests will be used to understand
how application and infrastructure scaling interact.

---

## 15. Security

Security is a central part of the project.

Planned areas include:

- AWS IAM policy design
- IAM trust relationships
- EKS access management
- EKS Pod Identity
- Kubernetes RBAC
- Secrets Manager
- External Secrets Operator
- NetworkPolicies
- Container vulnerability scanning
- Kubernetes admission policies

Security controls will be validated through
controlled experiments and troubleshooting scenarios.

---

## 16. Infrastructure Destruction

The environment is intentionally ephemeral.

```bash
make aws-down
```

The destruction workflow will:

1. Remove GitOps-managed applications.
2. Delete Kubernetes resources that provision AWS infrastructure.
3. Wait for load balancers and storage resources to be removed.
4. Run Terraform destroy.
5. Verify that the lab resources have been deleted.

The Terraform state bucket remains available.

Application data is not preserved.

The goal is to make the environment
fully reproducible from source configuration.

Some AWS resources may require additional cleanup
or dependency handling before destruction completes.

---

## 17. Learning Roadmap

### Phase 1 — AWS Foundation

- [ ] Configure AWS CLI authentication
- [ ] Create Terraform state S3 bucket
- [ ] Configure remote state and locking
- [ ] Implement Terraform networking modules
- [ ] Configure IAM roles and policies
- [ ] Provision Amazon EKS
- [ ] Configure EKS access
- [ ] Provision application data services
- [ ] Validate infrastructure destruction

### Phase 2 — Kubernetes & GitOps

- [ ] Bootstrap ArgoCD
- [ ] Implement App of Apps
- [ ] Configure AWS Load Balancer Controller
- [ ] Configure EKS Pod Identity
- [ ] Deploy Retail Store using Helm
- [ ] Configure External Secrets Operator
- [ ] Validate GitOps reconciliation
- [ ] Implement application configuration management

### Phase 3 — CI/CD

- [ ] Configure GitHub Actions OIDC
- [ ] Create Amazon ECR repositories
- [ ] Build and test container images
- [ ] Implement vulnerability scanning
- [ ] Automate image publishing
- [ ] Implement GitOps image updates
- [ ] Validate deployment and rollback workflows

### Phase 4 — Observability

- [ ] Deploy Prometheus
- [ ] Deploy Grafana
- [ ] Configure application metrics
- [ ] Deploy Loki
- [ ] Deploy Tempo
- [ ] Configure OpenTelemetry Collector
- [ ] Create dashboards
- [ ] Define alerts and SLOs

### Phase 5 — Advanced Platform Engineering

- [ ] Implement HPA
- [ ] Deploy Karpenter
- [ ] Perform load testing
- [ ] Implement progressive delivery
- [ ] Configure Kubernetes security policies
- [ ] Simulate node failures
- [ ] Investigate networking failures
- [ ] Perform IAM troubleshooting
- [ ] Test disaster recovery
- [ ] Document incidents and lessons learned

---

## 18. Troubleshooting Scenarios

The project includes controlled failure scenarios.

| Scenario | Learning Objective |
|----------|-------------------|
| Pod Pending | Scheduling and resource management |
| ImagePullBackOff | Registry access and networking |
| CrashLoopBackOff | Application lifecycle debugging |
| OOMKilled | Memory management |
| AccessDenied | AWS IAM and workload identity |
| Database timeout | Networking and service dependencies |
| ArgoCD OutOfSync | GitOps reconciliation |
| High API latency | Observability and tracing |
| Node failure | Availability and recovery |
| Terraform drift | Infrastructure state management |

Each scenario should include:

- Problem description
- Expected behavior
- Investigation steps
- Root cause
- Resolution
- Preventive improvements

---

## 19. Cost Management

This project uses AWS managed services that
may incur charges while the environment is running.

Cost optimization is part of the learning process.

Principles:

- Destroy unused lab infrastructure.
- Use cost-effective instance types.
- Avoid unnecessary high-availability configurations.
- Monitor AWS spending.
- Configure AWS Budgets.
- Verify resource cleanup after each session.
- Review Terraform plans before provisioning.

AWS Budgets provides notifications but does not
automatically shut down all AWS resources.

---

## 20. Success Criteria

The project will be considered successful when I can:

1. Provision the platform using Terraform.
2. Configure secure AWS authentication and authorization.
3. Deploy Retail Store to Amazon EKS.
4. Manage applications through Helm and ArgoCD.
5. Implement a secure CI/CD pipeline.
6. Collect and analyze logs, metrics, and traces.
7. Diagnose Kubernetes and AWS failures.
8. Test application and infrastructure autoscaling.
9. Destroy and recreate the environment reliably.
10. Explain the architectural decisions and operational trade-offs.

---

## 21. References

- [AWS Containers Retail Sample App](https://github.com/aws-containers/retail-store-sample-app)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/iam/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

---

## Disclaimer

This project is an independent educational platform engineering lab.

It uses the AWS Containers Retail Sample Application as a
demonstration workload.

The environment is designed for experimentation and learning,
not for processing real customer data or production transactions.