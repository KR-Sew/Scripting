# <img src="../../Assets/icons8-bash-48.svg" width=35 alt="Bash Scripts Collection">  Install NGINX from source and Cerbot for NGINX and Apache (Debian/Ubuntu)  

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
  </br>the scritp for installing Nginx on Debian 13 Trixie. This script doesn't create folders like sites-available, conf.d, sites-enabled if you need them you must create manually. Remember Nginx will be installed to `/usr/local/nginx`

- 📄[Install_Nginx_from_Source.sh](./Install_Nginx_From_Source.sh)
  </br>
  [![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/sh-update-rclone.yml)
  </br> #Script for installing Nginx from source. This script doesn't create folders like sites-available, conf.d, sites-enabled if you need them you must create manually. Remember Nginx will be installed to `/usr/local/nginx`

---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
