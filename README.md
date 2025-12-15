# Secure Three-Tier Web Architecture on Azure ☁️

Detta projekt är en helautomatiserad "Infrastructure as Code" (IaC) lösning för att driftsätta en säker, skalbar webbapplikation (Flask) med en hanterad PostgreSQL-databas på Microsoft Azure.

Lösningen använder en **GitOps-inspirerad deployment-strategi** där infrastrukturen provisioneras via Azure CLI, medan serverkonfigurationen hämtas dynamiskt från detta GitHub-repository vid uppstart.

---

## 🏗 Arkitektur

Systemet är byggt enligt en klassisk **3-Tier Architecture** för maximal säkerhet och isolering:

1.  **Reverse Proxy (Nginx):**
    * Agerar "portvakt" och tar emot all inkommande trafik.
    * **HTTPS (Port 443):** Konfigurerad med ett självsignerat SSL-certifikat för krypterad trafik.
    * Vidarebefordrar trafik till applikationsservern via ett internt nätverk.
    * Publik IP: ✅

2.  **Application Server (Flask/Gunicorn):**
    * Kör affärslogiken och Python-koden.
    * Helt isolerad från internet (Ingen publik IP).
    * Innehåller `postgresql-client` för databasadministration.
    * Publik IP: ❌

3.  **Database (Azure Database for PostgreSQL):**
    * Hanterad PaaS-tjänst (Flexible Server).
    * Endast tillgänglig för interna Azure-resurser.
    * Publik IP: ❌

4.  **Bastion Host (Jumpbox):**
    * Enda vägen in för SSH-administration (Port 22).
    * Använder SSH Agent Forwarding för att nå de interna servrarna.

---

## 🚀 Deployment (Hur man kör det)

Hela miljön kan återskapas från noll med ett enda kommando. Scriptet hanterar nätverk, brandväggar, VM-skapande och databaskopplingar.

### Förutsättningar
* Azure CLI installerat (`az login`).
* Git Bash (om du kör Windows) eller Terminal (Mac/Linux).
* SSH-nycklar genererade (`~/.ssh/id_rsa`).

### Steg-för-steg
1.  **Klona repot och gå till infra-mappen:**
    ```bash
    git clone [https://github.com/85emmhor-dev/Webinar.git](https://github.com/85emmhor-dev/Webinar.git)
    cd Webinar/infra
    ```

2.  **Kör deployment-scriptet:**
    ```bash
    ./deploy.sh
    ```

3.  **Vänta ca 5 minuter.**
    Scriptet kommer att ge dig IP-adressen till webbplatsen när det är klart ("DEPLOYMENT COMPLETE").

---

## ⚙️ Så fungerar Automationen (Under huven)

För att undvika problem med operativsystemsskillnader (t.ex. Windows CRLF vs Linux LF radbrytningar) används en **Bootstrapping-metod**:

1.  **Lokal Dator (`deploy.sh`):** Skapar Azure-resurserna och skickar en minimal `cloud-init`-fil till servrarna.
2.  **Server Uppstart:** Servrarna vaknar och får instruktionen: *"Installera Git och hämta senaste koden från GitHub"*.
3.  **GitHub Execution:** Servrarna laddar ner och kör installationsscripten som ligger versionshanterade i detta repo:
    * `setup.sh`: Installerar Python, Flask, Gunicorn och `postgresql-client` på WebServern.
    * `setup_proxy.sh`: Installerar Nginx och genererar SSL-certifikat på Proxyn.

Detta garanterar att servrarna alltid installeras identiskt, oavsett vem som kör deploy-scriptet.

---

## 🔒 Säkerhet & Verifiering

### HTTPS / SSL
Reverse Proxy är konfigurerad att lyssna på **Port 443**. Eftersom ett självsignerat certifikat används kommer webbläsaren att visa en varning vid första besöket, men trafiken är krypterad.

### Databasverifiering
För att bevisa att data sparas korrekt kan man ansluta manuellt till databasen inifrån WebServern:

```bash
# 1. Logga in via Bastion (med agent forwarding)
ssh -A azureuser@<BASTION_IP>

# 2. Hoppa till WebServer (privat IP)
ssh 10.0.0.4

# 3. Anslut till DB
psql "host=<DB_SERVER> user=flaskadmin password=<KEY> dbname=contactform sslmode=require"
