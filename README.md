# User Management

**Description**:  
Learn to manage user accounts in Linux by creating users with custom shells, directories, login settings, and password policies.

---

## Step - 1: User 1: Alice (Frontend Developer)

**Task**:  
- Create a user named `alice`  
- Set the login shell to `/bin/sh`  
- Ensure the account is created with a custom home directory at `/home/frontend/alice`  
- Set a password as `Alice@123`

**Solution Box**  
Use `useradd` to create a user named `alice` with:  
- Login shell as `/bin/sh`  
- Home directory set to `/home/frontend/alice`  
- Set a password

**Commands**:
```bash
sudo useradd -m -d /home/frontend/alice -s /bin/sh alice  
sudo passwd alice  
# Enter password: Alice@123
```

## Step - 2: User 2: Bob (DevOps Intern)

**Task**:  
- Create a user named `bob`  
- Assign `/sbin/nologin` shell  
- Do not create a home directory  
- Set an expiry date for the account to be 15 days from today  

**Solution Box**  
- Shell set to `/sbin/nologin` to prevent login (option `-s` with `useradd`)  
- No home directory created (option `-M`)  
- Expiry date set using `-e` option with a date 15 days from today  


**Commands**:
```bash
sudo useradd -M -s /sbin/nologin -e $(date -d "+15 days" +%Y-%m-%d) bob  
```

## Step - 3: User 3: Carol (Backend Developer)

**Task**:  
- Create a user named `carol`  
- Ensure the home directory is `/home/carol`  
- Lock the account immediately after creation  
- Add a comment/description: "Backend Developer"  

**Solution Box**  
- Home directory set to `/home/carol`  
- Add a description (comment): "Backend Developer"  
- Lock the account immediately after creation  

**Commands**:
```bash
sudo useradd -m -c "Backend Developer" carol  
sudo usermod -L carol  
```

## Step - 4: User 4: Dave (QA Engineer)

**Task**:  
- Create a user named `dave`  
- Set login shell to `/bin/bash`  
- Set a temporary password as `Dave@QA1`  
- Add a password policy:  
  - Passwords must expire every 30 days  
  - Users must change password at first login  
  - Account should be inactive after 5 days of password expiry  

**Solution Box**  
- Create user `dave` with login shell `/bin/bash` using option `-s`  
- Set a temporary password  
- Make password expire every 30 days  
- Require password change at first login  
- Make account inactive after 5 days of password expiry  

**Commands**:
```bash
sudo useradd -m -s /bin/bash dave  
sudo passwd dave  
sudo chage -d 0 dave  
sudo chage -M 30 -I 5 dave  
```

## Step - 5: User 5: Eve (Security Analyst)

**Task**:  
- Create a user named `eve`  
- Assign a custom home directory at `/opt/security/eve`  
- Create and add Eve to a new secondary group called `security`  
- Use `/bin/bash` as the shell  
- Set password for `eve` as `Sport@123`  

**Solution Box**  
- Create a group named `security`  
- Create user `eve` with:  
  - Home directory at `/opt/security/eve` using `-m` option  
  - Add to group `security` with `-g` option  
  - Set shell to `/bin/bash` with `-s` option  
- Set password for `eve`  

**Commands**:
```bash
sudo groupadd security  
sudo useradd -m -d /opt/security/eve -s /bin/bash -g security eve  
sudo passwd eve  
# Enter password: Sport@123  
```

## Automated Solution Script

```bash
# User 1
sudo useradd -m -d /home/frontend/alice -s /bin/sh alice
echo "alice:Alice@123" | sudo chpasswd

# User 2
sudo useradd -M -s /sbin/nologin -e $(date -d "+15 days" +%Y-%m-%d) bob

# User 3
sudo useradd -m -c "Backend Developer" carol
sudo usermod -L carol

# User 4
sudo useradd -m -s /bin/bash dave
sudo chage -d 0 dave  
sudo chage -M 30 -I 5 dave
echo "dave:Dave@QA1" | sudo chpasswd

# User 5
sudo groupadd security  
sudo useradd -m -d /opt/security/eve -s /bin/bash -g security eve
echo "eve:Sport@123" | sudo chpasswd
```
