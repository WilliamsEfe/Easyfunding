# EasyFundRaising Task

This project demonstrates deploying a Docker-containerized application that displays the current date and time on a webpage, using `Kubernetes` for orchestration, `Terraform` for AWS infrastructure provisioning, and optionally `ArgoCD` for deployment automation. Aimed at showcasing skills in containerization, IaC, and CI/CD processes, it aligns with DevOps best practices. 

The setup includes `Docker` for containerization, `Helm` for Kubernetes deployments, and `AWS` services (`EKS`, `RDS`, `S3`) for infrastructure. A concise guide on project structure, setup, and deployment instructions is provided in following:

## Project Structure

The project is organized into several directories, each serving a specific role in the deployment and management of the application and its infrastructure. Here's an overview of the directory structure and the purpose of key files within them:

- **`App/`**: Contains the source code of the sample application.
  - `Dockerfile`: Defines the Docker image for the application.
  - `app.py`: The Python script for the web application displaying the current date and time.
  - `requirements.txt`: Lists the Python dependencies for the application.

- **`helm-charts/`**: Contains Helm charts for deploying applications.
  - **`argocd/`**: Helm chart for ArgoCD, including applications and values configurations.
    - `applications/`: YAML files defining ArgoCD applications.
    - `Chart.yaml`, `Chart.lock`, `values.yaml`: Define the ArgoCD Helm chart and its dependencies.
  - **`aws-alb-controller/`**: Holds configuration files for the AWS Load Balancer Controller.
    - `aws-load-balancer-controller-service-account.yaml`: Kubernetes service account for the AWS Load Balancer Controller.
    - `iam_policy.json`: IAM policy for the service account.
    - `load-balancer-role-trust-policy.json`: Trust policy for the role assumed by the Load Balancer Controller.
  - **`my-sample-app/`**: Helm chart for deploying the sample application.
    - `Chart.yaml`, `values.yaml`: Define the Helm chart for the sample app.
    - `templates/`: Contains Kubernetes templates for deployment, service, ingress, etc.

- **`terraform/`**: Terraform configuration for provisioning AWS resources.
  - `main.tf`: Main Terraform configuration file.
  - **`modules/`**: Modular Terraform configurations for specific resources.
    - **`ec2/`**: Terraform module for EC2 instances.
    - **`rds/`**: Terraform module for RDS instances.
  - `outputs.tf`: Defines outputs from Terraform.
  - `variables.tf`, `terraform.tfvars`: Define and assign Terraform variables.
  - **`scripts/`**: Scripts for post-provisioning tasks, such as database user management.

## Prerequisites

Before starting the setup and deployment of the project, ensure you have the following tools installed and configured on your system.

