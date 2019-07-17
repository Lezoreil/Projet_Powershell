#Main

Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\AddOUforUserX.ps1
Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\CreaUsers.ps1
Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\random-password.ps1

$DC1='power'
$DC2='local'
$CompteurIHM=0
While($CompteurIHM -eq 0)
{
""
"Bonjour, que voulez-vous faire ?"
"1) Créer des utilisateurs"
"2)"
"3)"
"4) Quitter"
$choix= Read-Host '1, 2, 3 ou 4 ?'
    switch($choix)
        {
            1{CreaUsers}
            4{Exit}
        }
}