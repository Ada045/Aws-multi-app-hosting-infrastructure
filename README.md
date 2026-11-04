# Cost-Efficient Multi-Application Hosting Infrastructure on AWS

## Project Overview

This project demonstrates the design and deployment of a cost-efficient, multi-application hosting infrastructure on AWS using Terraform, Docker, Docker Compose and Nginx.

The primary objective was to solve a common infrastructure challenge: **how to host and manage multiple independent applications without provisioning a separate cloud server for each application.**

For applications primarily used for demonstrations, development, testing and other low-traffic purposes, deploying each application on a dedicated EC2 instance can result in unnecessary infrastructure costs and underutilised computing resources.

To address this, I designed a shared hosting environment where multiple applications run on a single EC2 instance while maintaining separate containers, application configurations, databases and access URLs.

The infrastructure provides a centralised hosting environment where applications can be deployed and accessed independently through their respective subdomains.

## Problem Statement

When managing multiple applications, one traditional approach is to provision a separate EC2 instance for every application.

Although this provides dedicated computing resources, it can introduce additional costs, especially when the applications do not require significant computing capacity or experience low traffic.

For example, hosting three applications independently could require:

- Three EC2 instances.
- Separate infrastructure configurations.
- Additional resource management.
- Higher recurring compute costs.

I wanted to explore an alternative architecture that would reduce infrastructure costs while maintaining a structured deployment environment.

The solution was to use a single EC2 instance as a shared application host, with Docker providing application isolation and Nginx handling traffic routing.

## Project Objectives

The main objectives were to:

1. Reduce infrastructure costs by hosting multiple applications on a single EC2 instance.
2. Automate AWS infrastructure provisioning using Terraform.
3. Containerise applications and their supporting services using Docker.
4. Maintain application separation through individual containers and Docker Compose configurations.
5. Configure Nginx as a reverse proxy to route requests based on domain names.
6. Provide HTTPS access using AWS Application Load Balancer and SSL/TLS certificates.
7. Use Amazon ECR as the central container image registry.
8. Create an infrastructure that can accommodate additional applications without requiring a completely new hosting environment for each one.

## Applications Hosted

The infrastructure currently supports three applications:

| Application | Description | Access URL |
|---|---|---|
| Rabbit LMS | Learning Management System | rabbit.apps.devs.surf |
| Sneakers | E-commerce application | sneakers.apps.devs.surf |
| Django CRM | Customer Relationship Management application | crm.apps.devs.surf |

Each application runs in its own containers and uses its own supporting database service.

This allows the applications to operate independently while sharing the underlying EC2 infrastructure.

## Architecture Overview

The infrastructure follows a shared-host architecture.

Incoming requests are received by an AWS Application Load Balancer, which handles HTTPS termination and forwards traffic to the EC2 instance.

Nginx on the EC2 instance then examines the requested hostname and routes the request to the appropriate application container.

### Architecture Components

**1. Terraform – Infrastructure as Code**

Terraform was used to provision and manage the AWS infrastructure.

Instead of manually creating resources through the AWS Management Console, I organised the infrastructure into reusable modules.

The infrastructure includes:

- VPC and networking resources.
- Public and private subnets.
- Internet Gateway and routing configuration.
- EC2 instance.
- Security groups.
- Application Load Balancer.
- Target group and listeners.
- SSL/TLS certificate integration.

The modular structure makes the infrastructure easier to maintain and extend.

**2. Amazon EC2 – Shared Application Host**

A single EC2 instance serves as the central hosting environment for all three applications.

Rather than assigning a separate server to each application, the instance runs multiple Docker containers.

This approach reduces the number of compute resources required for applications that do not need dedicated servers.

**3. Docker and Docker Compose – Application Containerisation**

Docker is used to package and run the applications in isolated containers.

Docker Compose manages the containers and their supporting services.

Each application has its own application services and database dependencies.

For example:

- Rabbit LMS runs its frontend, backend and MongoDB services.
- Sneakers runs its application container.
- Django CRM runs its application and PostgreSQL database services.

Database services communicate with their respective applications through Docker networking. Database ports are not exposed publicly.

This provides logical separation between application environments while allowing them to share the same EC2 host.

**4. Amazon ECR – Container Image Registry**

Amazon Elastic Container Registry (ECR) is used to store the Docker images required by the hosting environment.

Application images are built and pushed to ECR, allowing the EC2 instance to authenticate and pull the required images during deployment.

This separates image storage from the application hosting environment.

**5. Nginx – Reverse Proxy and Routing**

Nginx is responsible for directing incoming requests to the correct application.

Instead of exposing individual application ports publicly, the applications are accessed through dedicated subdomains.

The Nginx configuration uses hostname-based routing:

- `rabbit.apps.devs.surf` routes to the Rabbit frontend.
- `sneakers.apps.devs.surf` routes to the Sneakers application.
- `crm.apps.devs.surf` routes to the Django CRM application.

Rabbit LMS also has a separate backend API endpoint, which Nginx routes to the Rabbit backend container.

This allows multiple applications to share the same EC2 instance and public entry point without conflicting with one another.

