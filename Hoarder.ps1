# Télécharger Hoarder depuis GitHub
cd $env:USERPROFILE\Downloads
git clone https://github.com/DFIRKuiper/Hoarder.git


# Aller dans le dossier releases
cd .\Hoarder\releases\

# Exécuter hoarder.exe
.\hoarder.exe -vv 

# Attendre un peu que les fichiers se génèrent
Start-Sleep -Seconds 2

# Chercher le dernier fichier généré dans le dossier releases (ZIP, JSON, etc.)
$fichierGenere = Get-ChildItem -Path . -Include *.zip, *.csv, *.json -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $fichierGenere) {
    Write-Host "Aucun fichier généré trouvé."
    exit
}

# Envoyer le fichier à ton backend Django
Invoke-WebRequest -Uri "http://http:/127.0.0.1:8000/api/upload_resultat/" `
    -Method Post `
    -Form @{
        "fichier" = Get-Item $fichierGenere.FullName
    }

Write-Host "Fichier $($fichierGenere.Name) envoyé à Django."
