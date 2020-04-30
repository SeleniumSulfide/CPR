#region VSphere

function Wait-ForPowerState
{
    param
    (
        [Parameter(Mandatory = $true)]$VMName,
        [Parameter(Mandatory = $false)]$PowerState,
        [Parameter(Mandatory = $false)]$TimeOutSeconds=300
    )
    
    $VM = get-vm -Name $VMName
    $Time = 0
    while ($VM.Powerstate -NE $PowerState -and $Time -lt $TimeOutSeconds)
    {
        Write-Progress -Id 1 -ParentId 0 -Activity "Checking Power Status of $VMName" -Status "Waiting for $PowerState" -PercentComplete ($Time/$TimeOutSeconds*100)
        Start-Sleep -Seconds 5
        $VM = get-vm -Name $VMName
        $Time += 5
    }
    
    Write-Progress -ID 1 -Completed -Activity "Check Power Status of $VMName"

    if ($Time -ge $TimeOutSeconds)
    {
        return $false
    }
    else
    {
        return $true
    }
}

function Wait-ForVMTools
{
    param
    (
        [Parameter(Mandatory = $true)][String]$VMName,
        [Parameter(Mandatory = $true)][String]$ToolStatus,
        [Parameter(Mandatory = $false)]$TimeOutSeconds=300
    )
        
    [VMware.VIM.VirtualMachine]$VMView = Get-VM $VMName | Get-View
    $Time = 0
    while ($VMView.Guest.ToolsStatus -ne $ToolStatus -and $Time -lt $TimeOutSeconds)
    {
        Write-Progress -Id 1 -ParentId 0 -Activity "Checking Boot Status of $VMName" -Status "Status: Waiting" -PercentComplete ($Time/$TimeOutSeconds*100)
        Start-Sleep -Seconds 5
        [VMware.VIM.VirtualMachine]$VMView = Get-VM -Name $VMName | Get-View
        $Time += 5
    }
    
    Write-Progress -ID 1 -ParentId 0 -Completed -Activity "Checking Boot Status of $VMName"

    if ($Time -ge $TimeOutSeconds)
    {
        return $false
    }
    else
    {
        return $true
    }
}

function Set-PowerState
{
    param
    (
        [Parameter(Mandatory = $true)][String]$VMName,
        [Parameter(Mandatory = $true)][Boolean]$Power
    )
    $VM = get-vm $VMName
    [VMware.VIM.VirtualMachine]$VMView = Get-VM $VMName | Get-View
    if ($Power -and $VM.PowerState -ne "PowerdOn")
    {
        Start-VM $VM
        $Status = Wait-ForPowerState -VMName $VMName -PowerState "PoweredOn"
    }

    if (!($Power) -and $VM.Powerstate -eq "PoweredOn")
    {
        $VMView.ShutdownGuest()
        $Status = Wait-ForPowerState -VMName $VMName -PowerState "PoweredOff"
    }

    Return $Status
}

#endregion VSphere


#region VMInteraction
function Unlock-VM
{
    param
    (
        [Parameter(Mandatory = $false)][String]$VMName = $global:VMName,
        [Parameter(Mandatory = $false)][String]$User = $global:VMUser,
        [Parameter(Mandatory = $false)][String]$Pass = $global:VMPass,
        [Parameter(Mandatory = $false)][boolean]$SendUser = $global:SendUser
    )
    [VMware.Vim.VirtualMachine]$VMView = Get-VM $VMName | Get-View

    Send-CtrlAltDel $VMView

    Start-Sleep -Seconds 1
    if ($SendUser)
    {
        Send-VMKeys -VM $VMView -StringInput $User -SpecialKeyInput "TAB"
    }

    Send-VMKeys -VM $VMView -StringInput $Pass -SpecialKeyInput "Enter"
}

