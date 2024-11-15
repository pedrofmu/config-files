param (
    [string]$DomainName,
    [string]$UserName,
    [string]$FullName,
    [string]$Passwd,
    [string]$OU,
    [string]$PathPersonalFolder,
    [string]$PathPerfMovil
)

Import-Module ActiveDirectory

if (Get-ADUser -Filter {SamAccountName -eq $UserName} -ErrorAction SilentlyContinue) {
    Write-Host "$UserName already exist"
} else {
    $GivenName = $FullName.Split(" ")[0]
    $Surname = if ($FullName.Split(" ").Count -gt 1) { $FullName.Split(" ")[1] } else { "" }

    $UserParams = @{
        SamAccountName    = $UserName
        UserPrincipalName = "$UserName@$DomainName"
        GivenName         = $GivenName
        Surname           = $Surname
        AccountPassword   = (ConvertTo-SecureString $Passwd -AsPlainText -Force)
        Path              = $OU
        Enabled           = $true
    }

    if ($PathPersonalFolder){
        $UserParams['HomeDirectory'] = $PathPersonalFolder
        $UserParams['HomeDrive'] = "T:"
    }

    if ($PathPerfMovil){
        $UserParams['ProfilePath'] = $PathPerfMovil
    } 
    
    New-ADUser @UserParams 

    Set-ADUser -Identity $UserName -ChangePasswordAtLogon $false

    Write-Host "$UserName create in $OU"
}
