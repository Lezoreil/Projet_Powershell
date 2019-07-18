#############################################
# 	Title 	: 	Script_creat_VM_to_ESXi		#
#	Date  	:	08/04/2019					#
#	Version : 	1							#
#	Autor 	: 	Vincent GRATEAU				#
#############################################

#Import-Module -Name DnsServer
#Import-Module -Name ActiveDirectory
Import-Module VMware.VimAutomation.Core
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#								  		PATH FILES							  		   #
$path_log = "C:\Users\Administrator\Desktop\projet_powershell\result.log"
$path_csv = "C:\Users\Administrator\Desktop\projet_powershell\file.csv"
$path_portgroup_csv = "C:\Users\Administrator\Desktop\projet_powershell\portgroup.csv"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#								  		MAIL LIST							  		   #
$mail_target = "vgrateau@myges.fr"
$mail_serv = "vgrateau@outlook.com"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


$address_serveur = "10.1.1.10"
$address_esxi1 = "10.1.1.11"

$login = "root"
$password = "Root1!Root1!"
$Total_VM_creat_sucess = 0
$Total_VM_creat_err = 0

#Connection to Vcenter
Connect-VIServer $address_serveur -User $login -Password $password

function Send_Mail_fct($body,$subject)
{
	$password_mail = "Root1!Root1!Root1!"
    $SMTPServer = "smtp.office365.com"
    $SMTPPort = "587"
	$secpasswd = ConvertTo-SecureString "Root1!Root1!Root1!" -AsPlainText -Force
	$Credential_mail = New-Object System.Management.Automation.PSCredential($mail_serv,$secpasswd)
    $encodingMail = [System.Text.Encoding]::UTF8	
	
    Send-MailMessage -From $mail_serv -to $mail_target -Subject $subject -BodyAsHTML $body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credential_mail -Attachments $path_log -Encoding $encodingMail

}

function White_to_Log_Complet_fct($VM_State, $path_log,$info_VM)
{
    $NameVM = $line_csv.Name
	$Datastore = $line_csv.Datastore
	$GuestID = $line_csv.GuestID
	$NumCPU = $line_csv.NumCPU
	$CoresPerSocket = $line_csv.CoresPerSocket
	$MemoryMB = $line_csv.MemoryMB
	$DiskMB = $line_csv.DiskMB
	$DiskStorageFormat = $line_csv.DiskStorageFormat
	$NetworkName = $line_csv.NetworkName
	$Notes = $line_csv.Notes

	$Date_Action_VM = Get-Date
     
	Add-Content $path_log -Value " "
    Add-Content $path_log -Value $Date_Action_VM
    Add-Content $path_log -Value $VM_State
    Add-Content $path_log -Value " - - - - - - - - - - - - - - - - - - - -"
    Add-Content $path_log -Value " |   Name                >>> $NameVM"
    Add-Content $path_log -Value " |   Datastore           >>> $Datastore"
    Add-Content $path_log -Value " |   GuestID             >>> $GuestID"
    Add-Content $path_log -Value " |   NumCPU              >>> $NumCPU"
    Add-Content $path_log -Value " |   CoresPerSocket      >>> $CoresPerSocket"
    Add-Content $path_log -Value " |   MemoryMB            >>> $MemoryMB"
    Add-Content $path_log -Value " |   DiskMB              >>> $DiskMB"
    Add-Content $path_log -Value " |   DiskStorageFormat   >>> $DiskStorageFormat"
    Add-Content $path_log -Value " |   NetworkName         >>> $NetworkName"
    Add-Content $path_log -Value " |   Notes               >>> $Notes"
    Add-Content $path_log -Value " - - - - - - - - - - - - - - - - - - - -"
    Add-Content $path_log -Value " "
}

function progression_print_fct($Delta_VM_done)
{
	$progression = $([math]::Round($(($Delta_VM_done * 100)/$Num_total_VM_CSV)))
	Write-Host " PROGRESSION [$progression %] ---> $Delta_VM_done VM / $Num_total_VM_CSV VM " -ForegroundColor Yellow
}

