sudo ln -s /srv/myapp/nginx/myapp.conf /etc/nginx/sites-enabled/myapp.conf
sudo nginx -t
sudo systemctl reload nginx
