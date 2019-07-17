#Fonctions
function AddOUforUserX($User)
{
	Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1

	$GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name 

	$checkUser= Get-ADUser -identity $User.UserPrincipalName  
	$checkUserOU= Get-ADUser -identity $User.UserPrincipalName 

	if(($User.DistinguishedName -eq $checkUserOU)
		{
			Remove-ADOrganizationalUnit -Name $GroupeOU
		}
	else
		{
			New-ADOrganizationalUnit -Name $GroupeOU
		}
	if($User.Name -eq $checkUser)
		{
			Remove-ADUser -identity $User.SamAccountName -force
		}
	else
		{
			New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled
		}
	Return 
}