- **Docker**: Essential for building and running the containerized application.
  - [Download Docker](https://www.docker.com/products/docker-desktop)

- **AWS CLI**: Needed to interact with AWS for creating and managing cloud resources.
  - [Installing or updating the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

- **Terraform**: Used for provisioning the AWS infrastructure as code.
  - [Download Terraform](https://www.terraform.io/downloads.html)

- **Helm**: Manages Kubernetes applications through Helm Charts.
  - [Installing Helm](https://helm.sh/docs/intro/install/)

- **AWS EKS**: The Kubernetes environment for this project is hosted on AWS Elastic Kubernetes Service (EKS), providing a managed Kubernetes service.
  - To interact with your AWS EKS cluster, you'll need `eksctl` and `kubectl`:
    - **eksctl**: A simple CLI tool for creating clusters on AWS EKS - [Installing eksctl](https://eksctl.io/introduction/#installation)
    - **kubectl**: For deploying applications, managing cluster resources, and viewing logs.
      - [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/)

- **ArgoCD**: A GitOps continuous delivery tool for Kubernetes, recommended for automated deployment.
  - [Getting Started with Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/)

Ensure all these tools are installed and correctly configured before proceeding. Additionally, familiarize yourself with AWS EKS if you're not already, as it's central to deploying and managing the Kubernetes aspects of this project.

## Setup and Deployment Instructions

### Local Development

The project includes a simple Flask application that displays the current date and time. Below is a breakdown of the key components for local development:

Flask App (app.py): Implements a web server displaying the current date and time.
Requirements (requirements.txt): Lists all Python dependencies.
Dockerfile: Prepares the Docker environment for the Flask app, using Python 3.8-alpine as a base image.

#### Building and Running Docker Image Locally

Build the Docker image:

```
    docker build -t williamsmishael/datetime-app:1.0 .
```

Run the container locally (optional, to test):

```
    docker run -p 5000:5000 williamsmishael/datetime-app:1.0
```

Verify the application by accessing `http://localhost:5000` in a web browser.

#### Docker Hub Push

Login to Docker Hub:

Tag and push the Docker image to Docker Hub:

```
    docker push williamsmishael/datetime-app:1.0
```

Note: Ensure Docker is configured to use the user account with `sudo usermod -aG docker $USER` and `newgrp docker` commands for permission management.

### AWS Configuration and Setup

This section outlines the steps for setting up AWS services, including AWS CLI, AWS EKS, and S3 bucket for Helm chart storage, along with configuring the AWS Load Balancer Controller in the EKS cluster.

#### AWS CLI Setup and Access Credentials

1. **Install the AWS CLI**: Follow the [official documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) to install the AWS CLI on your system.

2. **Configure Access Credentials**:
   - Run `aws configure` to set up your AWS access key ID, secret access key, region, and output format.

#### Creating an S3 Bucket for Helm Chart Storage

1. **Create an S3 Bucket**:
Use the AWS Management Console or AWS CLI to create an S3 bucket. Ensure the bucket is private and enable versioning for added safety. 

2. **Initialize the Helm S3 Plugin**:
Configure the S3 Bucket as a Helm Repository: Use the Helm S3 plugin to turn your bucket into a Helm repository. This involves initializing the bucket with the Helm S3 plugin and pushing your charts to the repository.

```
    helm plugin install https://github.com/hypnoglow/helm-s3.git
```

```
    helm s3 init s3://easyfunding-helm-charts-repo
```

3. **Package Your Helm Chart**:
```
    helm package . --version 1.0.0 --app-version 1.0.0
```

4. **Push the Helm Chart to S3**:
```
    helm s3 push my-sample-app-1.0.0.tgz s3://easyfunding-helm-charts-repo
```

5. **Add Your S3 Helm Repo**:
```
    helm repo add easyfunding-helm-repo s3://easyfunding-helm-charts-repo/
```


#### AWS EKS Cluster Setup

The AWS EKS cluster setup involves creating IAM roles with pre-existing policies for the cluster and node group for operational security and functionality. Here are the policies associated with the cluster and node group:

- **Cluster**: AmazonEKSClusterPolicy
- **Node Group**:
- AmazonEC2ContainerRegistryReadOnly
- AmazonEKS_CNI_Policy
- AmazonEKSWorkerNodePolicy

These policies are essential for the cluster's interaction with AWS services and the management of resources within the EKS environment.

Follow the [EKS cluster setup guide](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) in the AWS documentation for detailed instructions.

#### AWS Load Balancer Controller Setup

To install the AWS Load Balancer Controller in your EKS cluster, follow these steps:

1. **Create an IAM OIDC identity provider for the cluster** using the AWS Management Console or AWS CLI.

2. **Create an IAM policy called `AWSLoadBalancerControllerIAMPolicy`** using the JSON provided in `aws-alb-controller/iam_policy.json`.

3. **Create a Kubernetes service account** named `aws-load-balancer-controller` in the `kube-system` namespace, attaching the IAM role with the policy created in the previous step. Use the `aws-load-balancer-controller-service-account.yaml` for this purpose, which includes the necessary annotations for the IAM role ARN.

4. **Deploy the AWS Load Balancer Controller** to your cluster by applying the Helm chart available in the `helm-charts/aws-alb-controller` directory. Ensure you update the `values.yaml` with the specifics of your deployment, such as the cluster name and region.

For a detailed guide and commands, refer to the [official AWS documentation on setting up the AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

### Terraform Setup

This section covers the steps to utilize Terraform for provisioning the required AWS infrastructure, including EC2 instances for secure access and RDS instances for database management. The project's Terraform code is structured for modularity and reusability, facilitating infrastructure as code practices.

#### Terraform Structure

The Terraform setup is organized into the following structure within the `terraform` directory:

- **`EC2KeyPair.pem`**: The private key file for SSH access to EC2 instances.
- **`main.tf`**: The primary configuration file that defines the provider and includes the modules for EC2 and RDS resources.
- **`modules/`**: Contains modular configurations for specific resources:
  - **`ec2/`**: Module for provisioning EC2 instances and associated security groups.
  - **`rds/`**: Module for provisioning RDS instances, with support for multiple environments (development and staging).
- **`outputs.tf`**: Defines outputs from Terraform that can be useful for further configurations or information retrieval.
- **`scripts/`**: Includes scripts for post-provisioning tasks, such as setting up database users.
- **`terraform.tfstate`** and **`terraform.tfstate.backup`**: Terraform state files.
- **`terraform.tfvars`**: Variables file to define values for the Terraform configurations.
- **`variables.tf`**: Declares variables used across the Terraform configurations.

#### Initialization and Application

To deploy the AWS infrastructure using Terraform, follow these steps:

1. **Navigate to the Terraform Directory**:
   Change to the directory where your Terraform configuration files are located.

```
    cd terraform
```

2. **Initialize Terraform**:
Run the `terraform init` command to initialize a working directory containing Terraform configuration files.

```
    terraform init
```

3. **Review the Terraform Plan**:
Execute `terraform plan` to review the actions Terraform will perform based on your configuration files.

```
    terraform plan
```

4. **Apply the Terraform Configuration**:
Apply the Terraform configuration to provision the AWS resources as defined in your Terraform files.

```
    terraform apply
```

Confirm the action when prompted to start the provisioning process.

5. **Accessing Outputs**:
After successful application, Terraform outputs defined in `outputs.tf` can be viewed with:

```
    terraform output
```

#### Post-Provisioning

Utilize the `setup-db-users.sh` script located in the `scripts/` directory to set up database users on the provisioned RDS instance. This script is automatically invoked by Terraform's `null_resource` provisioner but can be run manually for additional configurations or troubleshooting.

#### Cleanup

To destroy the AWS resources provisioned by Terraform, ensuring no ongoing charges, use:

```
    terraform destroy
```

Confirm the action when prompted to remove the resources.

This Terraform setup provides a foundation for robust AWS infrastructure management, facilitating secure access and scalable database solutions for the application deployed on AWS EKS.


### Helm Chart Deployment

This section provides the steps to deploy the sample Flask application on AWS EKS using Helm charts. The deployment leverages a custom Helm chart for the application, ensuring scalable and manageable Kubernetes resources.

#### Deploying the Sample Application with Helm

1. **Navigate to the Helm Charts Directory**:

```
    cd helm-charts/my-sample-app
```

2. **Update Helm Repositories** (if using external dependencies):

```
    helm repo update
```

3. **Install the Helm Chart**:
Deploy your application to the EKS cluster by running:

```
    helm install my-sample-app . --values values.yaml
```

Ensure you are connected to your EKS cluster's context with `kubectl` before executing the Helm command.

#### Verification

After deployment, verify the application is running:

1. **Check the Helm Release**:

```
    helm list
```

2. **Access the Application**:
Use the Load Balancer URL provided by the ingress resource. Find the URL by describing the ingress:

```
    kubectl get ingress
```

### ArgoCD

ArgoCD automates the continuous deployment of applications to Kubernetes. The following guide covers setting up ArgoCD in your EKS cluster and deploying applications through it.

#### Setting Up ArgoCD

1. **Install ArgoCD** on your EKS cluster:

```
    kubectl create namespace argocd
```

```
    kubectl apply -n argocd -f helm-charts/argocd
```

2. **Access the ArgoCD UI**:
Expose the ArgoCD server service:

```
kubectl port-forward svc/easyfunding-argocd-server -n argocd 8080:80
```

Then, access the UI through `http://localhost:8080`.

### Deploying Applications with ArgoCD

1. **Register Your Application** with ArgoCD:
Apply the `my-sample-app.yaml` configuration within the `argocd/applications` directory:

```
kubectl apply -f helm-charts/argocd/applications/my-sample-app.yaml
```

2. **Sync the Application** in ArgoCD:
Either use the ArgoCD UI to manually sync the application or enable automatic sync in the application definition.

#### Monitoring Deployment

ArgoCD provides a visual interface to monitor the deployment status, resources, and any discrepancies between the desired and current state.

#### Cleanup

To remove the application and ArgoCD components:

1. **Delete the Application**:
```
helm uninstall my-sample-app
```

And remove it from ArgoCD if necessary.

2. **Uninstall ArgoCD**:
```
kubectl delete -f helm-charts/argocd
```

By following these steps, you will have deployed your sample application to EKS using Helm and set up ArgoCD for deployment automation, aligning with best practices for Kubernetes application deployment and management.

## Usage

After deploying the sample Flask application to AWS EKS using Helm, the application is accessible through the Load Balancer URL created by the ingress resource. This section provides instructions on how to find and access your deployed application.

### Finding the Load Balancer URL

The AWS Load Balancer created by the ingress controller exposes your application to the internet. To find the Load Balancer URL:

1. **List the Ingress Resources**:
   Run the following command to get details about the ingress resources, including the URL of the Load Balancer.

```   
    kubectl get ingress
```

This command will output several pieces of information, including the NAME, CLASS, HOSTS, ADDRESS, and more.

2. **Identify the Load Balancer URL**:
Under the ADDRESS column, you will find the URL of the Load Balancer. This URL is what you'll use to access your deployed Flask application.

### Accessing the Application

With the Load Balancer URL:

1. **Open a Web Browser**: Launch your preferred web browser.

2. **Enter the Load Balancer URL**: Paste the URL into the browser's address bar and press Enter. If the deployment was successful and the Load Balancer is correctly configured, you should see the Flask application's output – the current date and time displayed on the webpage.

### Troubleshooting

- If you're unable to access the application, ensure that the ingress resource is correctly configured and that the Load Balancer is in an active state within the AWS Management Console.
- Check the security groups associated with your Load Balancer to ensure they allow incoming traffic on the correct port (typically 80 for HTTP).

By following these steps, you can access your sample Flask application deployed on AWS EKS, demonstrating the application's successful deployment and the effectiveness of your Kubernetes and AWS configurations.

## Git Branching and Merging Strategy

For this project, I've adopted a Git workflow that enhances collaboration, feature development, and release management. The strategy is designed to accommodate multiple developers working on different features simultaneously, while maintaining code quality and ease of integration.

### Main Branches

- **`main`**: The primary branch where the code reflects the production-ready state.
- **`develop`**: The development branch serves as an integration branch for features. All feature branches merge back into `develop`.

### Supporting Branches

- **Feature branches (`feature/`)**: For every new feature, a branch is created from `develop`. Naming follows the `feature/feature-name` convention. Once the feature is complete, it's merged back into `develop`.
- **Hotfix branches (`hotfix/`)**: Critical fixes that need to be applied directly to production are made in `hotfix/` branches off `main`. After merging into `main`, changes are also merged back into `develop`.
- **Release branches (`release/`)**: When `develop` has reached a stable point and is ready for release, a `release/` branch is created to prepare for a new production release. Any bug fixes during this phase are made in the release branch. The release branch is merged into `main` and back into `develop` upon release completion.

### Strategy Benefits

- **Parallel Development**: Enables simultaneous development of features without interference.
- **Quality Control**: Integrating code review and automated testing as part of the merging process enhances code quality.
- **Release Management**: Separation of development and release processes allows for clear stages and rollback points.

## Highlights of Advanced Kubernetes Features Implemented

To ensure the pod is production-ready, the following advanced Kubernetes features have been implemented:

- **Liveness and Readiness Probes**: Ensures that the Kubernetes scheduler knows when the application is ready to serve traffic (`readinessProbe`) and when it needs to be restarted (`livenessProbe`).

- **Resource Limits and Requests**: Defines the minimum (`requests`) and maximum (`limits`) computational resources the container can use. This is crucial for ensuring the application doesn't consume more resources than allocated, preventing it from affecting other applications running on the same cluster.

- **Security Contexts**: Configures permissions and access control settings for the pod to enhance security. For example, `runAsNonRoot: true` ensures that the container does not run as the root user.

- **Horizontal Pod Autoscaler (HPA)**: Automatically scales the number of pod replicas based on CPU usage or other selected metrics. Although marked as optional (`autoscaling.enabled: false`), it's ready to be enabled as needed.

These features collectively contribute to a robust, secure, and scalable deployment, aligning with best practices for Kubernetes applications in production environments.

## Tips and Troubleshooting

Deploying applications to Kubernetes and managing infrastructure with Terraform can sometimes lead to unexpected issues. Here are some tips and troubleshooting steps to help resolve common problems you might encounter.

### General Tips

- **Documentation Is Your Friend**: Always refer to the official documentation of the tools and services you're using (Kubernetes, AWS, Terraform, Helm, ArgoCD) for the most accurate and up-to-date information.
- **Consistent Environment**: Ensure your development, staging, and production environments are as similar as possible to avoid the "it works on my machine" problem.
- **Version Control**: Keep your tooling versions (kubectl, helm, terraform, aws-cli) in sync across your team to prevent compatibility issues.

### Troubleshooting Steps

#### Kubernetes/Helm Deployment Issues

- **Pods Not Starting**: Check pod status with `kubectl get pods`. If pods are in `ErrImagePull` or `ImagePullBackOff`, ensure your Docker image is correctly tagged and accessible. Use `kubectl describe pod <pod_name>` for more details.
- **Service Unreachable**: If your service is not accessible, verify the service and ingress configurations. Use `kubectl get svc` and `kubectl get ingress` to inspect these resources. Check the Load Balancer security groups and rules in AWS to ensure they allow traffic to the cluster nodes.
- **Application Errors**: View application logs with `kubectl logs <pod_name>`. This can provide insights into runtime errors or misconfigurations.

#### Terraform Issues

- **Failed Provisioning**: Ensure your AWS credentials are correctly configured. Run `aws configure` to set up the AWS CLI and verify with `aws sts get-caller-identity`. Review Terraform's execution plan (`terraform plan`) carefully before applying changes.
- **State Locking**: If Terraform reports a state lock, ensure no other processes are currently running Terraform changes. If the lock persists incorrectly, use `terraform force-unlock <lock_id>` to remove it.
- **Resource Deletion Errors**: Some resources might fail to delete due to dependencies. Manually remove the dependencies from the AWS Console or update your Terraform configuration to handle these dependencies explicitly.

#### ArgoCD Issues

- **Sync Failures**: Ensure the repository URL and branch specified in your ArgoCD Application resource are correct. Use the ArgoCD UI or CLI (`argocd app sync <app_name>`) to attempt a manual sync and watch for errors.
- **Access Issues**: If you can't access the ArgoCD UI, verify the ingress configuration and that the ArgoCD server service is correctly exposed. Check the Kubernetes service (`kubectl get svc -n argocd`) and ingress resource for the correct configuration.

### Additional Resources

- Kubernetes Documentation: https://kubernetes.io/docs/
- AWS Documentation: https://docs.aws.amazon.com/
- Terraform Documentation: https://www.terraform.io/docs/
- Helm Documentation: https://helm.sh/docs/
- ArgoCD Documentation: https://argo-cd.readthedocs.io/

By following these tips and utilizing the troubleshooting steps provided, you can resolve common issues that may arise during the deployment and management of your application and its infrastructure.
