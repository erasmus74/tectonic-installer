variable "instance_count" {
  type        = "string"
  description = "Amount of etcd nodes to be created. This should be an odd number and typically recommended to be 1 or 3 or 5"
}

variable "base_domain" {
  type = "string"
}

variable "external_endpoints" {
  type = "list"
}

variable "container_image" {
  type = "string"
}

variable "cluster_name" {
  type        = "string"
  description = "Name of Tectonic cluster. ETCD node names will be prefixed with this string"
}

variable "vmware_folder" {
  type        = "string"
  description = "Name of the VMware folder to create objects in"
}

variable core_public_keys {
  type        = "list"
  description = "Public Key for Core User"
}

variable vmware_datacenters {
  type        = "map"
  description = "vSphere Datacenter to create VMs in"
}

variable vmware_clusters {
  type        = "map"
  description = "vSphere Cluster to create VMs in"
}

variable vm_disk_datastores {
  type        = "map"
  description = "vSphere Datastore to use for VMs"
}

variable vmware_resource_pool {
  type        = "map"
  description = "vSphere resource pool to create VMs in"
}

variable vm_vcpu {
  type        = "string"
  description = "ETCD VMs vCPU count"
}

variable vm_memory {
  type        = "string"
  description = "ETCD VMs Memory size in MB"
}

variable vm_network_labels {
  type        = "map"
  description = "ETCD VMs PortGroups"
}

variable vm_disk_template {
  type        = "string"
  description = "Disk template to use for cloning ETCD VM CoreOS Container Linux"
}

variable vm_disk_template_folder {
  type        = "string"
  description = "vSphere Folder CoreOS Container Linux is located in"
}

variable dns_server {
  type        = "string"
  description = "DNS Server of the nodes"
}

variable ip_address {
  type        = "map"
  description = "IP Address of the node"
}

variable gateways {
  type        = "map"
  description = "Network gateway IP for the node"
}

variable hostname {
  type        = "map"
  description = "Hostname of the node"
}

variable "tls_ca_crt_pem" {
  default = ""
}

variable "tls_client_key_pem" {
  default = ""
}

variable "tls_client_crt_pem" {
  default = ""
}

variable "tls_server_key_pem" {
  default = ""
}

variable "tls_server_crt_pem" {
  default = ""
}

variable "tls_peer_key_pem" {
  default = ""
}

variable "tls_peer_crt_pem" {
  default = ""
}

variable "http_proxy_enabled" {
  type        = "string"
  description = "switch to configure hosts to use outbound http proxy"
}

variable "http_proxy" {
  type        = "string"
  description = "http_proxy variable for Nodes"
}

variable "https_proxy" {
  type        = "string"
  description = "https_proxy variable for Nodes"
}

variable "no_proxy" {
  type        = "string"
  description = "no_proxy variable for Nodes"
}

variable "trusted_ca" {
  type        = "string"
  description = "Path to CA to add to trusted CAs on cluster nodes"
}

variable "ntp_sources" {
  type        = "map"
  description = "NTP sources for the node"
}
