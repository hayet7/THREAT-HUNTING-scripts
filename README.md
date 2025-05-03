# THREAT-HUNTING-scripts

Ce projet regroupe plusieurs scripts PowerShell utilisés dans le cadre d'activités de **Threat Hunting** sur des postes Windows.

## 🧰 Contenu des scripts

- **Hayabusa.ps1**  
  Utilise [Hayabusa](https://github.com/Yamato-Security/hayabusa) pour analyser les journaux d'événements Windows (EVTX) afin de détecter des comportements suspects.

- **Hoarder.ps1**  
  Exécute l'outil Hoarder pour collecter automatiquement des artefacts forensiques sur les endpoints Windows (fichiers journaux, registre, etc.).

- **Loki.ps1**  
  Lance [Loki](https://github.com/Neo23x0/Loki), un scanner simple de malwares et d'indicateurs de compromission (IoC), pour identifier des fichiers ou processus malveillants.

## 🚀 Utilisation

Exécuter les scripts avec PowerShell en mode administrateur :

```powershell
.\Hayabusa.ps1
.\Hoarder.ps1
.\Loki.ps1
