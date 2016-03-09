<#
.SYNOPSIS
A set of custom functions to make my work more manageable.

#>
Clear;

Function Get-DiskUtil {
Param([string] $Computername = $env:computername)
Process {
If ($_) {$Computername = $_}
Get-WmiObject win32_Volume -Filter "drivetype=3" -ComputerName $ComputerName -EA SilentlyContinue |`
Select-Object @{Name= "ComputerName";Expression={$_.SystemName}},Name,
@{Name="SizeGB:";Expression={"{0:N2}" -f ($_.Capacity/1GB)}},
@{Name="FreeGB:";Expression={"{0:N2}" -f ($_.Freespace/1GB)}},
@{Name="UsedGB:";Expression={"{0:N2}" -f (($_.Capacity-$_.Freespace)/1GB)}},
@{Name="Perfree:";Expression={"{0:P2}" -f ($_.Freespace/$_.Capacity)}},
@{Name="Defrag?";Expression={$_.DefragAnalysis().DefragRecommended}}
}
}

Function Get-ServicePack {
Param([string]$ComputerName=$env:COMPUTERNAME)
Process{
if ($_) {$Computername=$_}
Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computername -EA SilentlyContinue |`
Select-Object @{Name="ComputerName";Expression={$_.CSName}}, 
@{Name="OperatingSystem";Expression={$_.Caption}},
@{Name="SPName";Expression={$_.ServicePackMajorVersion}}
}
}

Function Get-ShutdownEvent {
Param([string] $Computername=$env:computername,$OldestEvent=30 )
Process{
if ($_) {$Computername=$_}
$days = ($OldestEvent * -1)
$Oldestdate = (Get-Date).AddDays($days)
Get-WinEvent System -EA SilentlyContinue -ComputerName $Computername |`
Where-Object {$_.id -eq "1074" -or $_.id -eq"6008" -and $_.TimeCreated -ge $Oldestdate}|`
Select TimeCreated, Id, MachineName, Message, UserID, UserName |`
ForEach-Object {
$objSID = New-Object System.Security.Principal.SecurityIdentifier `
    ($_.UserID)
$objUser = ($objSID).Translate([System.Security.Principal.NTAccount])
$_.UserName = $objUser.Value
$_
}
}
}

Function Get-PatchList {
Param (
[string] $Computername=$env:computername, $oldest=180
)
Process {
$OldestUpdate = ($oldest * -1)
$date = (Get-Date).AddDays($OldestUpdate)
if ($_) {$Computername=$_}
$Criteria="Type='Software' and IsInstalled=0"
$UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$Computername))
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
$UpdateResults = $UpdateSearcher.Search($Criteria)
$Update = $UpdateResults.Updates
$Update | Select-Object @{Name="PublishedDate"; Expression={$_.LastDeploymentchangetime}},
@{Name="KBArticleID";Expression={$_.KBArticleIDs}},Title,
MsrcSeverity,Description, RebootRequired
}
}

Function Get-SystemInfo {
Param([string]$ComputerName=$env:COMPUTERNAME)
Process{
if ($_) {$Computername=$_}
$Bios = Get-WmiObject win32_Bios -ComputerName $ComputerName
$PcInfo = Get-WmiObject win32_ComputerSystem -ComputerName $ComputerName
$OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName
$NetInfo = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $ComputerName | Where-Object {$_.DefaultIPGateway -ne $null}
#$DisplayInfo = Get-WmiObject
                    
$ComputerInfo = New-Object PSObject
$ComputerInfo | Add-Member NoteProperty ComputerName -Value $PcInfo.name
$ComputerInfo | Add-Member NoteProperty UserName -Value $PcInfo.UserName
$ComputerInfo | Add-Member NoteProperty OS -Value $OSInfo.Caption
$ComputerInfo | Add-Member NoteProperty Architecture -Value $OSInfo.OSArchitecture
$ComputerInfo | Add-Member NoteProperty Manufacturer -Value $PcInfo.Manufacturer
$ComputerInfo | Add-Member NoteProperty Model -Value $PcInfo.model
$ComputerInfo | Add-Member NoteProperty SerialNumber -Value $Bios.SerialNumber
$ComputerInfo | Add-Member NoteProperty BiosVersion -Value $Bios.SMBIOSBIOSVersion
$ComputerInfo | Add-Member NoteProperty IPAddress -Value $NetInfo.IPAddress
$ComputerInfo | Add-Member NoteProperty IPGateway -Value $NetInfo.DefaultIPGateway
$ComputerInfo | Add-Member NoteProperty MacAddress -Value $NetInfo.MACAddress

$ComputerInfo
}
}

