#Configure provider
provider "azurerm" {
    subscription_id = "${var.arm_subscription_id}"
    client_id = "${var.arm_principal}"
    client_secret = "${var.arm_password}"
    tenant_id = "${var.tenant_id}"
 }

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
    vnet_name = "${var.vnet_name}"
    address_space = "${var.vnet_cidr_range}"
    subnet_prefixes = ["${cidrsubnet(var.vnet_cidr_range,8,0)}"]
    subnet_names = ["${var.vnet_name}-subnet1"]
}

#Create public IP address
resource "azurerm_public_ip" "azspip" {
  name                         = "${var.vm_name}-pip1"
  location                     = "${var.arm_region}"
  resource_group_name          = "${azurerm_resource_group.AzSonAz.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.public_dns_name}"

}

#Create security group and rules
resource "azurerm_network_security_group" "azsnsg" {
  name                = "${var.vm_name}-nsg"
  location            = "${var.arm_region}"
  resource_group_name = "${azurerm_resource_group.AzSonAz.name}"

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

#Create NIC
resource "azurerm_network_interface" "azsnic" {
  name                = "${var.vm_name}-nic1"
  location            = "${var.arm_region}"
  resource_group_name = "${azurerm_resource_group.AzSonAz.name}"
  network_security_group_id = "${azurerm_network_security_group.azsnsg.id}"

  ip_configuration {
    name                          = "${var.vm_name}-nic1config1"
    subnet_id                     = "${module.vnet.vnet_subnets[0]}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.azspip.id}"
  }
}

#Create new VM
resource "azurerm_virtual_machine" "azs" {
  name                  = "${var.vm_name}"
  location              = "${var.arm_region}"
  resource_group_name   = "${azurerm_resource_group.AzSonAz.name}"
  network_interface_ids = ["${azurerm_network_interface.azsnic.id}"]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "azsosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "${var.vm_data_disk_size}"
  }

  # Optional data disks
  storage_data_disk {
    name                    = "datadisk-1"
    managed_disk_type       = "Premium_LRS"
    create_option           = "Empty"
    disk_size_gb            = "${var.vm_data_disk_size}"
    lun                     = 1
  }

  storage_data_disk {
    name                    = "datadisk-2"
    managed_disk_type       = "Premium_LRS"
    create_option           = "Empty"
    disk_size_gb            = "${var.vm_data_disk_size}"
    lun                     = 2
  }

  storage_data_disk {
    name                    = "datadisk-3"
    managed_disk_type       = "Premium_LRS"
    create_option           = "Empty"
    disk_size_gb            = "${var.vm_data_disk_size}"
    lun                     = 3
  }

  storage_data_disk {
    name                    = "datadisk-4"
    managed_disk_type       = "Premium_LRS"
    create_option           = "Empty"
    disk_size_gb            = "${var.vm_data_disk_size}"
    lun                     = 4
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "AzureStackAdmin"
    admin_password = "Password1234!"
  }

}

#resource "azurerm_virtual_machine_extension" "azsext" {
#  name                 = "${var.vm_name}-ext"
#  location             = "${var.arm_region}"
#  resource_group_name  = "${azurerm_resource_group.AzSonAz.name}"
#  virtual_machine_name = "${azurerm_virtual_machine.azs.name}"
#  publisher            = "Microsoft.Compute"
#  type                 = "CustomScriptExtension"
#  type_handler_version = "1.8"
#
#  settings = <<SETTINGS
#    {
#        "commandToExecute": "hostname"
#    }
#SETTINGS
#
#  tags {
#    environment = "Production"
#  }
#}