function Set-VMPowerOn
{
    param
    (
        [Parameter(Mandatory = $true)][String]$VMName
    )

    Set-Powerstate -VMName $VMName -Power $True
    Wait-ForVMTools -VMName $VMName -ToolStatus "toolsOK"
}

function Set-VMPowerOFf
{
    param
    (
        [Parameter(Mandatory = $false)][String]$VMName = $global:VMName,
        [Parameter(Mandatory = $false)][Boolean]$Force = $false
    )

    if (!($Force))
    {
        Set-PowerState -VMName $VMName -Power $false
    }
    else 
    {
        Get-VM -Name $VMName | Stop-VM    
    }
}

function Restart-VM
{
    param
    (
        [Parameter(Mandatory = $false)][String]$VMName = $global:VMName,
        [Parameter(Mandatory = $false)][String]$User = $global:VMUser,
        [Parameter(Mandatory = $false)][String]$Pass = $global:VMPass,
        [Parameter(Mandatory = $false)][boolean]$SendUser = $global:SendUser
    )
    [VMware.Vim.VirtualMachine]$VMView = Get-VM $VMName | Get-View
    $VMView.RebootGuest()
    Wait-ForVmTools -VMName $VMName -ToolStatus "toolsNotRunning"
    Wait-ForVMTools -VMName $VMName -ToolStatus "toolsOK"
    Unlock-VM -VMName $VMName -User $User -Pass $Pass -SendUser $SendUser
}

function Send-CtrlAltDel
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][VMware.VIM.VirtualMachine]$VM
    )
    
    Send-VMKeys -VM $VM -LeftControl $True -LeftAlt $True -SpecialKeyInput "DEL"
}


function Start-CMD
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][VMware.VIM.VirtualMachine]$VM
    )
    
    Send-VMKeys -VM $VM -String "r" -LeftGUI $True
    Send-VMKeys -VM $VM -String "cmd" -SpecialKeyInput "Enter"
}

function Set-VMToLatestSnap
{
    param
    (
        [Parameter(Mandatory = $true)]$VMName
    )
    
    $Snap = $(Get-VM $VMName | Get-Snapshot)[-1]
    Set-VM -VM $Snap.VM -Snapshot $Snap -Confirm:$false
}

function Get-VMAdminShare #Returns Share Object
{
    param
    (
        [Parameter(Mandatory = $true)][String]$VMName,
        [Parameter(Mandatory = $true)][PSCredential]$VMCred
    )

    $IP = $(get-vm $VMName).guest.IPAddress
    $Root = "\\$IP\c$"
    $Drive = New-PSDrive -name $VMName -PSProvider Filesystem -Root $Root -Credential $VMCred
    return $Drive
}

function Add-Path
{
    Param
    (
        [Parameter(Mandatory = $true)][String]$Root,
        [Parameter(Mandatory = $true)][String]$Path
    )

    If ($Root -eq $path) { return $false }

    $Parent = Split-Path $Path -Parent

    if (!(Test-Path $Parent)) 
    {
        Write-Host "Did not find $Parent"
        $Parent = Add-Path $Root $Parent 
    } 
    else 
    { 
        $Parent = $true 
    }

    If ($Parent -and !(Test-Path $Path)) 
    { 
        Write-Host "Creating $Path"
        New-Item $Path -ItemType Directory | out-null
    }

    if ((Test-Path $Path)) 
    { 
        Write-Host "Found $Path"
        return $true 
    } 
    else 
    { 
        Write-Host "Did not find $Path"
        return $false 
    }
}

function Set-VMStatus
{
    Param
    (
        [Parameter(Mandatory = $true)][String]$Status,
        [Parameter(Mandatory = $false)][String]$file = $global:StatusFile
    )

    Set-Content $File $Status
}

function Set-VMAction
{
    Param
    (
        [Parameter(Mandatory = $true)][String]$Action,
        [Parameter(Mandatory = $false)][String]$file = $global:ActionFile
    )

    Set-Content $File $Action
}

