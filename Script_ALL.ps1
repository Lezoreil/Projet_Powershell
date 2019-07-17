#############################################
# 	Title 	: 	Script_creat_VM_to_ESXi		#
#	Date  	:	08/04/2019					#
#	Version : 	1							#
#	Autor 	: 	Vincent GRATEAU				#
#############################################


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

Import-Module VMware.VimAutomation.Core
$address_serveur = "10.1.1.10"
$address_esxi1 = "10.1.1.10"

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


function fct_vCenter ($NewUser)
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
        Add-VMHost -Server $address_serveur -Name "10.1.1.13" -Location $New_Cluster_name -Username $login -Password $password -force -ErrorAction Stop 
        Write-Host -ForegroundColor GREEN "New ESXI is deployed to Cluster"
    }
    catch [Exception]
	{   
        Write-Host "`n An error occured during the vCenter provisionning process : `n  $_.Exception" -ForegroundColor Red
    }

    try 
	{
        #PortGroup CSV
        Import-Csv -Delimiter ";" -Path $path_portgroup_csv | ForEach-Object 
        {
            $Portgroups = $_.Portgroups
            $ID = $_.ID

            New-VirtualPortGroup -VirtualSwitch vSwitch0 -Name $Portgroups -VLanId $ID -Confirm $false -ErrorAction Stop 
        }
    }
    catch [Exception]
	{   
        Write-Host "An error occured during the vCenter provisionning process : `n  $_.Exception" -ForegroundColor Red
    }

}

function fct_create_vm
{
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
		   Write-Host "Do you want import all VM WITHOUT verification ? "
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

function main_fct($path_csv, $path_log, $address_serveur, $login, $mail_target)
{

    $Delta_VM_done = 0 
	$progression = 0
	$Result_Statement_VM =""
	$result_creation=0,0
    $path_log_basic
    
    $UserChoose = Print_IHM_fct $path_csv

    while ($UserChoose -eq "1" -or $UserChoose -eq "2" -or $UserChoose -eq "3" -or $UserChoose -eq "4" -or $UserChoose -eq "5") 
    {     
	    $csv_file = import-csv $path_csv -delimiter ","
	
	    $measure =  Get-Content $path_csv
	    $Num_total_VM_CSV = $((($measure | Select-String .).Count))-1
	    
	    if($UserChoose -eq "1") # AD
	    {
             $NewUser= fct_AD
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
           fct_create_vm
        }
        
        if($UserChoose -eq "5") # Export
        {
            fct_export
        }
        
        pause
	    clear
       

        
      
        pause
         $UserChoose = Print_IHM_fct $path_csv
    }
    return
    
}


function Print_IHM_fct ($path_csv)
{
	clear
	Write-Host "#######################################	"
	Write-Host "#                               	  # "
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
	Write-Host "  >>> Choose Action" -NoNewline -ForegroundColor Yellow
	$UserChoose_IHM = Read-Host " " 
	return $UserChoose_IHM
} 

Write-Host "Loading ..."
main_fct $path_csv $path_log $address_serveur $login $mail_target
