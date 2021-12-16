#!/bin/bash
clear
echo -n "Сделать ветер [Y/n]?"
read -n1 update

if [[ "$update" = "Y" || "$update" = "y" ]]
then
echo
echo "Установка nginx..."
echo
echo
	sudo apt install nginx -y
	sudo systemctl start nginx
	sudo systemctl enable nginx
	sudo systemctl status nginx --no-pager
echo
echo "Версия: "
	nginx -v
echo
echo "Запись разрешений..."
	sudo chown www-data:www-data /usr/share/nginx/html -R
	sleep 2s

echo "ГОТОВО!"
	sleep 1s
echo
echo "Установка MySql Database Server..."
	sleep 1s
	sudo apt install mysql-server -y
	sudo systemctl status mysql --no-pager
	sudo systemctl enable mysql
	sleep 1s
	clear
echo "Установка MySql Security script..."
	sudo mysql_secure_installation
	sleep 2s
echo "Установка PHP7.3 Repository..."
	sleep 1s
	yes '' | sudo add-apt-repository ppa:ondrej/php
echo
echo "Обновление системы..."
	sleep 1s
	sudo apt-get update
echo "Установка PHP7.3..."
	sleep 1s
	sudo apt install php7.3-fpm php7.3-mysql -y
	sudo systemctl start php7.3-fpm
	sudo systemctl enable php7.3-fpm
	sudo systemctl status php7.3-fpm --no-pager
echo

echo "Установка дополнительных модулей для PHP7.3"
    slep 2s
    sudo apt install php7.3-mbstring php7.3-xml php7.3-bcmath
    sudo apt install composer
echo
echo "Готово" 

echo "Настройка проэкта Laravel"
echo
	read -p "Название для проэкта: " project_name
	read -p "Название домена: " domain_name
	cd $HOME
	composer create-project --prefer-dist  laravel/laravel $project_name
	cd $project_name
	sudo mv $HOME/$project_name /var/www/$project_name
	sudo chown -R www-data.www-data /var/www/$project_name/storage
	sudo chown -R www-data.www-data /var/www/$project_name/bootstrap/cache

	sudo echo "
	server {
    	listen 80;
    	server_name $domain_name;
    	root /var/www/$project_name/public;

    	add_header X-Frame-Options \"SAMEORIGIN\";
    	add_header X-XSS-Protection \"1; mode=block\";
    	add_header X-Content-Type-Options \"nosniff\";

    	index index.html index.htm index.php;

    	charset utf-8;

    	location / {
    	    try_files \$uri \$uri/ /index.php?\$query_string;
    	}

    	location = /favicon.ico { access_log off; log_not_found off; }
    	location = /robots.txt  { access_log off; log_not_found off; }

    	error_page 404 /index.php;

    	location ~ \.php$ {
    	    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    	    fastcgi_index index.php;
    	    fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
    	    include fastcgi_params;
    	}

    	location ~ /\.(?!well-known).* {
    	    deny all;
    	}
	}	
	" > /etc/nginx/sites-available/$domain_name
	sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
	sleep 2s
	sudo nginx -t
	sudo systemctl restart nginx
echo "Готово!"
echo
echo
echo "Welcome to: "
    curl icanhazip.com -4
	
echo

fi