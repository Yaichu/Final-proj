# Final Project

This is OpsSchool's course final project.
It's purpose is to create a highly available, automated infrastructure on AWS Cloud, and bring an application to life while integrating a variety of tools.
The architecture is fully cloud based - a VPC with two availability zones and two subnets on each one (private and public). The communication between the subnets and with the world goes through NAT and internet gateways, and load balancers.

### Requirements

- AWS account
- Git cli
- Terraform 0.12+
- Ansible 2.9+
- Python 3.6+
- Docker 19.03+
- Docker-Compose


### More details
**Terraform** builds the following:

- S3 bucket that saves the state of terraform (.tfstate file)
- VPC infrastructure (including subnets, NAT gateway, internet gateway, LBs)
- *EC2 Instances* including:
  - Jenkins (master & slaves)
  - ELK stack
  - Prometheus
  - Grafana
  - Consul servers' cluster
  - Most of the instances have Prometheus' exporters and consul agents installed
- EKS cluster

**Ansible** installs:

- Docker
- Prometheus' node exporters

**Docker Compose** deploys:

- Prometheus
- MySql DB

### Application Deployment

- Run `terraform init`  
  `terraform plan -out "project.tfplan"`  
  `terraform apply "project.tfplan"`
  
- Install the following in **Kubernetes**:
    - kubectl
    - iam-authentication
    - aws-cli
    
  Run:
    ```
    aws eks update-kubeconfig –name <cluster name>
    kubectl create -f pods1.yml
    kubectl get svc -o wide
    kubectl get pod -o wide
    kubectl get nodes
    ```
- Access Jenkins UI (port 8080) and:
  - install the plugin *Kubernetes Continuous Deploy Plugin* and copy the content of the config file to the credentials window
  - create a SCM pipeline job that commits the following:
    - choose the github repository with the application - https://github.com/Yaichu/project-application
    - run the build job
  
### Monitoring and Logging
  
- Prometheus UI: port 9090
- Grafana UI: port 3000
- Kibana UI: port 5601
