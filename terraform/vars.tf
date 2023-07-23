variable "project_id" {
  type = string
  default = "some text here..."
  description = "Project ID"
}

variable "region" {
  type = string
  default = "us-east1"
  description = "Project region"
}

variable "zone" {
  type = string 
  default = "us-east1-b"
  description = "Project zone" 
}

variable "vpc_name" {
  type = string
  default = "web-app-vpc"
  description = "The name of the VPC"
}

variable "public_subnet_name" {
  type = string
  default = "public-subnet"
  description = "The name of the Public Subnet"
}

variable "private_subnet_name" {
  type = string
  default = "private-subnet"
  description = "The name of the Private Subnet"
}

variable "public_subnet_cidr" {
  default = "10.10.0.0/16"
  type = string
  description = "CIDR block of the public subnet"
} 

variable "private_subnet_cidr" {
  default = "10.11.0.0/16"
  type = string
  description = "CIDR block of the private subnet"
} 

variable "cluster_name" {
  type = string
  default = "private-gke"
  description = "The name of GKE cluster"
}

variable "node_pool_machine_type" {
  type    = string
  default = "e2-small"
  description = "The node pool machine type"
}

variable "node_pool_disk_type" {
  type    = string
  default = "pd-balanced"
  description = "The node pool disk type"
}

variable "node_pool_disk_size" {
  type    = number
  default = 10
  description = "The node pool disk size"
}

variable "node_pool_image_type" {
  type    = string
  default = "pd-balanced"
  description = "The node pool image type"
}