function Get-VMStatus
{
    Param
    (
        
        [Parameter(Mandatory = $false)][String]$file = $global:StatusFile
    )

    Get-Content $File
}


function Get-VMAction
{
    Param
    (
        
        [Parameter(Mandatory = $false)][String]$file = $global:ActionFile
    )

    Get-Content $File
}

function Watch-VM
{
    Param
    (
        [Parameter(Mandatory = $false)][String]$StatusFile = $global:StatusFile,
        [Parameter(Mandatory = $false)][String]$ActionFile = $global:ActionFile
    ) 

    do 
    {
        $Status = Get-VMStatus $StatusFiles
        $Action = Get-VMAction $ActionFile

        Switch ($Action)
        {
            "Reboot"
                {
                    Restart-VM
                }
        }

    } while ($status -ne "Exit")
}
#endregion VMInteraction

#region WindowsUpdates
function Get-Updates
{
    Param(
        [Parameter()]$Session,
        [Parameter()]$Drivers=$false,
        [Parameter()]$logFile)
    #$Session = New-Object -ComObject Microsoft.Update.Session
               
    $Searcher = $Session.CreateUpdateSearcher()
    if (!($Drivers))
    {
        add-content $logfile "Searching for Windows Updates"
        #$searcher.serviceid = '9482f4b4-e343-43b6-b170-9a65bc822c77'
        $Criteria = "IsInstalled=0"
    }
    else
    {
        add-content $logfile "Searching for Driver Updates"
        $Searcher.ServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
        $Searcher.SearchScope =  1 # MachineOnly
        $Searcher.ServerSelection = 3 # Third Party
        $Criteria = "IsInstalled=0 and Type='Driver'"        
    }

    $SearchResult = $Searcher.Search($Criteria)
    $Updates = $SearchResult.Updates
    
    return , $Updates
}

function Sync-Updates
{
    Param(
        [Parameter()]$Updates,
        [Parameter()]$Session,
        [Parameter()]$logFile)

    add-content $logfile "Creating list of updates to download"
    $UpdatesToDownload = New-Object -Com Microsoft.Update.UpdateColl
    $updates | ForEach-Object { $UpdatesToDownload.Add($_) | out-null }
    
    add-content $logfile "Creating Update Download"
    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $UpdatesToDownload
    
    add-content $logfile "Downloading Updates"
    $Downloader.Download() | out-file $logFile -Append
}

function Install-Updates
{
    Param(
        [Parameter()]$Updates,
        [Parameter()]$Session,
        [Parameter()]$logFile)

    $UpdatesToInstall = New-Object -Com Microsoft.Update.UpdateColl
    $updates | ForEach-Object { if($_.IsDownloaded) { $UpdatesToInstall.Add($_) | out-null } }
    add-content $logfile "Updates to install:  $($Updates.Count())"

    add-content $logfile "Installing Updates"
    $Installer = $Session.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
    $InstallationResult = $Installer.Install()
    add-content $logfile "Installation Result:  $($InstallationResult.GetUpdateResult())"
    return $InstallationResult.RebootRequired
}

function Update-Windows
{
    Param(
        [Parameter()]$logFile)


    Set-VMStatus -Status "Creating Update Session"
    $Session = New-Object -Com Microsoft.Update.Session

    Set-VMStatus -Status "Beginning Windows Updates"
    $Updates = Get-Updates $Session $False $logFile

    if ($updates.count -eq 0)
    {
        add-content $logFile "No Windows Updates Found"
        Set-VMStatus -Status ""
        $WURestart = $false
    }
    else
    {
        Set-VMStatus -Status "Windows Updates Found"
        Sync-Updates $Updates $Session
        $WURestart = Install-Updates $Updates $Session $logFile
    }

    if ($WURestart)
    {
        Set-VMStatus -Status "Restarting..."
        Set-VMAction -Action "Reboot"
    }
}

#endregion WindowsUpdates