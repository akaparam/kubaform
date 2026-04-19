# Pricing Estimates

This document compares the cost of running a Kubernetes lab with KubaForm vs. AWS EKS, demonstrating why EKS can be significantly more expensive.

## KubaForm Configuration

**Region**: `ap-south-1` (Asia Pacific - Mumbai)  
**Availability Zones**: 2 (ap-south-1a, ap-south-1b)  
**Node Distribution**: Evenly distributed across AZs

### Infrastructure Overview

```
- Master Nodes:  2 x t3a.small (10GB gp2 EBS each)
- NGINX Proxy:   1 x t3a.micro (5GB gp2 EBS)
- Worker Nodes:  4 x t3a.medium (10GB gp2 EBS each)
- Total Nodes:   7 EC2 instances
```

### Networking Components

- 1 VPC with 2 public and 2 private subnets (1 pair per AZ)
- 1 Internet Gateway
- 1 NAT Gateway for egress
- 2 Elastic IPs (NAT + NGINX)
- Security Groups (inbound/outbound rules)

---

## Monthly Cost Breakdown

### EC2 On-Demand Instances (730 hours/month)

| Component | Instance Type | Count | Hourly Rate | Monthly Cost |
|-----------|---------------|-------|------------|--------------|
| Master Nodes | t3a.small | 2 | $0.0188 | $27.44 |
| NGINX Proxy | t3a.micro | 1 | $0.0080 | $5.84 |
| Worker Nodes | t3a.medium | 4 | $0.0300 | $87.60 |
| | | | **Subtotal** | **$120.88** |

### EBS Storage (general purpose, gp2)

| Component | Size | Count | Hourly Rate | Monthly Cost |
|-----------|------|-------|------------|--------------|
| Master Volumes | 10GB | 2 | $0.0011 | $1.60 |
| NGINX Volume | 5GB | 1 | $0.0006 | $0.44 |
| Worker Volumes | 10GB | 4 | $0.0011 | $3.20 |
| | | | **Subtotal** | **$5.24** |

### Data Transfer

| Service | Details | Estimated Monthly Cost |
|---------|---------|------------------------|
| NAT Gateway | ~1GB/day egress | $45.00 |
| Data Transfer Out | To internet/other AZs | $15.00 |
| | | **Subtotal** | **$60.00** |

### Networking

| Component | Type | Monthly Cost |
|-----------|------|--------------|
| Elastic IPs | 2 EIPs (NAT + NGINX) | $7.30 |
| VPC, Subnets, IGW, Route Tables | Basic VPC | Free |
| Security Groups | Basic firewall | Free |
| | | **Subtotal** | **$7.30** |

### **Total KubaForm Monthly Cost: ~$194-207** (including $7.30 for 2 EIPs)

---

## EKS Equivalent Configuration Pricing

For a **similar 6-node Kubernetes cluster** (excluding master nodes managed by EKS):

### EKS Control Plane

| Service | Details | Monthly Cost |
|---------|---------|--------------|
| EKS Cluster | Managed control plane | $73.00 |
| | (Fixed cost per cluster, ap-south-1) | |

### EC2 On-Demand Instances (same as KubaForm)

| Component | Instance Type | Count | Monthly Cost |
|-----------|---------------|-------|--------------|
| Worker Nodes | t3a.medium | 6 | $131.40 |
| | | | **Subtotal** | **$131.40** |

### EBS Storage (same as KubaForm)

- Worker Volumes: 6 x 10GB gp2 = **$4.80**

### Data Transfer

- Similar to KubaForm: **~$60.00**

### **Total EKS Monthly Cost: ~$269-280**

---

## Cost Comparison Summary

| Service | KubaForm | EKS | Difference | % Savings |
|---------|----------|-----|-----------|-----------|
| **Monthly Cost** | **~$200** | **~$275** | **$75** | **~27% cheaper** |
| **Annual Cost** | **~$2,400** | **~$3,300** | **$900** | **~27% cheaper** |

### Key Cost Differences

1. **EKS Control Plane Fee**: $73/month
   - With KubaForm, you manage the masters yourself (cost included in EC2 instance pricing)

2. **Node Count Flexibility**: 
   - KubaForm: You pay for exactly what you use (2 masters + 4 workers = 6 compute nodes)
   - EKS: You still pay for worker count, plus the fixed control plane fee

3. **Multi-AZ Deployment**:
   - KubaForm makes it easy to distribute nodes across AZs with Terraform
   - EKS charges the same but adds the control plane overhead

---

# AWS Pricing Calculator Links

## Generated Links

1. Kubaform Setup : https://calculator.aws/#/estimate?id=973776895bca01e29021e80ab805c36ae7ecdd06

2. EKS Setup : https://calculator.aws/#/estimate?id=3dce8f6863daf4ef41cb7ac7316f95a2a25f3f48

> Moreover, you can checkout the PDF version of the pricing estimates here: [Kubaform PDF](./assets/kubaform-pricing-estimate.pdf) and [EKS PDF](./assets/eks-pricing-estimate.pdf)

### Considerations

- Both are using On-Demand instances, and can be moved to Reserved instances to help save costs even further.
- NAT Gateways aren't considered for this setup as based on cluster and control plane interactions on different workloads, it will significantly vary for EKS and Kubaform. Thus, to keep the fight fair I have removed the costs for NAT Gateways. But even then for a single hosted zone NAT would be cheaper overall ;)

## Build your OWN estimates

### KubaForm Setup (7 nodes, ap-south-1)

Generate your own calculation:
1. Go to [AWS Pricing Calculator](https://calculator.aws/)
2. Add the following resources:
   - **EC2**: 2x t3a.small, 1x t3a.micro, 4x t3a.medium (on-demand, Linux)
   - **EBS**: 2x 10GB gp2, 1x 5GB gp2, 4x 10GB gp2 volumes
   - **Data Transfer**: Estimate 500GB/month internet egress
3. Region: **Asia Pacific (Mumbai) - ap-south-1**

### EKS Equivalent Setup

1. Go to [AWS Pricing Calculator](https://calculator.aws/)
2. Add the following resources:
   - **EKS**: Managed Kubernetes cluster (1 cluster)
   - **EC2**: 4x t3a.medium worker nodes (on-demand, Linux)
   - **EBS**: 4x 10GB gp2 volumes
   - **Data Transfer**: Same as KubaForm
3. Region: **Asia Pacific (Mumbai) - ap-south-1**

---

## Why Multi-AZ with Terraform?

With KubaForm, deploying across multiple availability zones is as simple as configuring a variable. This provides:

- **High Availability**: If one AZ goes down, your cluster continues running
- **Cost Efficiency**: No extra charge for AZ distribution (just NAT gateway data transfer)
- **Easy Scaling**: Add more worker nodes to different AZs without re-architecture
- **Terraform IaC**: Version control and reproducibility for your infrastructure

Example of distributing workers across AZs in Terraform:

```hcl
# Simply specify worker count and AZs - Terraform handles the rest
worker_config = {
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  instance_count     = 4
  instance_type      = "t3a.medium"
}
```

This automatically:
- Creates 2 workers in each AZ
- Sets up subnets and route tables
- Configures security groups for inter-AZ communication
- Provisions NAT gateways for HA