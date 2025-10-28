# Parámetros
param (
    [string]$DomainName = "infobatoi23.lan",
    [string]$BaseOU = "OU=Usuarios,DC=yourdomain,DC=com",
    [string]$PersonalFolderPath = "\\server\personal\%USERNAME%",
    [string]$BasePathMovil = "\\server\movil\%USERNAME%",
    [string]$BasePathObligatorio = "\\server\movil_obligatorio",
    [string]$DefaultPassword = "_admin1234",
    [string]$ObligatorioGroupName = "Grupo_Obligatorio"
)

Import-Module ActiveDirectory

# Verificar si el grupo "Grupo_Obligatorio" existe, si no, crearlo
if (-not (Get-ADGroup -Filter {Name -eq $ObligatorioGroupName} -ErrorAction SilentlyContinue)) {
    New-ADGroup -Name $ObligatorioGroupName -GroupScope Global -GroupCategory Security -Path $BaseOU -Description "Grupo para usuarios de perfil obligatorio"
    Write-Host "Grupo '$ObligatorioGroupName' creado."
}

# Leer el archivo CSV
$usuarios = Import-Csv -Path "usuarios.csv"

# Restricciones de horario (Gestió)
$HorarioGestion = "8:00-14:00"
$DiasGestion = "1-5"  # 1=Lunes, 5=Viernes (según Windows)

# Nombres de equipos del Taller (modificar con los definitivos)
$EquiposTaller = @("Taller01", "Taller02", "Taller03")

foreach ($usuario in $usuarios) {
    $OU = "OU=$($usuario.departament),$BaseOU"
    $FullName = "$($usuario.nom) $($usuario.cognom1) $($usuario.cognom2)"
    $UserName = $usuario.usuari
    $PathPerf = $null

    $PathPersonalFolder = $PersonalFolderPath -replace "%USERNAME%", $UserName
    # Crear la carpeta personal si no existe
    if (-not (Test-Path $PathPersonalFolder)) {
        New-Item -Path $PathPersonalFolder -Type Directory
    }

    # Determinar las rutas según el tipo de perfil
    if ($usuario.Tipo_Perfil -eq "movil") {
        $PathPerf = $BasePathMovil -replace "%USERNAME%", $UserName
    } elseif ($usuario.Tipo_Perfil -eq "obligatori") {
        $PathPerf = $BasePathObligatorio
    }

    # Verificar si el usuario ya existe
    if (Get-ADUser -Filter {SamAccountName -eq $UserName} -ErrorAction SilentlyContinue) {
        Write-Host "$UserName ya existe"
    } else {
        $UserParams = @{
            Name              = $UserName
            SamAccountName    = $UserName
            UserPrincipalName = "$UserName@$DomainName"
            GivenName         = $usuario.nom
            Surname           = "$($usuario.cognom1) $($usuario.cognom2)"
            AccountPassword   = (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force)
            Path              = $OU
            Enabled           = $true
        }

        # Asignar directorios si es necesario
        if ($PathPersonalFolder) {
            $UserParams['HomeDirectory'] = $PathPersonalFolder
            $UserParams['HomeDrive'] = "T:"
        }

        if ($PathPerf) {
            $UserParams['ProfilePath'] = $PathPerf
        }

        # Crear el grupo del departamento si no existe
        $DepartmentGroupName = "usuario.$($usuario.departament)"
        if (-not (Get-ADGroup -Filter {Name -eq $DepartmentGroupName} -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $DepartmentGroupName -GroupScope Global -Path $BaseOU -Description "Grupo de usuarios para el departamento $($usuario.departament)"
            Write-Host "Grupo '$DepartmentGroupName' creado."
        }

        # Crear el usuario
        New-ADUser @UserParams
        Write-Host "Usuario $UserName creado en $OU"

        # Añadir al grupo del departamento
        Add-ADGroupMember -Identity $DepartmentGroupName -Members $UserName
        Write-Host "$UserName añadido al grupo '$DepartmentGroupName'."

        # Si es perfil obligatorio, añadir al grupo "Grupo_Obligatorio"
        if ($usuario.Tipo_Perfil -eq "obligatori") {
            Add-ADGroupMember -Identity $ObligatorioGroupName -Members $UserName
            Write-Host "$UserName añadido al grupo '$ObligatorioGroupName'."
        }

        # Configurar contraseña y política de cambio
        Set-ADUser -Identity $UserName -ChangePasswordAtLogon $false

        Write-Host "$UserName creado con carpeta $PathPersonalFolder y perfil $usuario.Tipo_Perfil"

        # Configurar restricciones
        if ($usuario.departament -eq "Gestio") {
            # Aplicar restricciones de horario para Gestió
            $LogonHours = (New-Object int[] 21) # 21 bytes (7 días x 3 bytes por día)
            for ($i = 0; $i -lt 21; $i++) { $LogonHours[$i] = 0 } # Inicializa todo a 0
            # Llenar las horas de lunes a viernes (Días 1-5)
            for ($day = 1; $day -le 5; $day++) {
                $startHour = 8 * 2    # Hora de inicio en intervalos de 30 minutos
                $endHour = 14 * 2     # Hora final en intervalos de 30 minutos
                for ($hour = $startHour; $hour -lt $endHour; $hour++) {
                    $byteIndex = [math]::Floor($hour / 8)
                    $bitIndex = $hour % 8
                    $LogonHours[($day * 3) + $byteIndex] = $LogonHours[($day * 3) + $byteIndex] -bor (1 -shl $bitIndex)
                }
            }
            Set-ADUser -Identity $UserName -LogonHours $LogonHours
            Write-Host "Horario de inicio de sesión configurado para $UserName"
        } elseif ($usuario.departament -eq "Taller") {
            # Aplicar restricciones a equipos específicos
            $Workstations = ($EquiposTaller -join ",")
            Set-ADUser -Identity $UserName -LogonWorkstations $Workstations
            Write-Host "Restricción de equipos configurada para $UserName"
        }
    }
}

