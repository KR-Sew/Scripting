# <img src="../../Assets/icons8-bash-48.svg" width=35 alt="Bash Scripts Collection"> Useful network and none network utilities

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Database Icon by icons8.com](https://img.shields.io/badge/Database%20Icon%20by%20icon8.com-54f2f2.svg?logo=vsc&logoColor=white)](https://icons8.com)

Useful network utilities and just simple utils to work with `CLI` in **Debian/Ubuntu**.  

## 📂 Description

- ### <img width="25" src="../../Assets/utilities_terminal_icon_180964.svg" alt="bash"/> Network utilities

  - **Core Modern Networking tools** consist of:
    - `iproute2`. Tools included: `ip`,`ss`,`bridge`,`tc`(traffic control/qdisc/shaping)
    - Installing:

    ```bash
       sudo apt install iproute2
    ```
  
    - `iputils`. Contains `ping`,`tracepath`,`arping`
    - Installing:

    ```bash
      sudo apt install iputils-ping
    ```

  - **Traceroute and Path Analysis**
    - Package `traceroute`
    - Installing:

    ```bash
      sudo apt install traceroute
    ```

    - support `UDP`,`ICMP`,`TCP` mode (`-T`), custom ports. Example:

    ```bash
       traceroute -T -p 443 example.com
    ```

    - Package `mtr`
    - This is traceroute + ping combined in real-time.
    - Installing:

     ```bash
      sudo apt install mtr
     ```

    - Example:

    ```bash
       mtr  exampler.com
       mtr -T -P 443 example.com
    ```

  - **DNS Tools**
    - `dnsutils` contains `dig`,`nslookup`
    - Installing:

    ```bash
       sudo apt install dnsutils
    ```

    - Examples:

    ```bash
       dig +trace example.com
       dig @8.8.8.8 example.com
    ```

    - `knot-dnsutils` contains `kdig` modern, fast alternative to `dig`
    - Installing:

    ```bash
       sudo apt install knot-dnsutils
    ```

    - Examples:

    ```bash
       kdig +tls google.com
    ```

  - **Deep network inspection**
    - `tcpdump` Classic packet capture, essential fit in **Routing/NAT**
    - Installing:

    ```bash
       sudo apt install tcpdump
    ```

    - Example:

    ```bash
       tcpdump -i eth0 port 443
       tcpdump -i eth0 icmp
    ```

    - `wireshark-cli` CLI version of **WireShark**
    - Installing:

    ```bash
       sudo apt install tshark
    ```

  - **Modern diagnostic tools**
    - `nmap` Port scanner and service detector
    - Installing:

    ```bash
       sudo apt install nmap
    ```

    - Example:

    ```bash
       nmap -sS -p- 10.0.0.1
    ```
    - `iperf3` Bandwidth testing tool.
    - Installing:

    ```bash
       sudo apt install iperf3
    ```

    - Example, test between two servers:

    ```bash
       iperf3 -s
       iperf3 -c server_ip_address
    ```

  - **Socket connection debugging**
    - `netcat` Test raw TCP
    - Installing:

     ``` bash
        sudo apt install netcat-openbsd
     ```

    - `curl` Not just for **HTTP** - aslo for **FTP**,**SFTP**,**SMTP**,**Telnet**, raw **TCP**
    - Example:

    ```bash
       curl telnet://host:25
    ```

  - **Advanced tools**|
    - `ethtool` important in performance troubleshooting. Check **NIC** driver, speed, offloading
    - Installing:

    ```bash
       sudo apt install ethtool
    ```

    - `bmon` Bandwidth monitor in terminal. Very lightweight in real-time monitoring
    - Installing:

    ```bash
       sudo apt install bmon
    ```

    - `iftop` Shows bandwidth usage per connection
    - Installing:

    ```bash
       sudo apt install iftop
    ```

    - `bridge-utils` Legacy by useful
    - Installiing:

    ```bash
       sudo apt install bridge-utils
    ```

  - **Modern feeling**
    - `gping` Graphical ping in terminal
    - Installing:

    ```bash
       sudo apt install gping
    ```

    - `bandwhich` Shows which process uses bandwidth

  - Managing and configuring  **Logs** files
  - Managing and Installing **LXC/LXD** containers on **Debian/Ubuntu**
  - Some examples of **MOTD** graphics adn information scripts  
  - Scripts for auto installing and updating **Nginx** web server from source.
  - Installing and management **Proxmox** virtualization environment
  - Installing or Updating bash script for **Rclone**.
  - Installing and managing **Squid** proxy server on **Linux** (**Debian/Ubuntu**)
  - Installing and managing **Open ZFS** on **Debian/Ubuntu**  

---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Scripting](../)
