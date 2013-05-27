apt-get -y install libyaml-dev libgdbm-dev libncurses5-dev libffi-dev git-core redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev

# Make sure python2 resolves to python
ln -s /usr/bin/python /usr/bin/python2

# Create a git user for Gitlab
sudo adduser --disabled-login --gecos 'GitLab' git

# Login as git
sudo su git

# Go to home directory
cd /home/git

# Clone gitlab shell
git clone https://github.com/gitlabhq/gitlab-shell.git

cd gitlab-shell

# switch to right version
git checkout v1.4.0

cp config.yml.example config.yml

# Do setup
./bin/install