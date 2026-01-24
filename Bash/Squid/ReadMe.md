# <img width="48" height="48" src="https://img.icons8.com/external-tal-revivo-shadow-tal-revivo/48/external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo.png" alt="external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo"/>  Install NGINX from source and Cerbot for NGINX and Apache (Debian/Ubuntu)  

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

A collection of scripts that can install NGINX from source and install Certbot for NGINX or Apache web server on Debian/Ubuntu.  

## 📂 Folder Description

- 📄[Install_Certbot_Nginx.sh](./Install_Certbot_Nginx.sh)
  </br>
  [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-go.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-go.yml)
  </br> # Scripts for installation Certbot for using with Nginx web server.
- 📄[Install_Cerbot.sh](./Install_Certbot.sh)
  </br>
   [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-git-gitcli.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-git-gitcli.yml)
  </br> the script for installing or updating Certbot.It can use with both web servers
  Just select right key such as --nignx or --apache.
  
  ```bash
    sudo ./install_Certbot.sh --nginx
    sudo ./install_Certbot.sh --apache
  ```

- 📄[Install_nginx_deiban13.sh](./Install_nginx_debian13.sh)
  </br>
  [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-gawk.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-gawk.yml)
  </br>the scritp for installing Nginx on Debian 13 Trixie. This script doesn't create folders like `sites-available`, `conf.d`, `sites-enabled` if you need them you must create manually. Remember Nginx will be installed to `/usr/local/nginx`

- 📄[Install_Nginx_from_Source.sh](./Install_Nginx_From_Source.sh)
  </br>
  [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml)
  </br> #Script for installing Nginx from source. This script doesn't create folders like `sites-available`, `conf.d`, `sites-enabled` if you need them you must create manually. Remember Nginx will be installed to `/usr/local/nginx`

- 📄[Install_Nginx_deb13_with_folders.sh](./Install_nginx_deb13_with_folders.sh)
  </br>
  [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml)
  </br> #Script for installing Nginx from source. This script will create folders like `sites-available`, `conf.d`, `sites-enabled` in folder `/usr/local/nginx`. Also script check `curl` if it's not installed it will be installed too.

- 📄[Add_stream_module.sh](./Add_stream_module.sh)
  </br>
  [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml)
  </br> #Script for adding **stream** (SNI) module to **Nginx** installed from source. This script will check **Nginx** version, download it, unpack, and `reconfigure` and `install` stream module.


sudo apt-get update && sudo apt-get install -y apache2-utils
sudo htpasswd -c /opt/squid/auth/passwd proxyuser
# add more users (no -c):
sudo htpasswd /opt/squid/auth/passwd anotheruser
sudo chmod 640 /opt/squid/auth/passwd



cd /opt/squid
docker compose up -d
docker logs -f squid



sudo ufw allow from 203.0.113.10 to any port 3128 proto tcp
sudo ufw deny 3128/tcp
sudo ufw status verbose


Quick client tests
From a client machine:
curl -v --proxy http://proxyuser:YOURPASS@YOUR_SERVER_IP:3128 https://example.com


Set system env (Linux):
export http_proxy="http://proxyuser:YOURPASS@YOUR_SERVER_IP:3128"
export https_proxy="http://proxyuser:YOURPASS@YOUR_SERVER_IP:3128"


APT through proxy (example):

Create /etc/apt/apt.conf.d/80proxy:

Acquire::http::Proxy "http://proxyuser:YOURPASS@YOUR_SERVER_IP:3128";
Acquire::https::Proxy "http://proxyuser:YOURPASS@YOUR_SERVER_IP:3128";





---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
