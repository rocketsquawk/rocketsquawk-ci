# Install TeamCity pre-reqs ... WTF? No more Sun JRE?!
#apt-get -y install sun-java6-jre
echo "### Installing java (TeamCity pre-req) ###"
apt-get -y install openjdk-6-jre-headless

# Get TeamCity 7.1.5
echo "### Downloading and inflating standalone TeamCity server ###"
wget http://download-ln.jetbrains.com/teamcity/TeamCity-7.1.5.tar.gz
tar zxf TeamCity-7.1.5.tar.gz

echo "### Cleaning up the TeamCity tarball ###"
rm TeamCity-7.1.5.tar.gz
