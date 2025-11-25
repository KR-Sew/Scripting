# <img width="48" height="48" src="https://img.icons8.com/external-tal-revivo-shadow-tal-revivo/48/external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo.png" alt="external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo"/> Configure NGINX for **ISP Manager** panel

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Let's put **ISP manager** behind your existing **Nginx** reverse-proxy using a subdomain such as `isp.mysite.com`, issue a **Let’s Encrypt** certificate for it using **Certbot**, and then proxy all traffic to the local port `1500` where **ISP manager** is running.

## 📂 Action chain

- 📄 Create a file:

```swift
  /etc/nginx/sites-available/isp.mysite.com.conf
```

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

---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
