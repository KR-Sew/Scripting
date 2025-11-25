# <img width="48" height="48" src="https://img.icons8.com/external-tal-revivo-shadow-tal-revivo/48/external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo.png" alt="external-nginx-accelerates-content-and-application-delivery-improves-security-logo-shadow-tal-revivo"/> Configure NGINX for **ISP Manager** panel

[![Debian](https://img.shields.io/badge/Debian-607078?style=flat&logo=debian&logoColor=white&logoSize=auto&labelColor=a81d33)](https://www.debian.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-607078?style=flat&logo=ubuntu&logoColor=white&logoSize=auto&labelColor=e95420)](https://ubuntu.com/download)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=flat&logo=gnubash&logoColor=white&logoSize=auto&labelColor=black)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Let's put **ISP manager** behind your existing **Nginx** reverse-proxy using a subdomain such as `isp.mysite.com`, issue a **Let’s Encrypt** certificate for it using **Certbot**, and then proxy all traffic to the local port `1500` where **ISP manager** is running.

## 📂 Action chain

### - 📄 Create a file

```swift
  /etc/nginx/sites-available/isp.mysite.com.conf
```

### - 📄 Enable it

```swift
  sudo ln -s /etc/nginx/sites-available/isp.mysite.com.conf \
          /etc/nginx/sites-enabled/
```

### - 📄 Reload Nginx

```swift
  sudo nginx -t && sudo systemctl reload nginx && sudo systemctl status nginx
```

### - 📄 Issue a Let’s Encrypt certificate

```bash
  sudo certbot certonly --webroot -w /var/www/letsencrypt -d isp.mysite.com
```

 This will generate:

- `/etc/letsencrypt/live/isp.mysite.com/fullchain.pem`
- `/etc/letsencrypt/live/isp.mysite.com/privkey.pem`

After that, reload Nginx again:

```bash
  sudo nginx -t && sudo systemctl reload nginx && sudo systemctl status nginx
```

### - 



---

- 📄[README.md](ReadMe.md) # Project documentation

---

🔙 [back to 📂 Bash](../)
