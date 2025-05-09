# Variables
$destinationDjango = "http://192.168.1.100:8000/api/upload_resultat/"
$cheminProjet = "$env:USERPROFILE\Downloads\Hoarder"
$cheminReleases = "$cheminProjet\releases"
$hoarderExe = "$cheminReleases\hoarder.exe"

# Cloner Hoarder si nécessaire
if (!(Test-Path $cheminProjet)) {
    git clone https://github.com/DFIRKuiper/Hoarder.git $cheminProjet
}

# Aller dans le dossier releases
Set-Location $cheminReleases

# Exécuter Hoarder
& $hoarderExe -vv

# Attendre un peu si nécessaire (dépend du système)
Start-Sleep -Seconds 3

# Chercher le dernier fichier généré (ex: fichier zip)
$fichierGenere = Get-ChildItem -Path $cheminReleases -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $fichierGenere) {
    Write-Host "Aucun fichier généré trouvé."
    exit
}

# Envoi à Django
$response = Invoke-WebRequest -Uri $destinationDjango `
    -Method Post `
    -Form @{
        "fichier" = Get-Item $fichierGenere.FullName
    }

Write-Host "Fichier envoyé, réponse du serveur : $($response.Content)"


