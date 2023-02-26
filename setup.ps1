Install-Module -Name Microsoft.Graph -Force -AcceptLicense
Install-Module -Name Habitica -Force -AcceptLicense
Install-Module -Name Pester -Force -AcceptLicense
Install-Module -Name PSModuleDevelopment -Force -AcceptLicense
Install-Module -Name Microsoft.PowerShell.SecretManagement -Force -AcceptLicense
Install-Module -Name Microsoft.PowerShell.SecretStore -Force -AcceptLicense

Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
