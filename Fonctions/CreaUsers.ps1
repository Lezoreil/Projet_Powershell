#Creation Utilisateurs
    Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1
    Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\random-password.ps1
    Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\Check.ps1

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
	while ($CompteurID -le 9)
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
            $Check = Check($User)
            write-host "Resultat: $Check"
		}
}