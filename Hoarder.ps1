# Télécharger Hoarder depuis GitHub
cd $env:USERPROFILE\Downloads
git clone https://github.com/DFIRKuiper/Hoarder.git


# Aller dans le dossier releases
cd .\Hoarder\releases\

# Exécuter hoarder.exe
.\hoarder.exe -vv

#recuperation .zip

copy "C:\Users\$env:USERNAME\Downloads\Hoarder\releases\$env:COMPUTERNAME.zip" "C:\Users\$env:USERNAME\pfe\threat_hunting\threat_hunting\media\hoarder_zips\"
