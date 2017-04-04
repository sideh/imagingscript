#Make this script run
#powershell.exe -ExecutionPolicy bypass -NoLogo -WindowStyle Maximized -File "Installprintersv6.ps1" -NoExit

#Message to User
Write-Host "*********************************************"
Write-Host "Make sure this is Running As Administrator"
Write-Host "Ensure this is connect to the network"
Write-Host "*********************************************"
Write-Host ""
Write-Host "This script will attempt to Change the PC Name, Join a Domain and connect network Printers"
Write-Host ""
Write-Host "Testing is focusing in these areas:"
Write-Host "1. Installing Google Drive, Chrome, Java and WinRAR"
Write-Host "2. Installing Adobe Reader DC"
Write-Host "3. Making the AD user a local administrator"
Write-Host ""
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#Get Domain and User Details
Write-Host "Getting Domain Server details"
$server1 = $Host.ui.PromptForCredential("Need Domain Administrator Details", "Please enter your user Domain\Username and password for the Domain.", "", "Username")
Write-Host "Getting Local Administrator Login Credentials"
$ladmin = $Host.ui.PromptForCredential("Need eduSTAR Administrator Login", "Please enter your user name and password for the Local Admin.", "", "Username")
$pcname = Read-Host -Prompt "Enter New Computer Name"
$domain = Read-Host -Prompt "Enter Domain to Join"

#Subtracting the start of the PC Name to leave just their TO number.
$user = $pcname.Substring(4)

#Authenticate to Print Server, testing second one as the first one seems to do jack.
#net use \\7395-app06 /USER:$domain\$server1 -savecred 
net use \\7395-app06 /USER:$server1 /persistent:no

#Add new ones and set one (Black) as default
Write-Host "Installing CPR-BLACK"
Add-Printer -ConnectionName \\7395-app06\CPR-BLACK -DriverName KONICA MINOLTA C652 PS Mono
Write-Host "CPR-BLACK is now Installed"
Write-Host ""
Write-Host "Installing CPR-COLOUR"
Add-Printer -ConnectionName \\7395-app06\CPR-COLOUR -DriverName KONICA MINOLTA C652 PS Mono
Write-Host "CPR-COLOUR is now Installed"
Write-Host ""
Write-Host "Setting CPR-BLACK as default"
(New-Object -ComObject WScript.Network).SetDefaultPrinter('\\7395-app06\CPR-BLACK')
Write-Host "CPR-BLACK is now the defualt printer"
Write-Host ""

#Triggering Sonar
Write-Host "Authenticating to Proxy Server, Resuming in 20 Seconds"
Start-Process "iexplore.exe" "go/" -WindowStyle Normal
Start-Sleep -Seconds 20

#Install Chrome, Google Drive, Java and WinRAR
Write-Host "Installing Google Drive, Chrome, Java and WinRAR"
Start-Process -FilePath "NiniteInstaller.exe" -Wait
Write-Host "Google Drive, Chrome, Java and WinRAR are now installed"
Write-Host ""

#Install Adobe Reader DC
Write-Host "Installing Adobe Reader DC"
Start-Process -FilePath "AcroRdrDC1501720050_en_US.exe" /s -Wait
Write-Host "Adobe Reader DC is now installed"
Write-Host ""

#Install paper-cut, hopefully silently
Write-Host "Installing Paper-Cut Client"
Start-Process -FilePath "client-local-install.exe" -WorkingDirectory "\\7395-app06\PCClient\win" /s -Wait
Write-Host "Paper-Cut is now installed"
Write-Host "If the script stops here, it's due to PCClient being opened. Wont continue until that is exited."
Write-Host ""

#Join Domain and Rename PC
Write-Host "Joining $domain and renaming this PC to $pcname"
Add-Computer -DomainName $domain -NewName $pcname -Credential $server1
Write-Host "Please Restart for changes to take effect."
Write-Host ""

#Add User as Administrator
Write-Host "Adding AD User to the Administrators Group on $pcname"
net localgroup “Administrators” $domain\$user /add
Write-Host ""

#To keep the window open so we can check for any errors or just to see the time/effort saved! XD
Write-Host "Script is complete, How did it go?"
Read-Host -Prompt "Press Enter to Restart Windows"
Restart-Computer 