#Variables

#Azure account variables
variable "arm_subscription_id" {}
variable "arm_principal" {}
variable "arm_password" {}
variable "tenant_id" {}

#Deployment variables
variable "arm_region" {
    default = "East US"
}
variable "resource_group_name" {
    default = "AzureStackonAzure"
}

#VM Information
variable "vm_size" {
    type = "string"
    description = "Select a VM size. Valid inputs are: Standard_E16s_v3, Standard_D32s_v3, Standard_E32s_v3, Standard_D64s_v3, Standard_E64s_v3"
    default = "Standard_E16s_v3"
}

variable "vm_name" {
    type = "string"
    description = "Hostname for the VM"
    default = "AzS-HOST1"
}

variable "vm_data_disk_size" {
    type = "string"
    description = "Disk size for the VM.  Must be 128GB or bigger."
    default = "256"
}

variable "vm_admin_password" {
    default = "@zur3StackR0cks!"
}

#Networking Information
#Create new VNet variables
variable "vnet_name" {
    type = "string"
    description = "Name for VNet.  Leave blank if using existing VNet"
    default = "AzureStack-VNet"
}

variable "vnet_cidr_range" {
    type = "string"
    description = "CIDR address range for VNet.  Will create a single subnet in VNet using entire address space"
    default = "10.0.0.0/16"
}

variable "public_dns_name" {
    type = "string"
    description = "public dns name to use for VM public IP address"
}