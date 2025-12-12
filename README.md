# Project Report: Secure & Automated Flask Deployment on Azure

## 1. Executive Summary
Detta projekt demonstrerar en helautomatiserad driftsättning av en säker 3-tier webbapplikation. Genom att kombinera **Azure CLI** för infrastruktur och **Cloud-init/GitHub** för konfiguration, kan hela miljön återskapas från noll med ett enda kommando (`./deploy.sh`).

## 2. Arkitektur
* **Reverse Proxy (Nginx):** Hanterar inkommande trafik och skyddar webbservern.
* **Web Server (Flask/Gunicorn):** Kör applikationslogiken i en isolerad miljö.
* **Database (PostgreSQL Flexible Server):** Privat och säker datalagring.

## 3. Deployment-strategi (The "GitOps" Approach)
För att säkerställa stabilitet och undvika plattformsberoende fel (t.ex. Windows vs Linux radbrytningar), flyttades all konfigurationslogik från lokala script till GitHub-repositoryt.

1.  **Bootstrap:** Azure skapar VM:s och ger dem en minimal "Cloud-init"-instruktion.
2.  **Pull:** Servrarna klonar automatiskt koden från GitHub vid uppstart.
3.  **Execute:** Servrarna kör versionshanterade installationsscript (`setup.sh` och `setup_proxy.sh`) som ligger i repot.

## 4. Lösta Hinder (Lessons Learned)

### A. "Silent Failures" i Cloud-init (CRLF vs LF)
* **Problem:** Konfigurationsfiler skapade i Windows (Git Bash) fick fel radbrytningar (`\r\n`), vilket gjorde att Linux ignorerade dem tyst. Resultatet var att servrarna startade men förblev tomma.
* **Lösning:** Använde `printf` i terminalen för att generera lokala YAML-filer med tvingande Linux-format (`\n`), samt flyttade komplex logik till `.sh`-filer på GitHub.

### B. Mappstruktur & Sökvägar
* **Problem:** Flask kräver specifika mappar (`templates`, `static`). Att skapa dessa dynamiskt via script visade sig vara felbenäget.
* **Lösning:** Omstrukturerade GitHub-repot för att spegla produktionsmiljön. Detta förenklade installationsscriptet drastiskt.

### C. Databaskoppling
* **Problem:** Tjänstefilen (`systemd`) hittade inte den virtuella Python-miljön p.g.a. felaktiga sökvägar.
* **Lösning:** Standardiserade installationsvägen i `setup.sh` till `/home/azureuser/Webinar/` och uppdaterade `flaskapp.service` att peka exakt dit.

## 5. Resultat
En fullt fungerande, "Self-Healing" infrastruktur där deployment-tiden minimerats och den manuella handpåläggningen eliminerats helt.
