function menu($option){
    
    Write-Host "#--------------------------------#"
    Write-Host "|        Choose an Option        |"
    Write-Host "| 1.- Add host to a Domain.      |"
    Write-Host "| 2.- Basic setup configuration. |"
    Write-Host "| 3.- Exit                       |"
    Write-Host "#--------------------------------#"
    $option = Read-Host -Prompt 'Insert your option '
    return $option
}

Function Add-ComputerToDomain(){ 
   <# Param( 
      [string]$DomainAccountName = $(throw "Parameter missing: -DomainAccountName DomainAccountName"),  
      [string]$DomainAccountPassword =$(throw "Parameter missing: -DomainAccountPassword DomainAccountPassword"), 
      [string]$DomainName =$(throw "Parameter missing: -DomainName DomainName"), 
      [string]$NewComputerName =$(throw "Parameter missing: -NewComputerName ComputerName"),
      [string]$OU =$(throw "Parameter missing: -OU Path")   
    )#> 
    Try{
        $DomainAccountName = Read-Host -Prompt 'Account Username: '
        $DomainAccountPassword = Read-Host -Prompt 'Account Password: '
        $DomainName = Read-Host -Prompt 'Domain Name: '
        $NewComputerName = Read-Host -Prompt 'New Computer Name: '
        $OU = "OU=Domain Computers,DC=unolabs,DC=com" #Read-Host -Prompt 'OU Path: '
        #$str = "-DomainAccountName $DomainAccountName -DomainAccountPassword $DomainAccountPassword -DomainName $DomainName -NewComputerName $NewComputerName -OU $OU"
        #Write-Host($str)
         
        $credentials = New-Object System.Management.Automation.PsCredential($DomainAccountName, (ConvertTo-SecureString $DomainAccountPassword -AsPlainText -Force))
        write-Host "Adding $computername to the $DomainName to the path $OU" 
        Add-Computer -DomainName $DomainName -Credential $credentials -OUPath $OU -ErrorAction Stop
        Rename-Computer -NewName $NewComputerName -DomainCredential $credentials -Force -ErrorAction Stop  
        Restart-Computer -ErrorAction Stop 

    } 
    Catch { 
        Write-Host -ForegroundColor Red $Displayname $_.Exception.Message 
    } 
} 

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
 
# Run your code that needs to be elevated here
$sw = menu

switch($sw){
    
    1{
        if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain){
            Write-Host -ForegroundColor Red ("The computer is already part of a Domain.")
        }
        else{
            Write-Host("Add host to a Domain selected")
            Add-ComputerToDomain
        }
    }

    2{
        if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain){
            Write-Host("Basic setup configuration selected.")
            Set-NetFirewallProfile -Name Domain -DefaultInboundAction Allow
            Set-NetFirewallProfile -Name Private -DefaultInboundAction Allow
            Set-NetFirewallProfile -Name Public -DefaultInboundAction Allow
            gpupdate /force  
        }
        else{
            Write-Host -ForegroundColor Red ("You haven't join the computer to the Domain.")  
        }
    }
}
Write-Host -NoNewLine "Press any key to continue..."

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


