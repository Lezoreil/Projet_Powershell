#Creation Utilisateurs
    Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1
    Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\random-password.ps1
    #Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\AddOUforUserX.ps1
function AddOUforUserX($User)
{
    write-host "Fonction AddOUforUserX lancée"


    $GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name 


    $checkUser= Get-ADUser -identity $User.SamAccountName 
    $checkUserOU= Get-ADOrganizationalUnit $GroupeOU 

    if($GroupeOU -eq $checkUserOU)
        {
            Remove-ADOrganizationalUnit -Identity $User.Path -Confirm:$False
            write-host  "ADOrganizationalUnit: $checkUserOU supprimé"
            New-ADOrganizationalUnit -Name $GroupeOU -ProtectedFromAccidentalDeletion $False
            write-host  "ADOrganizationalUnit: $checkUserOU Créé"
        }
    else
        {
            New-ADOrganizationalUnit -Name $GroupeOU -ProtectedFromAccidentalDeletion $False
            write-host  "ADOrganizationalUnit: $checkUserOU Créé"
        }
    if($User.Name -eq $checkUser.Name)
        {
            Remove-ADUser -identity $User.SamAccountName 
            write-host  "ADUser: $checkUser supprimé"
            New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled
            write-host  "ADUser: $checkUser Créé"
            $Check= "OK"
        }
    else
        {
            New-ADUser -Name $User.Name -GivenName $User.GivenName -Surname $User.Surname -SamAccountName $User.SamAccountName -UserPrincipalName $User.UserPrincipalName -Path $User.Path -AccountPassword $User.AccountPassword -Enabled $User.Enabled
            write-host  "ADUser: $checkUser Créé"
            $Check= "OK"
        }
    
    Return $Check
}
function CreaUsers($User)
{
    write-host "Fonction CreaUsers lancée"
    #Imports
	$CompteurID = 0
    #Objet User
    $User= New-Object psobject -Property @{
            Id = $CompteurID
            Name = "toto-0$CompteurID"
            GivenName = "0"
            Surname = "toto"
            SamAccountName = ""
            UserPrincipalName = ""
            Path = ""
            AccountPassword = ""
            Enabled = $true}
    #Boucle de création
	For ($CompteurID= 0, $CompteurID -le 9, $CompteurID++)
		{
			$CompteurID #Affichage du compteur
            #Remplissage de l'utilisateur
            $User.Name = "toto-0$CompteurID"
			$Plettre = $User.Name.subString(0,1) #Recupère la première lettre du Prenom
			$GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name 
            $User.SamAccountName = $Plettre+$User.Surname
            $User.UserPrincipalName = $User.SamAccountName+"@"+$DC1+"."+$DC2
            $User.Path = "OU=$GroupeOU,DC=$DC1,DC=$DC2"
            $User.AccountPassword = random-password 
            #Check de l'utilisateur et et son groupe (Création/Suppression)
            $Check = AddOUforUserX
            write-host "Resultat: $Check"
		}
}