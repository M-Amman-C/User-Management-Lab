# User 1
sudo useradd -m -d /home/frontend/alice -s /bin/sh alice
echo "alice:Alice@123" | sudo chpasswd &>/dev/null

echo -e "\nUser 1 Created\n"


# User 2
sudo useradd -M -s /sbin/nologin -e $(date -d "+15 days" +%Y-%m-%d) bob

echo -e "\nUser 2 Created\n"

# User 3
sudo useradd -m -c "Backend Developer" carol
sudo usermod -L carol

echo -e "\nUser 3 Created\n"

# User 4
sudo useradd -m -s /bin/bash dave
sudo chage -d 0 dave  
sudo chage -M 30 -I 5 dave
echo "dave:Dave@QA1" | sudo chpasswd &>/dev/null

echo -e "\nUser 4 Created\n"

# User 5
sudo groupadd security  
sudo useradd -m -d /opt/security/eve -s /bin/bash -g security eve
echo "eve:Sport@123" | sudo chpasswd

echo -e "\nUser 5 Created\n"