**6. AWS Application Load Balancer – Traffic Entry Point**

An internet-facing Application Load Balancer provides a central entry point for incoming application traffic.

It is configured with:

- An HTTP listener on port 80 that redirects requests to HTTPS.
- An HTTPS listener on port 443.
- An SSL/TLS certificate managed through AWS Certificate Manager (ACM).
- A target group that forwards HTTP traffic to the EC2 instance.

The ALB terminates HTTPS connections and forwards requests to the EC2 instance, where Nginx handles application-level routing.

**7. AWS Certificate Manager – SSL/TLS**

AWS Certificate Manager is used to manage the SSL/TLS certificate for the application subdomains.

This enables secure HTTPS access without having to manage individual certificates inside each application container.

## How Traffic Flows Through the Infrastructure

Understanding the request flow is an important part of this project.

When a user visits one of the application URLs, the following process takes place:

1. The user accesses an application through its subdomain.
2. DNS resolves the subdomain to the Application Load Balancer.
3. The ALB receives the incoming request.
4. If the request uses HTTP, it redirects the user to HTTPS.
5. The ALB terminates the HTTPS connection using its ACM certificate.
6. The ALB forwards the request to the EC2 instance over HTTP.
7. Nginx on the EC2 instance examines the hostname in the request.
8. Based on the hostname, Nginx forwards the request to the appropriate application container.
9. The application processes the request and communicates with its database where necessary.
10. The response travels back through Nginx and the ALB to the user.

### Example: Accessing Rabbit LMS

When a user visits:

`https://rabbit.apps.devs.surf`

The request follows this path:

`User → DNS → Application Load Balancer → EC2 Nginx → Rabbit Frontend Container`

When the frontend makes an API request, Nginx routes the API traffic to the Rabbit backend container.

This routing arrangement allows the frontend and backend to operate as separate services while presenting a unified application URL to users.

## Security Considerations

Security was considered throughout the infrastructure design.

Some of the measures implemented include:

- Security groups to control inbound and outbound network traffic.
- SSH access restricted to an authorised source IP.
- EC2 application traffic on port 80 restricted to the ALB security group.
- Public access to the applications provided through the ALB over HTTP and HTTPS.
- HTTPS termination using AWS Certificate Manager.
- Database containers kept within Docker networking rather than exposing their ports publicly.
- EC2 IAM role permissions for retrieving container images from Amazon ECR.

These measures help reduce unnecessary public exposure of the infrastructure and its supporting services.

## Infrastructure Design Decisions

One of the most important decisions in this project was choosing a shared hosting architecture instead of provisioning separate EC2 instances.

This decision was based on the expected workload of the applications.

Since the applications are primarily intended for demonstrations and low-traffic usage, dedicating a separate server to each application would introduce additional infrastructure costs without necessarily providing meaningful benefits.

By using Docker, Docker Compose and Nginx, I was able to host multiple applications within one environment while keeping their application services and databases logically separated.

The architecture is designed for cost efficiency rather than high availability.

It is important to note that hosting all applications on one EC2 instance introduces a single point of failure. If the instance becomes unavailable, all hosted applications may become unavailable as well. Resource contention is also a consideration as application traffic increases.

For this reason, the design is most suitable for low-traffic applications and demonstration environments rather than workloads requiring high availability or independent scaling.

## Key Challenges and Learning Outcomes

Working on this project provided practical experience with several areas of cloud and DevOps engineering:

- Designing AWS networking and infrastructure using Terraform.
- Organising Terraform configurations into reusable modules.
- Managing multiple Docker containers on a shared host.
- Configuring Nginx reverse proxy routing for multiple applications.
- Understanding how DNS, HTTPS, load balancers and reverse proxies work together.
- Managing container images through Amazon ECR.
- Configuring communication between application containers and database services.
- Implementing network restrictions through AWS security groups.
- Troubleshooting application deployment and infrastructure issues.

One of my biggest takeaways was understanding that infrastructure design involves more than getting an application running. It also requires considering cost, security, maintainability, resource utilisation and the expected workload.

## Technologies Used

| Category | Technologies |
|---|---|
| Cloud Platform | AWS |
| Infrastructure as Code | Terraform |
| Compute | Amazon EC2 |
| Containerisation | Docker |
| Container Orchestration | Docker Compose |
| Reverse Proxy | Nginx |
| Load Balancing | AWS Application Load Balancer |
| Container Registry | Amazon ECR |
| SSL/TLS | AWS Certificate Manager |
| Networking | VPC, Subnets, Internet Gateway, Security Groups |
| Databases | MongoDB, PostgreSQL |

## Conclusion

This project demonstrates how multiple independent applications can be hosted on shared cloud infrastructure without requiring a dedicated EC2 instance for every application.

By combining Terraform, Docker, Docker Compose, Nginx and AWS services, I built a centralised hosting environment that focuses on reducing infrastructure costs while maintaining application separation and organised traffic routing.

The project also strengthened my understanding of how different DevOps and cloud technologies work together to deliver a functional hosting solution.

**The key idea behind this project is simple: optimise infrastructure resources without unnecessarily increasing complexity.**
