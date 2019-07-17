#Fonctions
function AddOUforUserX($User)
{
	Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1
	$checkUser= Get-ADUser -identity $User.Name  
	$checkUserOU= Get-ADUser -identity $User.DistinguishedName 
	if($User -eq $checkUser)
		{
			Remove-ADUser -Name $User.Name
		}
	else
		{
			New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled
		}
	if()
		{
			Remove-ADOrganizationalUnit -Name "Admin-"
		}
	else
		{
			New-ADOrganizationalUnit -Name "Admin-$User.Name" -Path "DC=$DC1,DC=$DC2"
		}
}