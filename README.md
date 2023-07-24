# WideBot DevOps Task

### Introduction

This documentation provides a comprehensive guide for provisioning the infrastructure for a web application using terraform and kubernetes along with associated databases (MongoDB, SQL Server), Redis caching layer, domain name configuration, SSL certificate setup, and load balancer implementation. The infrastructure will be deployed using Terraform and managed within a Google Kubernetes Engine (GKE) cluster.

### Prerequisites

The following are required to complete this task:

1. Basic knowledge of Terraform, Docker, Kubernetes, and Google Cloud Platform (GCP)
2. GCP account with billing enabled
3. Terraform v0.12+ installed
4. Docker installed
5. kubectl configured to connect to a GKE cluster (Just in case you want to connect to the GKE cluster from your machine)

### Project Structure

The project consists mainly of 3 directories. Here is a high-level overview of the structure:

1. `application`: This directory contains your application's code and its dependencies. You can place all your source code files and any required libraries or dependencies within this directory.

2. `kubernetes`: This directory holds the Kubernetes deployment files. You can place all the YAML or JSON files required to deploy your application on Kubernetes in this directory.

3. `terraform`: This directory contains the Terraform infrastructure files. Here, you can put the main Terraform files used to create your infrastructure (e.g., virtual machines, networks). Additionally, it includes a subdirectory called k8s.

4. `terraform/k8s`: This subdirectory within the Terraform directory contains the Terraform code specifically for creating Kubernetes resources. It serves as an alternative to the kubernetes directory files. Here, you can have all the necessary Terraform files to manage your Kubernetes resources (e.g., deployments, services, configmaps).

Note: The `terraform/k8s` directory provides an alternative approach to managing Kubernetes resources through Terraform, offering flexibility and ease of infrastructure management alongside your application's deployment files in the kubernetes directory.

# Project Architecture:

The project architecture is designed to deploy a cloud-based application. The architecture is implemented using Terraform to provision infrastructure resources in Google Cloud Platform (GCP) and Kubernetes (K8s) to manage containerized applications. The application consists of multiple components, including a web application, a backend database, and a caching layer.

1. VPC and Subnets:

The architecture starts with the creation of a Virtual Private Cloud (VPC) using the google_compute_network resource in Terraform.
The VPC is divided into two subnets: public and private.
The public subnet hosts a VM that acts as a bastion host to connect to the GKE cluster.
The private subnet contains the GKE cluster where the main application services run.

2. VPC Firewall:

A firewall rule is defined using google_compute_firewall to control inbound and outbound traffic in the VPC.
The firewall allows access to specific ports like SSH (22), HTTPS (443), Redis (6379), MongoDB (27017), and SQL Server (1433) from the public subnet.

3. GKE Cluster:

The GKE cluster is created using google_container_cluster resource in Terraform.
The cluster is set to be private, with private nodes and endpoints accessible only from within the VPC.
The master node has a private IP address within a specific CIDR block.

Hers is a diagram:

![Architecture](https://github.com/amr-elzahar/widebot-devops-task/blob/main/diagram.png?raw=true)

# Provision Infrastructure with Terraform

The terraform directory contains the Terraform configuration files to provision the infrastructure on GCP.

### Usage

1. Configure GCP credentials in Terraform - set the credentials and project variables in terraform/vars.tf using the following:

```
cloud auth application-default login
```

2. Navigate to terraform directory:

```
cd terraform/
```

2. Run the following command to initialize the working directory.

```
terraform init
```

3. Run the following command to ve rify the resources to be created.

```
terraform plan
```

5. Run the following command to provision the GCP infrastructure.

```
terraform apply --auto-approve
```

6. Once complete, the Kubernetes cluster will be available. Configure kubectl on the public VM to connect to it:

```
gcloud container clusters get-credentials <gke-cluster-name> --zone <zone> --project <project-id>
```

- Replace the `<gke-cluster-name>` with the name of the cluster defined in terraform files
- Replace `<zone>` with the name of zone where the k8s cluster is created
- Replace `<project-id>` with the project id

# Provision Kubernetes resources with Terraform

There are two approaches to automating Kubernetes resource provisioning. One option is to utilize the files in the Kubernetes directory directly by navigating to this directory and running the following command:

```
kubectl create -f .
```

Alternatively, we can leverage Terraform to automate the process by using the files located in the terraform/k8s directory bu using:

```
terrafom apply --auto-approve
```

# Configure Domain and SSL with the application

1. Update appsettings.json and set these environment variables as so:

```
{
  "AppSettings": {
    "DomainName": "${DOMAIN_NAME}",
    "SSL": {
      "CertificatePath": "${SSL_CERTIFICATE}",
      "PrivateKeyPath": "${SSL_PRIVATE_KEY}"
    }
  }
}
```

2. Update the application code as follows:

```
using System;

public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {

        var domainName = Environment.GetEnvironmentVariable("DOMAIN_NAME");
        var sslCertificate = Environment.GetEnvironmentVariable("SSL_CERTIFICATE");
        var sslPrivateKey = Environment.GetEnvironmentVariable("SSL_PRIVATE_KEY");

         // Then use these variables in your code

}
```

Note: We will use these environment variables in the k8s deployment files of the application

# Configure Domain and SSL with kubernetes

1. Using your domain provider, point your domain (e.g. my-domain.com) to the load balancer IP address.

2. Obtain an SSL certificate for the domain from a trusted certificate authority.

3. Create a kubernetes secret for the SSL Certificate.

4. Configure the Ingress resource kubernetes/ingress.yaml to use the secret and domain.

Note: Step 3 and step 4 were implemented in the the app deployment in the terraform code

# Application with Redis Caching Integration

This demonstrates how to integrate Redis caching into an ASP.NET application to improve performance

### Usage

1. Install Redis package using the Package Manager Console:

```
Install-Package StackExchange.Redis
```

2. Add Redis configuration by openning the ASP.NET application's appsettings.json file and add the Redis configuration settings. Make sure to replace the placeholders with your actual Redis server address and port:

```
{
  "Redis": {
    "ConnectionString": "redis_server:port",
  }
}
```

3. Set up Redis client and caching logic by adding the following code to your Startup.cs file:

```
using StackExchange.Redis;


public void ConfigureServices(IServiceCollection services)
{

    var redisConfig = Configuration.GetSection("Redis").Get<RedisConfiguration>();
    services.AddSingleton<IConnectionMultiplexer>(ConnectionMultiplexer.Connect(redisConfig.ConnectionString));

}

```

4. Implement caching logic by adding the Redis client and use it to store and retrieve data. Here's an example of how to implement such a caching:

```
using StackExchange.Redis;


private readonly IConnectionMultiplexer _redis;

public YourService(IConnectionMultiplexer redis)
{
    _redis = redis;
}

public string GetCachedData(string key)
{
    IDatabase cache = _redis.GetDatabase();
    var cachedValue = cache.StringGet(key);
    if (cachedValue.HasValue)
    {
        // Data found in cache
        return cachedValue;
    }
    else
    {
        // Data not found in cache, fetch from the original source and add to cache
        var data = GetDataFromOriginalSource();
        cache.StringSet(key, data, TimeSpan.FromMinutes(10)); // Cache with 10 minutes expiration
        return data;
    }
}
```
