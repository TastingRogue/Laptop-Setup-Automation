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
        }
        else{
            Write-Host -ForegroundColor Red ("You haven't join the computer to the Domain.")  
        }
    }
}