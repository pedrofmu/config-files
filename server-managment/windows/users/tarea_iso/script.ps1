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

if (Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue -not) {
    New-LocalGroup -Name $GroupName
}

$usersList = Import-Csv -Path $UsersFilePath

foreach ($userEntry in $usersList) {
    $FullName = "$($userEntry.Nom) $($userEntry.Cognom1) $($userEntry.Cognom2)"
    $LoginName = "$($userEntry.Nom.Substring(1))$($userEntry.Cognom1.Substring(3))$($userEntry.Cognom2.Substring(3))"
    $Description = "Localitat: $($userEntry.Localitat); Tel: $($userEntry.Tel)"
    $Password = ConvertTo-SecureString -String "$($userEntry.Cognom1)"

    if ($LoginName -eq "") {
        Write-Error "Login Name not defined"
        exit
    }

    New-LocalUser -Name $LoginName -Password $Password -FullName $FullName -Description $Description 
    Write-Host "$($LoginName) created"

    # Manage group 
    $SecondaryGroupName = "$($userEntry.Groups)"
    if (($SecondaryGroupName -ne "") -and (Get-LocalGroup -Name $SecondaryGroupName -ErrorAction SilentlyContinue -not)) {
        New-LocalGroup -Name $SecondaryGroupName
        Write-Host "$($SecondaryGroupName) group created"
    } 

    # Add user to groups
    Add-LocalGroupMember -Group $SecondaryGroupName -Member $LoginName
    Write-Host "$($LoginName) added to group $($SecondaryGroupName)"
    Add-LocalGroupMember -Group $GroupName -Member $LoginName
    Write-Host "$($LoginName) added to group $($GroupName)"
}

Write-Host "Finished creating users"
