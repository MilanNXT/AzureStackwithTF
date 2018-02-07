param(
    $VMName = "MySQL01",
    $AdminUserName = "mysqladmin",
    $ResourceGroupName = "MySQL",
    $ArmEndpoint = "https://adminmanagement.local.azurestack.external",
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential] $AzureStackAdmin,
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential] $cloudAdminCreds
)

$MySQLCredentials = Get-Credential -UserName $AdminUserName -Message "Credentials for MySQL admin user"

Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

Add-AzureRmAccount -Environment "AzureStackAdmin"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location local

$deployment = New-AzureRmResourceGroupDeployment -Name $ResourceGroupName `
    -ResourceGroupName $ResourceGroupName -Mode Incremental `
    -TemplateUri "https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/mysql-standalone-server-windows/azuredeploy.json" `
    -TemplateParameterObject @{"VMName"=$VMName;"AdminUserName"=$AdminUserName;"adminPassword"=$MySQLCredentials.Password}

Invoke-WebRequest -Uri https://aka.ms/azurestackmysqlrp1712 -OutFile C:\AzureStackOnAzureVM\QuickStart\MSSQL\AzureStack.MySQL.RP.zip

Expand-Archive -Path C:\AzureStackOnAzureVM\QuickStart\MySQL\AzureStack.MySQL.RP.zip

# Use the NetBIOS name for the Azure Stack domain. On the Azure SDK, the default is AzureStack, and the default prefix is AzS.
# For integrated systems, the domain and the prefix are the same.
$domain = "AzureStack"
$prefix = "AzS"
$privilegedEndpoint = "$prefix-ERCS01"

# Point to the directory where the resource provider installation files were extracted.
$tempDir = 'C:\AzureStackOnAzureVM\QuickStart\MSSQL'

# Set the credentials for the new resource provider VM.
$vmLocalAdminPass = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("mysqlrpadmin", $vmLocalAdminPass)

# Change the following as appropriate.
$PfxPass = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force

# Run the installation script from the folder where you extracted the installation files.
# Find the ERCS01 IP address first, and make sure the certificate
# file is in the specified directory.
. $tempDir\DeployMySQLProvider.ps1 -AzCredential $AzureStackAdmin `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $cloudAdminCreds `
  -PrivilegedEndpoint $privilegedEndpoint `
  -DefaultSSLCertificatePassword $PfxPass `
  -DependencyFilesLocalPath $tempDir\cert `
  -AcceptLicense
    