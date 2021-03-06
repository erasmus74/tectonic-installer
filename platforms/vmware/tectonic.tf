module "bootkube" {
  source         = "../../modules/bootkube"
  cloud_provider = ""

  cluster_name = "${var.tectonic_cluster_name}"

  # Address of kube-apiserver
  kube_apiserver_url = "https://${var.tectonic_vmware_controller_domain}:443"

  # Address of Identity service
  oidc_issuer_url = "https://${var.tectonic_vmware_ingress_domain}/identity"

  # Platform-independent variables wiring, do not modify.
  existing_certs   = "${var.tectonic_existing_certs}"
  container_images = "${var.tectonic_container_images}"
  versions         = "${var.tectonic_versions}"

  ca_cert    = "${var.tectonic_ca_cert}"
  ca_key     = "${var.tectonic_ca_key}"
  ca_key_alg = "${var.tectonic_ca_key_alg}"

  service_cidr = "${var.tectonic_service_cidr}"
  cluster_cidr = "${var.tectonic_cluster_cidr}"

  advertise_address = "0.0.0.0"
  anonymous_auth    = "false"

  oidc_username_claim = "email"
  oidc_groups_claim   = "groups"
  oidc_client_id      = "tectonic-kubectl"

  etcd_endpoints   = "${formatlist("%s.%s", values(var.tectonic_vmware_etcd_hostnames), var.tectonic_base_domain)}"
  etcd_ca_cert     = "${var.tectonic_etcd_ca_cert_path}"
  etcd_client_cert = "${var.tectonic_etcd_client_cert_path}"
  etcd_client_key  = "${var.tectonic_etcd_client_key_path}"
  etcd_tls_enabled = "${var.tectonic_etcd_tls_enabled}"

  etcd_cert_dns_names = ["${formatlist("%s.%s",
        values(var.tectonic_vmware_etcd_hostnames),
        var.tectonic_base_domain
  )}"]

  etcd_tls_enabled = "${var.tectonic_etcd_tls_enabled}"

  experimental_enabled = "${var.tectonic_experimental}"

  master_count = "${var.tectonic_master_count}"
}

module "tectonic" {
  source   = "../../modules/tectonic"
  platform = "vsphere"

  cluster_name = "${var.tectonic_cluster_name}"

  # Address of kube-apiserver
  kube_apiserver_url = "https://${var.tectonic_vmware_controller_domain}:443"

  # Address of the Tectonic console (without protocol)
  base_address = "${var.tectonic_vmware_ingress_domain}"

  # Platform-independent variables wiring, do not modify.
  existing_certs   = "${var.tectonic_existing_certs}"
  container_images = "${var.tectonic_container_images}"
  versions         = "${var.tectonic_versions}"

  license_path     = "${var.tectonic_vanilla_k8s ? "/dev/null" : pathexpand(var.tectonic_license_path)}"
  pull_secret_path = "${var.tectonic_vanilla_k8s ? "/dev/null" : pathexpand(var.tectonic_pull_secret_path)}"

  admin_email         = "${var.tectonic_admin_email}"
  admin_password_hash = "${var.tectonic_admin_password_hash}"

  update_channel = "${var.tectonic_update_channel}"
  update_app_id  = "${var.tectonic_update_app_id}"
  update_server  = "${var.tectonic_update_server}"

  ca_generated  = "${module.bootkube.ca_cert == "" ? false : true}"
  ca_cert       = "${module.bootkube.ca_cert}"
  local_ca_cert = "${module.bootkube.local_ca_cert}"
  ca_key_alg    = "${module.bootkube.ca_key_alg}"
  ca_key        = "${module.bootkube.ca_key}"

  console_client_id = "tectonic-console"
  kubectl_client_id = "tectonic-kubectl"
  ingress_kind      = "NodePort"
  experimental      = "${var.tectonic_experimental}"
  master_count      = "${var.tectonic_master_count}"
  stats_url         = "${var.tectonic_stats_url}"

  image_re = "${var.tectonic_image_re}"

  http_proxy  = "${var.tectonic_vmware_httpproxy}"
  https_proxy = "${var.tectonic_vmware_httpsproxy}"
  no_proxy    = "${var.tectonic_vmware_noproxy}"
}

module "flannel-vxlan" {
  source = "../../modules/net/flannel-vxlan"

  flannel_image     = "${var.tectonic_container_images["flannel"]}"
  flannel_cni_image = "${var.tectonic_container_images["flannel_cni"]}"
  cluster_cidr      = "${var.tectonic_cluster_cidr}"

  bootkube_id = "${module.bootkube.id}"
}

module "calico-network-policy" {
  source = "../../modules/net/calico-network-policy"

  kube_apiserver_url = "https://${var.tectonic_vmware_controller_domain}:443"
  calico_image       = "${var.tectonic_container_images["calico"]}"
  calico_cni_image   = "${var.tectonic_container_images["calico_cni"]}"
  cluster_cidr       = "${var.tectonic_cluster_cidr}"
  enabled            = "${var.tectonic_calico_network_policy}"

  bootkube_id = "${module.bootkube.id}"
}

data "archive_file" "assets" {
  type       = "zip"
  source_dir = "./generated/"

  # Because the archive_file provider is a data source, depends_on can't be
  # used to guarantee that the tectonic/bootkube modules have generated
  # all the assets on disk before trying to archive them. Instead, we use their
  # ID outputs, that are only computed once the assets have actually been
  # written to disk. We re-hash the IDs (or dedicated module outputs, like module.bootkube.content_hash)
  # to make the filename shorter, since there is no security nor collision risk anyways.
  #
  # Additionally, data sources do not support managing any lifecycle whatsoever,
  # and therefore, the archive is never deleted. To avoid cluttering the module
  # folder, we write it in the Terraform managed hidden folder `.terraform`.  
  output_path = "./.terraform/generated_${sha1("${module.tectonic.id} ${module.bootkube.id} ${module.flannel-vxlan.id} ${module.calico-network-policy.id}")}.zip"
}
