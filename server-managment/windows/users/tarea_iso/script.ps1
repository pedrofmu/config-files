#
# Copyright (c) 2025 Pedro Fernández Muñoz 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software...
#
param (
    [string]$GroupName = "",
    [string]$UsersFilePath = ".\delimitado.csv"
)

if ($GroupName -eq "") {
    Write-Error "GroupName not defined"
    exit 
}

if (-not (Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue)) {
    New-LocalGroup -Name $GroupName
    Write-Host "Group '$GroupName' created"
}

if (-not (Test-Path -LiteralPath $UsersFilePath)) { 
    Write-Error "Users file not found: $UsersFilePath"; 
    return 
}

$usersList = Import-Csv -Path $UsersFilePath -Delimiter ","

foreach ($userEntry in $usersList) {
    $FullName = "$($userEntry.Nom) $($userEntry.Cognom1) $($userEntry.Cognom2)"
    $LoginName = "$($userEntry.Nom.Substring(1))$($userEntry.Cognom1.Substring(3))$($userEntry.Cognom2.Substring(3))"
    $Description = "Localitat: $($userEntry.Localitat); Tel: $($userEntry.Tel)"
    $Password = ConvertTo-SecureString -String "$($userEntry.Cognom1)" -AsPlainText -Force

    if ([string]::IsNullOrWhiteSpace($LoginName)) {
        Write-Error "Login Name not defined"
        continue
    }

    # Create user if missing
    if (-not (Get-LocalUser -Name $LoginName -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name $LoginName -Password $Password -FullName $FullName -Description $Description
        Write-Host "$LoginName created"
    } else {
        Write-Host "$LoginName already exists"
        continue
    }

    # Manage group 
    $SecondaryGroupName = "$($userEntry.Groups)"
    if (-not ([string]::IsNullOrWhiteSpace($SecondaryGroupName))) {
        if (-not (Get-LocalGroup -Name $SecondaryGroupName -ErrorAction SilentlyContinue)) {
            New-LocalGroup -Name $SecondaryGroupName
            Write-Host "$($SecondaryGroupName) group created"    
        }

        Add-LocalGroupMember -Group $SecondaryGroupName -Member $LoginName
        Write-Host "$($LoginName) added to group $($SecondaryGroupName)"
    } 

    # Add user to groups
    Add-LocalGroupMember -Group $GroupName -Member $LoginName
    Write-Host "$($LoginName) added to group $($GroupName)"
}

Write-Host "Finished creating users"
