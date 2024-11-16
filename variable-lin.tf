variable "rg_name" {
  default = "rg_abc"
}

variable "location" {
  default = "EastAsia"
}

variable "address_space1" {
  default = ["10.5.0.0/16"]
  type    = list(string)
}

variable "address_space2" {
  default = ["10.15.0.0/16"]
  type    = list(string)
}



variable "vnet_name" {
  default = "abc_vnet"
}
variable "subnet_space1" {
  default = ["10.5.1.0/24", "10.5.2.0/24"]
  type    = list(string)
}

variable "subnet_space2" {
  default = ["10.15.0.0/24", "10.15.2.0/24"]
  type    = list(string)
}


variable "subnet_name" {
  default = "abc_subnet"
}

variable "key" {
  description = "abc SSH public key"
  type        = string
  default = "abcsshkey"
}
variable "nic_name" {
  default = "abcnic"
}
variable "public-ip_name" {
  default = "public-winip"
}

variable "ip_name" {
  default = "ip"
}
variable "sku" {
  default = "22.04-LTS"
}
variable "vm_name" {
  default = "linuxtfvm"
}
variable "admin" {
  default = "azureadmin"
}
variable "size" {
  default = "Standard_B1s"
}
variable "user" {
  default = "azureuser"
}

variable "private_ip" {
  description = "Static private IP address for the network interface"
  type        = string
  default     = "10.15.0.10"
}



variable "nsg" {
  default = "nsglinux"
}