function Check($User)
{
    write-host "Fonction Check lancée"


    $GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name 
    $checkUser= Get-ADUser -identity $User.SamAccountName 
    $checkUserOU= Get-ADOrganizationalUnit $GroupeOU 

    if($GroupeOU -eq $checkUserOU)
    {
            ################################################################################
            try 
	        { 
                Remove-ADOrganizationalUnit -Identity $User.Path -Confirm:$False -ErrorAction Stop 
                write-host  "ADOrganizationalUnit: $checkUserOU deleted"  -ForegroundColor green
            }
            catch [Exception]
	        {  
                Write-Host "`n An error occured during the removal of user process : `n  $_.Exception" -ForegroundColor Red
            }
            ################################################################################
            try
            {
                New-ADOrganizationalUnit -Name $GroupeOU -ProtectedFromAccidentalDeletion $False -ErrorAction Stop 
                write-host  "ADOrganizationalUnit: $checkUserOU Created"   -ForegroundColor green
            }
            catch [Exception]
	        {  
                Write-Host "`n An error occured during the creation of user process : `n  $_.Exception" -ForegroundColor Red
            }
    }

    else
    {
            ################################################################################
            try
            {
                New-ADOrganizationalUnit -Name $GroupeOU -ProtectedFromAccidentalDeletion $False -ErrorAction Stop 
                write-host  "ADOrganizationalUnit: $checkUserOU Created"
            }
            catch [Exception]
	        {  
                Write-Host "`n An error occured during the creation of user process : `n  $_.Exception" -ForegroundColor Red
            }
    }

    if($User.Name -eq $checkUser.Name)
    {
            try 
	        { 
                Remove-ADUser -identity $User.SamAccountName 
                write-host  "ADUser: $checkUser deleted" -ForegroundColor green
            }
            catch [Exception]
	        {  
                Write-Host "`n An error occured during the removal of user process : `n  $_.Exception" -ForegroundColor Red
            }
            ################################################################################
            try
            {
                New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled -ErrorAction Stop 
                write-host  "ADUser: $checkUser Created" -ForegroundColor green
            }
            catch [Exception]
	        {  
                Write-Host "`n An error occured during the creation of new user provisionning process : `n  $_.Exception" -ForegroundColor Red
            }
            Write-host "Check OK"
    }

    else
    {
            try 
	        { 
                New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled -ErrorAction Stop 
                write-host  "ADUser: $checkUser Create"
                $Check= "OK"
            }
            catch [Exception]
	        {   
                Write-Host "`n An error occured during the creation of new user provisionning process : `n  $_.Exception" -ForegroundColor Red
            }
    }
    
    Return $Check
}

function random-password($Pass_Secure)
{
    write-host "Fonction random-password lancée"
    for ($i=0;$i -lt 3;$i++)
    {
        $min += Get-Random -InputObject a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    }
    for ($i=0;$i -lt 3;$i++)
    {
        $maj += Get-Random -InputObject A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
    }
    $nombre = Get-Random -Minimum 10 -Maximum 99
    $caracspec = Get-Random -InputObject $,!,%,*,_,-,+,=,?,[,],:,"@","&","#","|","(",")","{","}",";",",","."
    $Pass_Simple = $maj+$min+$caracspec+$nombre
    $Pass_Secure = ConvertTo-SecureString $Pass_Simple -AsPlainText -Force
    #Affichage
    #$Pass_Simple
    #$Pass_Secure
    return $Pass_Secure
}

