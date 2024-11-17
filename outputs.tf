output "vm1_public_ip" {
  value = azurerm_public_ip.public_ipabc.ip_address
}         

output "vm2_private_ip" {
  value = azurerm_network_interface.nicvm2.ip_configuration[0].private_ip_address
}    

