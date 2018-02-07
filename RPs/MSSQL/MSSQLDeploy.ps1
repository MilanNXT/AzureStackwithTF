param(
    $VMName = "MSSQL01",
    $AdminUserName = "mssqladmin",
    $ResourceGroupName = "MSSQL",
    $ArmEndpoint = "https://adminmanagement.local.azurestack.external",
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential] $AzureStackAdmin,
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential] $cloudAdminCreds
)

$MSSQLCredentials = Get-Credential -UserName $AdminUserName -Message "Credentials for MSSQL admin user"

Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

Add-AzureRmAccount -Environment "AzureStackAdmin" -Credential $AzureStackAdmin

New-AzureRmResourceGroup -Name $ResourceGroupName -Location local -Force

$deployment = New-AzureRmResourceGroupDeployment -Name $ResourceGroupName `
    -ResourceGroupName $ResourceGroupName -Mode Incremental `
    -TemplateFile .\azuredeploy.json `
    -TemplateParameterObject @{"vmName"=$VMName;"adminUsername"=$AdminUserName;"adminPassword"=$MSSQLCredentials.Password;"sqlAuthenticationLogin"=$AdminUserName;"sqlAuthenticationPassword"=$MSSQLCredentials.Password}

Invoke-WebRequest -Uri https://aka.ms/azurestacksqlrp1712 -OutFile C:\AzureStackOnAzureVM\QuickStart\MSSQL\AzureStack.MSSQL.RP.zip

Expand-Archive -Path C:\AzureStackOnAzureVM\QuickStart\MSSQL\AzureStack.MSSQL.RP.zip

# Use the NetBIOS name for the Azure Stack domain. On the Azure Stack SDK, the default is AzureStack and the default prefix is AzS.
# For integrated systems, the domain and the prefix are the same.
$domain = "AzureStack"
$prefix = "AzS"
$privilegedEndpoint = "$prefix-ERCS01"

# Point to the directory where the resource provider installation files were extracted.
$tempDir = 'C:\AzureStackOnAzureVM\QuickStart\MSSQL\AzureStack.MSSQL.RP'

# Set credentials for the new Resource Provider VM.
$vmLocalAdminPass = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin", $vmLocalAdminPass)

# Change the following as appropriate.
$PfxPass = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force

# Change directory to the folder where you extracted the installation files.
# Then adjust the endpoints.
. $tempDir\DeploySQLProvider.ps1 -AzCredential $AzureStackAdmin `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $cloudAdminCreds `
  -PrivilegedEndpoint $privilegedEndpoint `
  -DefaultSSLCertificatePassword $PfxPass `
  -DependencyFilesLocalPath $tempDir\cert



