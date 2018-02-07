Configuration AzureStackonAzure {
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node 'localhost' {
        
        WindowsFeature HyperV {
            Ensure = "Present"
            Name = "Hyper-V"
        }

        WindowsFeature HyperVTools {
            Ensure = "Present"
            Name = "RSAT-Hyper-V-Tools"
            IncludeAllSubFeature = $true
        }

        WindowsFeature ADPowershellTools {
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
            IncludeAllSubFeature = $true
        }

        WindowsFeature ADDSTools {
            Ensure = "Present"
            Name = "RSAT-ADDS"
            IncludeAllSubFeature = $true
        }

        WindowsFeature Failover-Clustering {
            Ensure = "Present"
            Name = "Failover-Clustering"
        }

        WindowsFeature Web-Server {
            Ensure = "Present"
            Name = "Web-Server"
        }

        WindowsFeature RSAT-Clustering {
            Ensure = "Present"
            Name = "RSAT-Clustering"
            IncludeAllSubFeature = $true
        }

        WindowsFeature FS-FileServer {
            Ensure = "Present"
            Name = "FS-FileServer"
        }
        
        WindowsFeature Storage-Services {
            Ensure = "Present"
            Name = "Storage-Services"
        }

        WindowsFeature Web-Mgmt-Console {
            Ensure = "Present"
            Name = "Web-Mgmt-Console"
        }

        WindowsFeature Web-Scripting-Tools {
            Ensure = "Present"
            Name = "Web-Scripting-Tools"
        }

        WindowsFeature GPMC {
            Ensure = "Present"
            Name = "GPMC"
        }

        File DefaultLocalPath {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\AzureStackOnAzureVM"
        }

        File Install-ADSK {
            Ensure = "Present"
            SourcePath = "https://raw.githubusercontent.com/ned1313/AzureStack-VM-PoC/master/scripts/Install-ASDK.ps1"
            DestinationPath = "C:\AzureStackOnAzureVM\Install-ASDK.ps1"
        }

        File ASDKCompanionService {
            Ensure = "Present"
            SourcePath = "https://raw.githubusercontent.com/ned1313/AzureStack-VM-PoC/master/scripts/ASDKCompanionService.ps1"
            DestinationPath = "C:\AzureStackOnAzureVM\ASDKCompanionService.ps1"
        }

    }
}

[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            ActionAfterReboot = 'ContinueConfiguration'
            RebootNodeIfNeeded = $true
        }
    }
}