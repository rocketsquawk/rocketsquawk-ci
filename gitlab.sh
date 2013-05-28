# Install a bunch of pre-reqs
echo "### Installing a bunch of stuff that GitLab requires ###"
apt-get -y install libyaml-dev libgdbm-dev libncurses5-dev libffi-dev git-core redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev
gem install bundler --no-ri --no-rdoc

# Make sure python2 resolves to python
echo "### Linking python2 to python ###"
ln -s /usr/bin/python /usr/bin/python2

# Create a git user for Gitlab
echo "### Creating GitLab user 'git' ###"
adduser --disabled-login --gecos 'GitLab' git

# Install gitlab-shell into the new git user's home dir
echo "### Installing gitlab-shell ###"
su git -l -c 'git clone https://github.com/gitlabhq/gitlab-shell.git'
su git -l -c 'cd gitlab-shell && git checkout v1.4.0 && cp config.yml.example config.yml && ./bin/install'

# Install MySql and set the root password to 'rocketsquawk'
echo "### Installing MySql ###"
echo "mysql-server-5.5 mysql-server/root_password password rocketsquawk" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password rocketsquawk" | debconf-set-selections
apt-get install -y mysql-server mysql-client libmysqlclient-dev

# Create the gitlab DB
echo "### Creating GitLab DB ###"
cat <<EOF > ./create_db.sql
CREATE USER 'gitlab'@'localhost' IDENTIFIED BY 'rocketsquawk';
CREATE DATABASE IF NOT EXISTS gitlabhq_production DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON gitlabhq_production.* TO gitlab@localhost;
EOF

mysql -u root -procketsquawk -e 'source create_db.sql'
rm ./create_db.sql

# Install gitlab itself
echo "### Installing GitLab itself ###"
su git -l -c 'git clone https://github.com/gitlabhq/gitlabhq.git gitlab'
su git -l -c 'cd gitlab && git checkout 5-2-stable && cp config/gitlab.yml.example config/gitlab.yml'

# Make sure to change "localhost" to the fully-qualified domain name of your
# host serving GitLab where necessary
#sudo -u git -H vim config/gitlab.yml

# Make sure GitLab can write to the log/ and tmp/ directories
#sudo chown -R git log/
#sudo chown -R git tmp/
#sudo chmod -R u+rwX  log/
#sudo chmod -R u+rwX  tmp/

# Create directory for satellites
su git -l -c 'mkdir /home/git/gitlab-satellites'

# Create directories for sockets/pids and make sure GitLab can write to them
su git -l -c 'mkdir /home/git/gitlab/tmp/pids/ && mkdir /home/git/gitlab/tmp/sockets/'
chmod -R u+rwX /home/git/gitlab/tmp/pids/
chmod -R u+rwX /home/git/gitlab/tmp/sockets/

# Create public/uploads directory otherwise backup will fail
su git -l -c 'mkdir /home/git/gitlab/public/uploads'
chmod -R u+rwX /home/git/gitlab/public/uploads

# Copy the example Puma config
su git -l -c 'cp /home/git/gitlab/config/puma.rb.example /home/git/gitlab/config/puma.rb'

# Configure Git global settings for git user, useful when editing via web
# Edit user.email according to what is set in gitlab.yml
su git -l -c 'git config --global user.name "GitLab" && git config --global user.email "gitlab@localhost"'

# Mysql
su git -l -c 'cp /home/git/gitlab/config/database.yml.mysql /home/git/gitlab/config/database.yml'

# Install gems
gem install charlock_holmes -v '0.6.9.4' --no-ri --no-rdoc

# For MySQL (note, the option says "without")
sudo -u git -H bundle install --deployment --without development test postgres
sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production

cp lib/support/init.d/gitlab /etc/init.d/gitlab
chmod +x /etc/init.d/gitlab

# Make GitLab start on boot:
#update-rc.d gitlab defaults 21

# Let's try this thing out
/etc/init.d/gitlab restart
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

apt-get -y install nginx

cp /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab
ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

# Make sure to edit the config file to match your setup:

# **YOUR_SERVER_FQDN** to the fully-qualified
# domain name of your host serving GitLab. Also, replace
# the 'listen' line with the following:
#   listen 80 default_server;         # e.g., listen 192.168.1.1:80;
#sudo vim /etc/nginx/sites-available/gitlab

# Restart
sudo service nginx restart