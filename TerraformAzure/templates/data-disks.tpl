  storage_data_disk {
    name                    = "datadisk-${current_count}"
    managed_disk_type       = "Premium_LRS"
    create_option           = "Empty"
    disk_size_gb            = "${disk_size_gb}"
    lun                     = ${current_count}
  }