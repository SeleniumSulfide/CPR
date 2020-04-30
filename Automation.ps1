
$i = 0

$i++
Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Collecting VM User/Password"


########## Collecting necessary credentials ##########

$PassVMUser = $false #Set this to true if you need to enter the user name or false if the login process only asks for password
$VMName = "cwm-lcbase-03"
$VMServer = "cpv-horizonvcsa.fhlbi.com"
do
{
    $VMUser = "$VMName\$(Read-Host -Prompt "Please enter the local username")"
} while ($VMUser -eq "")

do
{
    $VMPass = Read-Host -Prompt "Please enter the local password"
} while ($VMPass -eq "")


$VMPassEnc = ConvertTo-SecureString $VMPass -AsPlainText -Force
[pscredential]$VMCred = New-Object System.Management.Automation.PSCredential($VMUser, $VMPassEnc)

$VSphereCred = Get-Credential -Message "Please enter the Credentials for connecting to VSphere"



########## Connect to VSphere and start VM ##########

$i++
Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Connecting to $VMServer"
Connect-VIServer -Server $VMServer -Credential $VSphereCred

$i++
Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Powering on $VMName"
Set-PowerState -VMName $VMName -Power $True
Wait-ForVMTools -VMName $VMName -ToolStatus "toolsOK"

$i++
for ($time=0; $time -lt 60; $time++)
{
    Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Waiting 60s for Machine to finish booting" -PercentComplete ($time/60*100)
    start-sleep 1
}`

$i++
Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Logging in to $VMName as $VMUser"
if ($PassVMUser)
{
    Unlock-VM -VMName $VMName -User $VMUser -Pass $VMPass
}
else
{
    Unlock-VM -VMName $VMName -Pass $VMPass
}


########## Upload Files ##########

[System.Management.Automation.PSDriveInfo]$VMDrive = Get-VMAdminShare -VMName $VMName -VMCred $VMCred
ForEach ($file in $FileManifest.FilesToUpload.File)
{
    $Source = "$($file.Source)\$($file.Name)"
    $Destination = "$($VMDrive.Root)\$($file.Dest)"

    if ((Add-Path $VMDrive.Root $Destination))
    {
        Copy-Item -Path $Source -Destination $Destination
    }
}



$i++
for ($time=0; $time -lt 60; $time++)
{
    Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Waiting 60s for desktop" -PercentComplete ($time/60*100)
    start-sleep 1
}



$i++
Write-Progress -ID 0 -Activity "Updating VM" -CurrentOperation "Step $i - Beginning Windows Updates"
Get-VM -Name $VMName | Get-View | Start-CMD
start-sleep -Seconds 1
Get-VM -Name $VMname | Get-View | Send-VMKeys -StringInput "powershell c:\temp\windowsupdatev2.ps1" -SpecialKeyInput "Enter"

#Set-PowerState -VMName $VMName -Power $False
#Revert-ToLatestSnap $VMName