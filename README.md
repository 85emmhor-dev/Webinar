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

graph TD
    %% --- Styles ---
    classDef azure fill:#0072C6,stroke:#fff,stroke-width:2px,color:#fff;
    classDef subnet fill:#e1f0fa,stroke:#0072C6,stroke-width:1px,stroke-dasharray: 5 5,color:#000;
    classDef vm fill:#fff,stroke:#0072C6,stroke-width:2px,color:#000;
    classDef db fill:#333,stroke:#fff,stroke-width:2px,color:#fff;
    classDef ext fill:#f9f9f9,stroke:#666,stroke-width:1px,color:#000;

    %% --- External Actors ---
    subgraph Internet ["🌐 Internet"]
        User((Besökare)):::ext
        Admin((Admin)):::ext
        GitHub[GitHub Repo<br/>Code & Scripts]:::ext
    end

    %% --- Azure Environment ---
    subgraph Azure ["☁️ Microsoft Azure (Resource Group)"]
        style Azure fill:#f0f8ff,stroke:#0072C6,color:#000

        subgraph VNet ["Secure VNet (10.0.0.0/16)"]
            style VNet fill:#fff,stroke:#ccc,color:#000

            %% --- Public Facing Components ---
            subgraph PublicZone ["Public Access (NSG Allow)"]
                class PublicZone subnet
                Proxy[("Reverse Proxy<br/>(Nginx)<br/>Public IP")]:::vm
                Bastion[("Bastion Host<br/>(Jumpbox)<br/>Public IP")]:::vm
            end

            %% --- Private Components ---
            subgraph PrivateZone ["Private/Isolated (No Public IP)"]
                class PrivateZone subnet
                WebServer[("Web Server<br/>(Flask/Gunicorn)<br/>10.0.0.4")]:::vm
            end
        end

        %% --- Database (PaaS) ---
        DB[("Azure Database<br/>for PostgreSQL")]:::db
    end

    %% --- Traffic Flows ---
    %% 1. User Traffic
    User -- "HTTPS (443)" --> Proxy
    Proxy -- "HTTP (5001)" --> WebServer

    %% 2. Admin Traffic
    Admin -- "SSH (22)" --> Bastion
    Bastion -. "SSH Tunnel (22)" .-> WebServer
    Bastion -. "SSH Tunnel (22)" .-> Proxy

    %% 3. Database Traffic
    WebServer -- "TCP (5432)" --> DB

    %% 4. Provisioning Flow
    GitHub -. "git clone (Boot)" .-> Proxy
    GitHub -. "git clone (Boot)" .-> WebServer



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
