#Main
#Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\Check.ps1
#Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\CreaUsers.ps1
#Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\random-password.ps1

$DC1='power'
$DC2='local'

function CreaUsers($User)
{
    write-host "Fonction CreaUsers lancée"
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
}

function Check($User)
{
    write-host "Fonction Check lancée"


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

$CompteurIHM=0
While($CompteurIHM -eq 0)
{
""
"Bonjour, que voulez-vous faire ?"
"1) Créer des utilisateurs"
"2) Quitter"
"3)"
"4)"
$choix= Read-Host '1, 2, 3 ou 4 ?'
    switch($choix)
        {
            1{CreaUsers}
            2{Exit}
        }
}