function add_1_vm_fct($line_csv,$path_log_complet, $result_creation, $mail_target, $NameCluster, $Dalta_VM_done)
{	
    $Total_VM_creat_sucess+= 1
	try 
	{
		$NameCluster = $line_csv.NameCluster
        
		#$Datastore = $line_csv.Datastore
        $Datastore = 'datastore1'
		$GuestID = $line_csv.GuestID
		#$NumCPU = $line_csv.NumCPU
        $NumCPU = '1'
		$CoresPerSocket = $line_csv.CoresPerSocket
		#$MemoryMB = $line_csv.MemoryMB
        $MemoryMB = '512'		
        $DiskMB = $line_csv.DiskMB


		$DiskStorageFormat = $line_csv.DiskStorageFormat
		$NetworkName = $line_csv.NetworkName
		$Notes = $line_csv.Notes


        $NumCPU = $line_csv.NumCPU

        $NameVM = "vm-" + $NameCluster + "-" + $Delta_VM_done
        
        
	    
       
        New-Vm -ResourcePool $NameCluster -Name $NameVM -Datastore $Datastore -GuestID $GuestID -NumCPU $NumCPU -CoresPerSocket $CoresPerSocket -MemoryMB $MemoryMB -DiskMB $DiskMB  -NetworkName $NetworkName -Notes $Notes -ErrorAction Stop 
        
        Write-Host $NameVM "successfully created" -ForegroundColor Green
		$Result_Statement_VM = " VM [$NameVM] - [v] SUCCESSFULLY created"
        White_to_Log_Complet_fct $Result_Statement_VM $path_log_complet $line_csv 

        # mail for client who need this VM
        $body = @"
        <p>Hello,</p>
<p>This is summary about your request to creat VM</p>


<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#9ABAD9;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#9ABAD9;color:#444;background-color:#EBF5FF;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#9ABAD9;color:#fff;background-color:#409cff;}
.tg .tg-0x09{background-color:#9b9b9b;text-align:left;vertical-align:top}
.tg .tg-kftd{background-color:#efefef;text-align:left;vertical-align:top}
.tg .tg-3w70{font-weight:bold;font-size:24px;background-color:#32cb00;text-align:center;vertical-align:top}
</style>
<table class="tg" style="undefined;table-layout: fixed; width: 602px">
<colgroup>
<col style="width: 300.366667px">
<col style="width: 302px">
</colgroup>
  <tr>
    <th class="tg-3w70">Name</th>
    <th class="tg-3w70">$NameVM</th>
  </tr>
  <tr>
    <td class="tg-kftd">Datastore</td>
    <td class="tg-kftd">$Datastore</td>
  </tr>
  <tr>
    <td class="tg-0x09">GuestID</td>
    <td class="tg-0x09">$GuestID</td>
  </tr>
  <tr>
    <td class="tg-kftd">NumCPU</td>
    <td class="tg-kftd">$NumCPU</td>
  </tr>
  <tr>
    <td class="tg-0x09">CoresPerSocket</td>
    <td class="tg-0x09">$CoresPerSocket</td>
  </tr>
  <tr>
    <td class="tg-kftd">MemoryMB</td>
    <td class="tg-kftd">$MemoryMB</td>
  </tr>
  <tr>
    <td class="tg-0x09">DiskMB</td>
    <td class="tg-0x09">$DiskMB</td>
  </tr>
  <tr>
    <td class="tg-kftd">DiskStorageFormat</td>
    <td class="tg-kftd">$DiskStorageFormat</td>
  </tr>
  <tr>
    <td class="tg-0x09">NetworkName</td>
    <td class="tg-0x09">$NetworkName</td>
  </tr>
  <tr>
    <td class="tg-kftd">Notes</td>
    <td class="tg-kftd">$Notes</td>
  </tr>
</table>

<h2><span style="background-color: #00ff00;">Result of creating the VM : SUCCESSFUL [v]<br /></span></h2>


<p>Cordialement,</p>
<p>Vincent GRATEAU</p>
"@

        $subject = "Request creation VM : SUCCESS $NameVM"
        Send_Mail_fct $body $subject 


        #$result_creation[0] = $result_creation[0] + 1
        #return $result_creation
	}
			
	catch [Exception]
	{   
		
		$Total_VM_creat_err = $Total_VM_creat_err + 1
		Write-Host "An error occured during the VM provisionning process : Name >>> [$NameVM] `n $_.Exception" -ForegroundColor Red
	    $Result_Statement_VM = " VM [$NameVM] - [x] ERROR during creation `n $_.Exception"
     
	    White_to_Log_Complet_fct $Result_Statement_VM $path_log_complet $line_csv 
        $body = @"
 <p>Hello,</p>
<p>This is summary about your request to creat VM</p>


<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#9ABAD9;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#9ABAD9;color:#444;background-color:#EBF5FF;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#9ABAD9;color:#fff;background-color:#409cff;}
.tg .tg-k1q9{font-weight:bold;font-size:18px;background-color:#cb0000;border-color:inherit;text-align:center;vertical-align:top}
.tg .tg-266k{background-color:#9b9b9b;border-color:inherit;text-align:left;vertical-align:top}
.tg .tg-y698{background-color:#efefef;border-color:inherit;text-align:left;vertical-align:top}
</style>
<table class="tg" style="undefined;table-layout: fixed; width: 603px">
<colgroup>
<col style="width: 300px">
<col style="width: 303px">
</colgroup>
  <tr>
    <th class="tg-k1q9">Name</th>
    <th class="tg-k1q9">$NameVM</th>
  </tr>
  <tr>
    <td class="tg-y698">Datastore</td>
    <td class="tg-y698">$Datastore</td>
  </tr>
  <tr>
    <td class="tg-266k">GuestID</td>
    <td class="tg-266k">$GuestID</td>
  </tr>
  <tr>
    <td class="tg-y698">NumCPU</td>
    <td class="tg-y698">$NumCPU</td>
  </tr>
  <tr>
    <td class="tg-266k">CoresPerSocket</td>
    <td class="tg-266k">$CoresPerSocket</td>
  </tr>
  <tr>
    <td class="tg-y698">MemoryMB</td>
    <td class="tg-y698">$MemoryMB</td>
  </tr>
  <tr>
    <td class="tg-266k">DiskMB</td>
    <td class="tg-266k">$DiskMB</td>
  </tr>
  <tr>
    <td class="tg-y698">DiskStorageFormat</td>
    <td class="tg-y698">$DiskStorageFormat</td>
  </tr>
  <tr>
    <td class="tg-266k">NetworkName</td>
    <td class="tg-266k">$NetworkName</td>
  </tr>
  <tr>
    <td class="tg-y698">Notes</td>
    <td class="tg-y698">$Notes</td>
  </tr>
</table>


 
<h2><span style="background-color: #00ff00;"><span style="background-color: #ff0000;">&nbsp;- Result of creating the VM : FAILD [x] -&nbsp; </span><br /></span></h2>

<hr />
<h3 style="padding-left: 30px;"><strong><span style="color: #ff0000;">$_.Exception</span></strong></h3>
<hr />
 
<p>Cordialement,</p>
<p>Vincent GRATEAU</p>            
"@
        $subject = "Request creation VM : Error $NameVM"
        Send_Mail_fct x$body $subject 
    
		$result_creation[1]= $result_creation[1] + 1
        #return $result_creation
    }
	#Sent inf to log state creation of vm
	
			
	return $result_creation #$Total_VM_creat_sucess, $Total_VM_creat_er 
}

function change_csv_path_fct($path_csv)
{

    $UserChoosepath_csv = Read-Host "New csv path >>> " 
    Write-Host "New path >>> $UserChoosepath_csv"
    $UserConfirme = Read-Host "Confirme and exit [Y] or leave witout save [N] ? "
    if($UserConfirme -eq "Y")
    {
	    return $UserChoose_IHM
    }
    else
    {
        return $path_csv
    }
}

function fct_AD()
{
    clear
    Write-Host "#######################################	"
	Write-Host "#                               	  # "
	Write-Host "#       Function Create User          # "
	Write-Host "#                                     # "
	Write-Host "#######################################	"
    Write-Host "`n "

    #Imports
    $CompteurID = 0
    #Objet User
    $User= New-Object psobject -Property @{
            Id = $CompteurID
            Name = "toto-0"+$CompteurID
            GivenName = "0"
            Surname = "toto"
            SamAccountName = ""
            UserPrincipalName = ""
            Path = ""
            AccountPassword = ""
            Enabled = $true}
    #Boucle de création
    while ($CompteurID -le 9)
        {
            $CompteurID++
            $CompteurID #Affichage du compteur
            #Remplissage de l'utilisateur
            $User.Name = "toto-0"+$CompteurID
            $Plettre = $User.Name.subString(0,1) #Recupère la première lettre du Prenom
            $GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name
            $User.SamAccountName = $Plettre+$User.Surname+$CompteurID
            $User.UserPrincipalName = $User.SamAccountName+"@"+$DC1+"."+$DC2
            $User.Path = "OU=$GroupeOU,DC=$DC1,DC=$DC2"
            $User.AccountPassword = random-password 
            $User
            #Check de l'utilisateur et et son groupe (Création/Suppression)
            $Check = Check($User)
            write-host "Resultat: $Check"
        }
   #return $User
}

function fct_DNS()
{
	Write-Host "#######################################	"
	Write-Host "#                                     # "
	Write-Host "#           Program DNS               # "
	Write-Host "#                                     # "
	Write-Host "#######################################	"
    Write-Host "   	"

    $ipAddress = Read-Host -Prompt "Please enter the IP address of the Esxi"
    if( -not ($ipAddress -match "^(?:(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)\.){3}(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)$"))
     {
        do
        {
        $ipAddress = Read-Host -Prompt "Please enter a correct IPv4 address xxx.xxx.xxx.xxx"
        }until( $ipAddress -match "^(?:(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)\.){3}(?:1\d\d|2[0-5][0-5]|2[0-4]\d|0?[1-9]\d|0?0?\d)$")
    }
    #Permet de lister les records DNS de power.local correspondant à l'addresse saisie
    $checkRecord = Get-DnsServerResourceRecord -ZoneName power.local | Where-Object {$_.RecordData.IPv4Address -match $ipAddress}

    if( $checkRecord )
    {
            $recordHostname = $checkRecord.Hostname
            $recordType = $checkRecord.RecordType
            
            #Retire l'enregistrement DNS correspondant a l'adresse IP saisie
            write-host "DNS precious record removal"
            Remove-DnsServerResourceRecord -ZoneName power.local -Name $recordHostname -RRType $recordType -Force

            #Permet de recreer l'enregistrement DNS sur l'ip saisie
            write-host "DNS new record creation"
            Add-DnsServerResourceRecordA -Name $recordHostname -ZoneName power.local -IPv4Address $ipAddress

            $isComputer = Get-ADComputer -Filter 'Name -like "ESXI"'
            if( -Not $isComputer )
            {
                Write-Host "A new computer has been added to the Active Directory"
                #Creation d'un ordinateur (par defaut dans OU computers)
                New-ADComputer -Name $recordHostname -SAMAccountName $recordHostname 
            }
            else
            {
                Write-Host "Deletion of the previous computer"
                #Si le computer existe deja il est supprime puis recreer
                Remove-ADComputer -Identity $recordHostname -Confirm:$false
                Write-Host "Creation of a new computer"
                New-ADComputer -Name $recordHostname -SAMAccountName "ESXI" 
            }
    }
    else
    {
            Write-Host "This record doesnt exist ..."
            $nameNewRecord = Read-Host -Prompt "Please enter the hostname of the Esxi"

            #Si le record n'existe pas, il est cree
            Add-DnsServerResourceRecordA -Name $nameNewRecord -ZoneName power.local -IPv4Address $ipAddress
            
            Write-Host "The new record has been created."

            #Creation d'un ordinateur (par defaut dans OU computers)
            New-ADComputer -Name $nameNewRecord -SAMAccountName $nameNewRecord 

            Write-Host "A new computer named $nameNewRecord has been created !"

            break
    }
}

function fct_vCenter()
{
    clear
    Write-Host "#######################################	"
	Write-Host "#                               	  # "
	Write-Host "#            Function vCenter         # "
	Write-Host "#                                     # "
	Write-Host "#######################################	"
    Write-Host "`n "
    $New_Cluster_name = "Cluster2"
    $Datacenter_name = "DC"
    $Esxi_Ip_add = "10.1.1.12"
    try 
	{
        #New-VIPermission -Role "Admin" -Principal $NewUser -Entity (Get-Datacenter)
    

        #Create Cluster / ADRS automatique
        New-Cluster -Location $Datacenter_name  -Name $New_Cluster_name -DrsAutomationLevel FullyAutomated -ErrorAction Stop 
        Write-Host -ForegroundColor GREEN "New Cluster deployed to vCenter"
    }
    catch [Exception]
	{   
        Write-Host "`n An error occured during the vCenter provisionning process : `n  $_.Exception" -ForegroundColor Red
    }
    
    try 
	{
        #Adding ESXI
        Add-VMHost -Server $address_serveur -Name $Esxi_Ip_add -Location $New_Cluster_name -Username $login -Password $password -force -ErrorAction Stop 
        Write-Host -ForegroundColor GREEN "New ESXI is deployed to Cluster"
    }
    catch [Exception]
	{   
        Write-Host "`n An error occured during the vCenter provisionning process : `n  $_.Exception" -ForegroundColor Red
    }

    try 
	{
        #PortGroup CSV
        Import-Csv -Delimiter ";" -Path $path_portgroup_csv | ForEach-Object {
            $Portgroups = $_.Portgroups
            $ID = $_.ID
            New-VirtualPortGroup -VirtualSwitch vSwitch0 -Name $Portgroups -VLanId $ID  -ErrorAction Stop 
            Write-Host -ForegroundColor GREEN "New ESXI is deployed to Cluster"
        }
    }
    catch [Exception]
	{   
        Write-Host "`n An error occured during the vCenter provisionning process : `n  $_.Exception" -ForegroundColor Red
    }
    pause
}

 
function fct_create_vm($path_csv)
{
    $csv_file = import-csv $path_csv -delimiter ","
    clear
    Write-Host "#######################################	"
	Write-Host "#                               	  # "
	Write-Host "#            Function Create VM       # "
	Write-Host "#                                     # "
	Write-Host "#######################################	"
    Write-Host "`n "
  
    $Delta_VM_done = 0 
	$progression = 0
	$Result_Statement_VM =""
	#$result_creation=0,0
    $csv_file
	write-Host "Do you want import all VM WITHOUT verification ? " -ForegroundColor Yellow 
    $verif_vm = Read-Host " Verif[Y] or noVerif[N]  >> " # if verif=y --> verif OK / verif=N --> NO verif
    foreach ($line_csv in $csv_file)
	{
	    $line_csv
		if($verif_vm -ne "N") # verif auto
        {
            Write-Host " "	
	   	    Write-Host " Do you want import this VM ? " -ForegroundColor Yellow -NoNewline
            $finalChoose = Read-Host " [Y] or [N] " 
            if ($finalChoose -eq "Y")
	        {	
		        #$line_csv                
                $result_creation = add_1_vm_fct $line_csv $path_log $result_creation $mail_target $Dalta_VM_done 
	        }
        }
        else #no verif
        { 
           $result_creation = add_1_vm_fct $line_csv $path_log $result_creation $mail_target $Dalta_VM_done
        }
        $Delta_VM_done = $Delta_VM_done + 1	 # Fct progression programme 
		progression_print_fct $Delta_VM_done
    } 
}

function Print_IHM_fct ()
{
	clear
	Write-Host "#######################################	"
	Write-Host "#                                     # "
	Write-Host "#           Program Powershell        # "
	Write-Host "#                                     # "
	Write-Host "#######################################	"
    Write-Host "   	"
	Write-Host "  What do you want to do ? "
    Write-Host "  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
	Write-Host "  1) AD "
	Write-Host "  2) DNS"
	Write-Host "  3) vCenter"	
	Write-Host "  4) Create VM" 
    Write-Host "  5) Export" 
    Write-Host "  6) Exit" 
	
} 

function main_fct($path_csv, $path_log, $address_serveur, $login, $mail_target)
{
    $Delta_VM_done = 0 
	$progression = 0
	$Result_Statement_VM =""
	$result_creation=0,0
    
    
    $UserChoose = "0"
    
    #while ($UserChoose -eq "1" -or $UserChoose -eq "2" -or $UserChoose -eq "3" -or $UserChoose -eq "4" -or $UserChoose -eq "5") 
    
    while($UserChoose -ne "6")    
	{    
        Print_IHM_fct $path_csv
        Write-Host "  >>> Choose Action" -NoNewline -ForegroundColor Yellow
	    $UserChoose = Read-Host " " 
	    if($UserChoose -eq "1") # AD
	    {
             fct_AD
	    }
    
   	    if($UserChoose -eq "2") # DNS
	    { 
            fct_DNS
	    }

        if($UserChoose -eq "3") # vCenter
        {
            fct_vCenter($NewUser)
        }

        if($UserChoose -eq "4") # Create VM
        {
           fct_create_vm($path_csv)
        }
        
        if($UserChoose -eq "5") # Export
        {
            fct_export
        }
    } 
}   





Write-Host "Loading ..."
main_fct $path_csv $path_log $address_serveur $login $mail_target
