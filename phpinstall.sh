# install lamp server
sudo apt-get install lamp-server^ 

# download composer
curl -sS https://getcomposer.org/installer | php
# move composer to /usr
sudo mv composer.phar /usr/local/bin/composer
# fix permissions
sudo chmod +x /usr/local/bin/composer

# install laravel dependencies
sudo apt-get install php-mbstring php-xml -y

# to create laravel project use:
# composer create-project --prefer-dist laravel/laravel [project-name]
# and to run the local server use:
# php artisan serve --host=[IP] --port=[port]
