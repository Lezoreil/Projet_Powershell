#Creation Utilisateurs
function CreaUsers($User)
{
    write-host "Fonction CreaUsers lancée"
    #Imports
    #Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1
    #Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\random-password.ps1
    #Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\AddOUforUserX.ps1

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
	While ($CompteurID -le 9)
		{
			$CompteurID++
			$CompteurID #Affichage de check
            #Remplissage de l'utilisateur
			$Plettre = $User.Name.subString(0,1) #Recupère la première lettre du Prenom
			$GroupeOU = "Admin-"+$User.Name #Groupe incrémenté aussi comme le Name 
            $User.SamAccountName = $Plettre+$User.Surname
            $User.UserPrincipalName = $User.SamAccountName+"@"+$DC1+"."+$DC2
            $User.Path = "OU=$GroupeOU,DC=$DC1,DC=$DC2"
            $User.AccountPassword = random-password 
            #Check de l'utilisateur et et son groupe (Création/Suppression)
            AddOUforUserX($User)
		}
    return $CompteurID
}