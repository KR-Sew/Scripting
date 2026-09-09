# <img width="48" height="48" src="https://img.icons8.com/external-tal-revivo-shadow-tal-revivo/48/external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo.png" alt="external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo"/>  Install NGINX from source (Debian/Ubuntu)  

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

These scripts that can install **NGINX** from source on **Debian/Ubuntu**.  

## 📂 Folder Description

- 📄[**Install Nginx Deb13 symlink**](./install_nginx_deb13_symlink.sh)
  - Scripts for installation **Nginx** from source on **Debian13** and add `symlink` for it. This script creates folders like `sites-available`, `conf.d`, `sites-enabled` in folder `/usr/local/nginx`. Also script check `curl` if it's not installed it will be installed too. And it creates symlink to the folder `/etc/nginx` for getting certificates using **Certbot**.`

- 📄[**Install Nginx Deb13 with forlders**](./Install_nginx_deb13_with_folders.sh)
  - the script for installing **Nginx** from source. This script creates folders like `sites-available`, `conf.d`, `sites-enabled` in folder `/usr/local/nginx`. Also script check `curl` if it's not installed it will be installed too.

- 📄[**Install Nginx Debian13**](./Install_nginx_debian13.sh)
  - the scritp for installing Nginx on **Debian 13 Trixie**. This script doesn't create folders like `sites-available`, `conf.d`, `sites-enabled` if you need them you must create manually. Remember **Nginx** will be installed to `/usr/local/nginx`

- 📄[**Install Nginx from Source**](./Install_Nginx_From_Source.sh)
  - the script for installing **Nginx** from source. This script doesn't create folders  like `sites-available`, `conf.d`, `sites-enabled` if you need them you must create manually. Remember **Nginx** will be installed to `/usr/local/nginx`

- 📄[**Add stream module**](./Add_stream_module.sh)
  - the script for adding **stream** (SNI) module to **Nginx** installed from source. This script will check **Nginx** version, download it, unpack, and `reconfigure` and `install` stream module.

---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