Function Get-IeVersion {
Param([string]$computer = $env:COMPUTERNAME)
Process {
If ($_) {$Computer = $_}
$hklm = 2147483650
$key = "SOFTWARE\Microsoft\Internet Explorer"
$value = "Version"
$wmi = [wmiclass]"\\$computer\root\default:stdRegProv"
$User = Get-WmiObject Win32_ComputerSystem -ComputerName $computer
$IeInfo = New-Object PSObject
$IeInfo | Add-Member NoteProperty ComputerName -Value $Computer
$IeInfo | Add-Member NoteProperty "IE Version" -Value ($wmi.GetStringValue($hklm,$key,$value)).svalue
$IeInfo | Add-Member NoteProperty UserName -Value ($User).UserName
$IeInfo
}
}

Function Set-TimeStamp {
Param (

    [Parameter(mandatory=$true)]
    [string[]]$path,
    [datetime]$date = (Get-Date)
	)
	  Get-ChildItem -Path $path |
    ForEach-Object {
     $_.CreationTime = $date
     $_.LastAccessTime = $date
     $_.LastWriteTime = $date }
} #end function Set-FileTimeStamps

Function Get-SoftwareList {
get-childitem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" | foreach { get-ItemProperty $_.PSPath } |`
Where-Object { $_.URLInfoAbout -notmatch "support.microsoft.com" -and $_.DisplayName -ne $null } |`
Sort-Object DisplayName  | Format-table DisplayName,Version, Publisher,InstallDate, URLInfoAbout

}

function Get-FolderSize {
 param([string] $RootFolder = "c:\",
    [string] $foldersize = "1000")
    Process {
        $fso = New-Object -ComObject scripting.filesystemobject
    If ($_){$Rootfolder = $_}

    $folders = foreach($folder in (Get-ChildItem $RootFolder -Directory -Recurse -EA SilentlyContinue)){
         New-Object -TypeName psobject -Property @{
                name=$fso.GetFolder($folder.FullName.ToString()).path;
                size=[int]($fso.GetFolder($folder.FullName.ToString()).size /1MB)
            }
        }
$folders | Where-Object{$_.size -ge $foldersize}

    }
    
}


Function Get-AntiVirusVersion {
Param([string]$ComputerName = $env:COMPUTERNAME)
Process {
        if($_) {$ComputerName= $_}

        $Software = Get-WmiObject Win32_Product -ComputerName $ComputerName | Where-Object {$_.Name -like "*Symantec*" -or  $_.Name -like "*McAfee*"} 
        $SEPInfo = New-Object PSObject
        $SEPInfo | Add-Member NoteProperty ComputerName -Value $ComputerName
        $SEPInfo | Add-Member NoteProperty SoftWareName -Value $Software.Name
        $SEPInfo | Add-Member NoteProperty Version  -Value $Software.Version
        $SEPInfo
    }

}


Function Get-DriveHealth {
Param([string] $ComputerName = $env:COMPUTERNAME)
Process {
        if($_) {$ComputerName= $_}
        $drives = Get-WmiObject win32_diskdrive -ComputerName $ComputerName
        foreach($drive in $drives) 
            {

            $DriveStatus = New-Object PSObject
            $DriveStatus | Add-Member NoteProperty ComputerName -Value $drive.PSComputerName
            $DriveStatus | Add-Member NoteProperty DeviceID -Value $drive.deviceid
            $DriveStatus | Add-Member NoteProperty Model -Value $drive.model 
            $DriveStatus | Add-Member NoteProperty InterfaceType -Value $drive.InterfaceType
            $DriveStatus | Add-Member NoteProperty Status -Value $drive.status
            $DriveStatus | Add-Member NoteProperty "Size(GB)" -Value ($drive.Size / 1GB).ToString("#.##")
            $DriveStatus | Add-Member NoteProperty Serial -Value $drive.serialnumber
            $DriveStatus
       }
    }
}


Function Get-Computerlist {
    $Computerlist = @()
    $obj = (Net view)
    $max = ($obj.count) -3
    $obj[3..$Max] | foreach -Process{
        $Computerlist += (($_ -split '\\')[2] -split "\s")[0]
    }

 $Computerlist
 }