<#
.SYNOPSIS
  Crée les comptes Active Directory de l'entreprise à partir d'un fichier CSV.
.DESCRIPTION
  Pour chaque ligne du CSV (Prenom;Nom;Service;Fonction), crée un utilisateur
  prenom.nom dans l'OU de son service. Le mot de passe initial est saisi à l'invite
  (jamais stocké dans le script ni dans le CSV) et doit être changé à la première connexion.
.EXAMPLE
  .\New-AtelierUsers.ps1 -CsvPath C:\Scripts\utilisateurs.csv
#>
param(
    [string]$CsvPath = "C:\Scripts\utilisateurs.csv",
    [string]$Domaine = "atelier.local",
    [string]$BaseDN  = "OU=Utilisateurs,OU=Atelier Morel,DC=atelier,DC=local"
)

$mdp = Read-Host -AsSecureString "Mot de passe initial des comptes"

Import-Csv -Path $CsvPath -Delimiter ";" | ForEach-Object {
    $sam = ($_.Prenom + "." + $_.Nom).ToLower()

    # Idempotence : on ne recrée pas un compte existant
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Host "Existe deja : $sam" -ForegroundColor Yellow
        return
    }

    New-ADUser -Name "$($_.Prenom) $($_.Nom)" `
               -GivenName $_.Prenom -Surname $_.Nom `
               -DisplayName "$($_.Prenom) $($_.Nom)" `
               -SamAccountName $sam -UserPrincipalName "$sam@$Domaine" `
               -Department $_.Service -Title $_.Fonction `
               -Path "OU=$($_.Service),$BaseDN" `
               -AccountPassword $mdp -ChangePasswordAtLogon $true -Enabled $true

    Write-Host "Cree : $sam ($($_.Service))" -ForegroundColor Green
}
