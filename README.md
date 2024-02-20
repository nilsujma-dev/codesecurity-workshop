# Project Documentation

## High-Level Summary

The project establishes an automated pipeline to build, scan for security vulnerabilities, and deploy an Nginx web server containerized in Docker. The application serves static HTML content and is designed to run within a Kubernetes cluster managed by the Azure Kubernetes Service (AKS). The Docker image is built from a `Dockerfile` that configures Nginx and copies over the necessary HTML files. The pipeline orchestrates the process with security scans at each stage, ensuring that the image is safe to deploy. Finally, the pipeline handles the deployment, creating a Kubernetes `Deployment` to manage the Nginx pod(s) and a `Service` to expose it to the internet through a LoadBalancer.

## Detailed Documentation

### Project Overview

This project provisions an Nginx web server using Docker and Kubernetes. The web server is configured to serve static HTML content. GitLab CI/CD is utilized for continuous integration and deployment, which includes building the Docker image, pushing it to registries, scanning for vulnerabilities, and deploying to the Azure Kubernetes Service (AKS).

The `Dockerfile` used for building the Nginx Docker image performs the following steps:

- Uses the latest official Nginx image as the base.
- Removes the default Nginx configuration file.
- Copies a custom configuration file and HTML files into the image.
- Exposes port 80 for web traffic.
- Sets the command to start Nginx.

The Kubernetes deployment (`Deployment`) is designed to maintain a single replica of the Nginx server running. The deployment specifies which Docker image to use through the `$IMAGE_TAG` variable that is dynamically replaced by the CI/CD pipeline. Additionally, a Kubernetes service (`Service`) is created to expose Nginx to the internet via a LoadBalancer that listens on port 80.

### CI/CD Pipeline Stages

1. **Security Gates**: Automated security checks are performed using Spectral to ensure the source code meets the security standards.

2. **Build**: The Docker image for the Nginx web server is built using the provided `Dockerfile`.

3. **ShiftLeft Scan**: After the build stage, the Docker image is scanned for vulnerabilities using the ShiftLeft tool to prevent deployment of images with known security issues.

4. **Azure Push**: The scanned image is then pushed to an Azure Container Registry (ACR), tagged with the appropriate details for identification.

5. **ACR ShiftLeft Scan**: The image in ACR is scanned once again for vulnerabilities, ensuring that the version in the registry is secure before deployment.

6. **Deploy**: The `deploy_to_aks` job applies the Kubernetes deployment and service configurations to the AKS cluster, resulting in the Nginx server running on a dynamically provisioned LoadBalancer that routes traffic to it.

### Pipeline Execution

- Only commits to the `main` branch trigger the pipeline.
- Environment variables are required for image tagging, registry authentication, and Kubernetes cluster access.
- Kubernetes configuration files need the `imagePullSecrets` section if private registries are used.

### Reproducing the Pipeline

To utilize this pipeline:

1. Place the `.gitlab-ci.yml`, `Dockerfile`, `nginx.conf`, `index.html`, `access.html`, `deployment.yaml`, and `service.yaml` in the root of the GitLab repository.
2. Set the required CI/CD variables in your GitLab project.
3. Ensure that the runner used has Docker available.
4. Establish Docker registry and Azure Container Registry access.
5. Configure an Azure Kubernetes Service (AKS) with access credentials and assure that your GitLab runner has permissions to interact with AKS.
6. Once a push to the `main` branch occurs, monitor the pipeline execution in GitLab CI/CD dashboard to ensure each stage completes successfully.

### Additional Considerations

- The Docker image is built and pushed to multiple registries for redundancy and to facilitate diverse deployment strategies.
- ShiftLeft scans occur after the build stage and again after pushing to Azure, securing the delivery pipeline at every touchpoint.
- Kubernetes deployment files are templated to accept image tags specified by environmental variables, maintaining consistency and ensuring deployments utilize the correct image.
- This detailed documentation can serve as a basis for setting up similar pipelines and is meant to guide technical and non-technical team members alike.