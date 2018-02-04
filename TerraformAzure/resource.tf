#Create resource group
resource "azurerm_resource_group" "AzSonAz" {
    name = "${var.resource_group_name}"
    location = "${var.arm_region}"
}
#Create new VNet
module "vnet" {
    source = "Azure/network/azurerm"
    resource_group_name = "${azurerm_resource_group.AzSonAz.name}"
    location = "${var.arm_region}"
    address_space = "${var.vnet_cidr_range}"
    subnet_prefixes = ["${cidrsubnet(var.vnet_cidr_range,8,0)"]
    subnet_names = ["${var.vnet_name}-subnet1"]
}

#Create data disks
#module "datadisks" {
#
#    count = 4
#
#    source               = "Azure/manageddisk/azurerm"
#    managed_disk_name    = "datadisk-${count.index}"
#    resource_group_name  = "${azurerm_resource_group.AzSonAz.name}"
#    disk_size_gb         = "${var.vm_data_disk_size}"
#    location             = "${var.arm_region}"
#    storage_account_type = "Premium_LRS"
#}

#Create storage_os_disk template
data template_file data_disk_list {
    count = 4
    source = "${file(./templates/data-disks.tpl)}"

    vars = {
        disk_size_gb = "${var.vm_data_disk_size}"
        current_count = "${count.index}"
    }


}

#Create new VM
  module "windowsservers" {
    source              = "Azure/compute/azurerm"
    resource_group_name = "${azurerm_resource_group.AzSonAz.name}"
    location            = "${var.arm_region}"
    vm_hostname         = "${var.vm_name}"
    admin_password      = "${var.vm_admin_password}"
    public_ip_dns       = ["${var.public_dns_name}"]
    nb_public_ip        = "1"
    remote_port         = "3389"
    nb_instances        = "1"
    vm_os_publisher     = "MicrosoftWindowsServer"
    vm_os_offer         = "WindowsServer"
    vm_os_sku           = "2016-Datacenter"
    vm_size             = "${var.vm_size}"
    vnet_subnet_id      = "${module.vnet.vnet_subnets[0]}"
    delete_os_disk_on_termination = "true"
  }

