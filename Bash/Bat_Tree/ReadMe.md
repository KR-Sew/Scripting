# <img src="https://git-scm.com/images/logos/downloads/Git-Icon-1788C.svg" width=35 alt="Instatll and update Git">  Install or Update Batcat and Tree

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

There are scripts that can install **Batcat** and **Tree** from source or update them.
And configure **Batcat** to run like the short name **bat**.

## 📂 Description

- 📄[install_bat_tree.sh](./install-batcat-tree.sh)
  
  - to run this script
  
  ```bash
     chmod +x ./install_bat_tree.sh
     sudo ./install_bat_tree.sh
  ```

- **BAT** can be configured manually for some an old verion:
  
  ```bash
     mkdir -p "$HOME/.local/bin"
     ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"

    grep -Fqx 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" ||
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    
    source "$HOME/.bashrc" 
  ```

  - then you can check

  ```bash
     bat --version
     tree --version
  ```   

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
