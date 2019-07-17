#Fonctions check
Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1

function Check($User)
{
	write-host "Fonction AddOUforUserX lancée"


	$GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name 


	$checkUser= Get-ADUser -identity $User.SamAccountName 
	$checkUserOU= Get-ADOrganizationalUnit $GroupeOU 

	if($GroupeOU -eq $checkUserOU)
		{
			Remove-ADOrganizationalUnit -Identity $User.Path -Confirm:$False
			write-host	"ADOrganizationalUnit: $checkUserOU supprimé"
			New-ADOrganizationalUnit -Name $GroupeOU -ProtectedFromAccidentalDeletion $False
			write-host	"ADOrganizationalUnit: $checkUserOU Créé"
		}
	else
		{
			New-ADOrganizationalUnit -Name $GroupeOU -ProtectedFromAccidentalDeletion $False
			write-host	"ADOrganizationalUnit: $checkUserOU Créé"
		}
	if($User.Name -eq $checkUser.Name)
		{
			Remove-ADUser -identity $User.SamAccountName 
			write-host	"ADUser: $checkUser supprimé"
			New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled
			write-host	"ADUser: $checkUser Créé"
			$Check= "OK"
		}
	else
		{
			New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled
			write-host	"ADUser: $checkUser Créé"
			$Check= "OK"
		}
	
	Return $Check
}