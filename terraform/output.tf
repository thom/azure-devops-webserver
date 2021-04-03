output "public_ip_address" {
  value       = "http://${azurerm_public_ip.pip.ip_address}/"
  description = "The public IP address of the load balancer"
}
