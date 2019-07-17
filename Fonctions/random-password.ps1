#Fonctions password
#Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Main.ps1
#Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\CreaUsers.ps1
#Import-module $env:USERPROFILE\Documents\GitHub\Projet_Powershell\Fonctions\Check.ps1

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