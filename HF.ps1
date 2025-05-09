# Télécharger Hoarder depuis GitHub (si pas déjà fait)
cd $env:USERPROFILE\Downloads
if (-not (Test-Path "Hoarder")) {
    git clone https://github.com/DFIRKuiper/Hoarder.git
}

# Aller dans le dossier releases
cd .\Hoarder\releases\

# Exécuter hoarder.exe
.\hoarder.exe -vv

# Attendre quelques secondes le temps que le zip se génère
Start-Sleep -Seconds 5

# Récupérer le dernier fichier .zip généré
$latestZip = Get-ChildItem -Filter *.zip | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Afficher le fichier trouvé
Write-Host "Dernier fichier ZIP généré : $($latestZip.FullName)"

# URL de ton serveur Django (à adapter à ton IP/port réel)
$uploadUrl = "http://localhost:8000//upload-hoarder/"

# Envoi du fichier vers l’interface web
Invoke-RestMethod -Uri $uploadUrl -Method Post -Form @{ "file" = Get-Item $latestZip.FullName }
