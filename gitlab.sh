# Install a bunch of pre-reqs
echo "### Installing a bunch of stuff that GitLab requires ###"
apt-get -y install libyaml-dev libgdbm-dev libncurses5-dev libffi-dev git-core redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev

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

# Install gitlab itself
echo "### Installing GitLab itself ###"
su git -l -c 'git clone https://github.com/gitlabhq/gitlabhq.git gitlab'
su git -l -c 'cd gitlab && git checkout 5-2-stable && cp config/gitlab.yml.example config/gitlab.yml'