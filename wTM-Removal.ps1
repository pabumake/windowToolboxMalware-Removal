# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
    }
}

# wTM-Removal.ps1
# Authors: pabumake,luzea
# Helpers: Harromann,Zuescho,XplLiciT,Cirno,Janmm14
# Origin: SemperVideo Community Discord
# Release: 2022-04-10 16:51

$global:checkProbabilitySum = 0
$global:RiskySytem = $false

# Check for following System Paths

$winpath_systemfile = "C:\systemfile\"
$winpath_python3 = "C:\Windows\security\pywinvera"
$winpath_python3_sub = "C:\Windows\security\pywinveraa"

# Check if obs.log file exists -> Contains Encrypted Python File -> More investigation required
$filepath_crypted_python = "C:\systemfile\obs.log"

# Check for following Tasks in Sheduler
$taskpath_AppID = @('\Microsoft\Windows\AppID\','VerifiedCert')
$taskpath_ApplicationExp = @('\Microsoft\Windows\Application Experience\','Maintenance')
$taskpath_Services_0 = @('\Microsoft\Windows\Services\','CertPathCheck')
$taskpath_Services_1 = @('\Microsoft\Windows\Services\','CertPathw')
$taskpath_Servicing0 = @('\Microsoft\Windows\Servicing\','ComponentCleanup')
$taskpath_Servicing1 = @('\Microsoft\Windows\Servicing\','ServiceCleanup')
$taskpath_Shell = @('\Microsoft\Windows\Shell\','ObjectTask')
$taskpath_Clip = @('\Microsoft\Windows\Clip\','ServiceCleanup')

$knownTargets = "12"

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [String]
        $Message
    )

    process {
        if($Message.Contains('[!]')){
            Write-Host -ForegroundColor Red $Message
        } elseif($Message.Contains('[-]')){
            Write-Host -ForegroundColor Green $Message
        } elseif($Message.Contains('[?]')){
            Write-Host -ForegroundColor Yellow $Message
        } else {
            Write-Host $Message
        }
        Add-Content -Path "$PSScriptRoot\Log.txt" -Value "$(Get-Date): $Message"
    }
}

function Get-SystemPaths ($winpath){
    # Check for C:\systemfile\ 
    if (Test-Path -Path $winpath){
        Write-Log "[!] Found $winpath."
        $global:checkProbabilitySum += 1
    } else {
    Write-Log "[*] Could not find $winpath"
    }
}

function Get-FilePaths ($winpath){
    # Check for C:\systemfile\ 
    if (Test-Path -Path $winpath -PathType Leaf){
        Write-Log "[!] Found $winpath. This file could contain major Payload."
        $global:checkProbabilitySum += 1
    } else {
    Write-Log "[*] Could not find $winpath"
    }
}

function Remove-SystemPaths($winpath){
    if (Test-Path -Path $winpath){
        try{
            Write-Log "[*] Removing $winpath"
            Remove-Item -Path $winpath -Recurse -Force
        }
        catch{
            Write-Log "[!] Could not delete $winpath"
            Write-Error $_
        }
    }
}

function Get-FromSchedulerTasks ($scheduledtasks){
    $fullschedulerpath = $scheduledtasks[0] + $scheduledtasks[1]
    if(Get-ScheduledTask -TaskPath $scheduledtasks[0] -TaskName $scheduledtasks[1] -ErrorAction "SilentlyContinue"){ #| Where {$_.TaskName -eq $scheduledtasks[1]}
        $global:checkProbabilitySum += 1
        Write-Log "[!] Found $fullschedulerpath. This sums up to $global:checkProbabilitySum of $knownTargets."
    }
}

function Unregister-MalwareTasks ($scheduledtasks){
    $fullschedulerpath = $scheduledtasks[0] + $scheduledtasks[1]
    Write-Log "[*] Removing $fullschedulerpath"
    Unregister-ScheduledTask -TaskPath $scheduledtasks[0] -TaskName $scheduledtasks[1] -Confirm:$false -ErrorAction "SilentlyContinue"
}

function Get-RiskyInfectionState {
    $detectWinSystemLocale =  Get-WinSystemLocale | Select-Object -ExpandProperty Name
    if($detectWinSystemLocale -like "en-*"){
        return $true
    } else {
        return $false
    }
}

function Get-HasBeenRun{
    if(Test-Path -Path "$PSScriptRoot\HasBeenRun.txt"){
        Write-Log "[*] Running Cleanup one more time helps remove remaining bits of the Malware."
        return $true
    } else {
        Write-Log "[*] This is the first time the Script has been run."
        Add-Content -Path "$PSScriptRoot\HasBeenRun.txt" -Value "1"
        return $false
    }
}

$hasBeenRun = Get-HasBeenRun
$global:RiskySytem = Get-RiskyInfectionState

Get-SystemPaths($winpath_systemfile)
Get-SystemPaths($winpath_python3)
Get-SystemPaths($winpath_python3_sub)
Get-FilePaths($filepath_crypted_python)

Get-FromSchedulerTasks($taskpath_AppID)
Get-FromSchedulerTasks($taskpath_ApplicationExp)
Get-FromSchedulerTasks($taskpath_Services_0)
Get-FromSchedulerTasks($taskpath_Services_1)
Get-FromSchedulerTasks($taskpath_Servicing0)
Get-FromSchedulerTasks($taskpath_Servicing1)
Get-FromSchedulerTasks($taskpath_Shell)
Get-FromSchedulerTasks($taskpath_Clip)

if($hasBeenRun -eq $false){
    Write-Log "[!] System is targeted by Malware. Use Remove Option to remove bad files/tasks"
    $global:checkProbabilitySum +=1
} 
if($global:RiskySytem -eq $false){
    Write-Log "[-] System is NOT targeted by Malware. If no other files were found your probably save."
}

if($global:checkProbabilitySum -gt 0){
    if($global:RiskySytem -eq $true){
        Write-Log "[?] Your System Language equals 'en-' wich is the default Target of windowToolBox Malware."
        Write-Log "[?] If this is the only finding you are propbably save. Continue to ensure run Removal process anyway."
    } else {
        Write-Log "[?] Your System is not targetet by windowToolBox Malware. You're propbably not affected."
        Write-Log "[?] You can run the script anyways to ensure your System is not affected."
    }
    Write-Log "[!] Your System is at risk. We found $global:checkProbabilitySum of $knownTargets entrys that match windowToolboxMalware." 
    $removeMalware = Read-Host -Prompt "[*] Remove all folders and tasks connected with windowToolBox Malware? (Y/N)"
    if($removeMalware -eq "Y" -or $removeMalware -eq "y"){
        Remove-SystemPaths($winpath_systemfile)
        Remove-SystemPaths($winpath_python3)
        Remove-SystemPaths($winpath_python3_sub)
        Unregister-MalwareTasks($taskpath_AppID)
        Unregister-MalwareTasks($taskpath_ApplicationExp)
        Unregister-MalwareTasks($taskpath_Services_0)
        Unregister-MalwareTasks($taskpath_Services_1)
        Unregister-MalwareTasks($taskpath_Servicing0)
        Unregister-MalwareTasks($taskpath_Servicing1)
        Unregister-MalwareTasks($taskpath_Shell)
        Unregister-MalwareTasks($taskpath_Clip)
        # Reestablish Windows Update and corresponding Services
        Set-Service -Name wuauserv -StartupType Manual
        Set-Service -Name bits -StartupType Manual
        Set-Service -Name cryptsvc -StartupType Automatic
        if($hasBeenRun -eq $false){
            Write-Log "[!] We recommend you restart your Computer and rerun the Script to remove the remaining bits of of the Malware." 
        }
        if($hasBeenRun -eq $true){
            Write-Log "[!] To ensure everything is okay we recommend to run Windows Troubleshooting for Windows Update Services."
            Write-Log "[?] We recommend this step since the Malware seems to manipulate Windows Update Service."
            Write-Log "[?] To restore normal functioning of Windows Update this is a recommend step."
            Write-Log "[?] If you want to keep Windows Updates as Optional thats up to you."
            
        }
        Write-Log "[*] This window will close in 15 Seconds."
        Start-Sleep -Seconds 15

    }
}
else {
    Write-Log "[-] We could not find anything connected with windowToolxBox Malware. Recheck for new Version of this Script later."
    Write-Log "[*] This window will close in 10 Seconds."
    Start-Sleep -Seconds 10
}