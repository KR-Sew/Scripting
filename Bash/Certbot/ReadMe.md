# <a href="https://certbot.eff.org/"><img src="https://certbot.eff.org/assets/certbot-logo-1A-6d3526936bd519275528105555f03904956c040da2be6ee981ef4777389a4cd2.svg" width=125 alt="Instatll and update Git">  Install or Update Certbot

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

These are scripts that can install **Certbot** or update them from source.

## 📂 Description

- 📄[**install_Certbot_nginx.sh**](./Install_Certbot_Nginx.sh)
  - the script installs `Certbot` for `nginx` web server on **Debian 13**
  - set the script executable and run:
  
   ```bash
      sudo chmod +x ./install_certbot_nginx.sh
      sudo ./install_certbot_nginx.sh
   
   ```

- 📄[**Install_Certbot.sh**](./Install_Certbot.sh)
  - this is the universal installation script that fits for `nginx` `apache` or for `standalone`
    configuration
  
   ```bash
      sudo chmod +x ./Install_Certbot.sh
      sudo ./Install_Certbot.sh
   
   ```

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
