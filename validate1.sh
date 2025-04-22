#Functions
sudo apt install expect -y &>/dev/null


check_user(){
	username=$1
	id "$username" &>/dev/null && echo "User exists" || echo "User does not exist"	
}

check_home(){
	username=$1
	expected_home=$2
	actual_home=$(getent passwd $username | cut -d: -f6)
	[[ -d "$actual_home" ]] && {
		[[ "$expected_home" == "$actual_home" ]] && echo "User home correct" || echo "User home incorrect"
	} || echo "Home directory does not exist"
}

check_shell(){
	username=$1
	expected_shell=$2
	actual_shell=$(getent passwd $username | cut -d: -f7)
	[[ "$expected_shell" == "$actual_shell" ]] && echo "User shell correct" || echo "User shell incorrect"
}


check_comment(){
	username=$1
	expected_comment=$2
	actual_comment=$(getent passwd $username | cut -d: -f5)
	[[ "$expected_comment" == "$actual_comment" ]] && echo "User comment correct" || echo "User comment incorrect"
}

check_expiry() {
	local username="$1"
	local expected_days="$2"

	expiry=$(chage -l "$username" | grep "Account expires" | cut -d: -f2 | xargs)
	expected_date=$(date -d "+$expected_days days" +"%b %d, %Y")

	[[ "$expiry" == "$expected_date" ]] && echo "$username has correct expiry date" || echo "$username expiry date is incorrect"
}

check_locked() {
	local username="$1"
	status=$(passwd -S "$username" | awk '{print $2}')
	[[ "$status" == "L" ]] && echo "$username is locked" || echo "$username is NOT locked"
}

check_chage_policy() {
	username="$1"
	max_days="$2"
	inactive_days="$3"

	actual_max=$(chage -l "$username" | grep "Maximum" | awk -F: '{print $2}' | xargs)
	
	
	#------------------Calculate Inactive Days--------------------------------------------------
	
	expiry_date=$(chage -l "$username" | grep "Password expires" | awk -F: '{print $2}' | xargs)
	expiry_epoch=$(date -d "$expiry_date" +%s)

	inactive_date=$(chage -l "$username" | grep "inactive" | awk -F: '{print $2}' | xargs)
	inactive_epoch=$(date -d "$inactive_date" +%s)

	#-------------------------------------------------------------------------------------------

	actual_inactive=$(( ($inactive_epoch - $expiry_epoch) / 86400 ))


	[[ "$actual_max" == "$max_days" ]] && echo "$username has correct max days: $max_days" || echo "$username has incorrect max days: $actual_max"
  	[[ "$actual_inactive" == "$inactive_days" ]] && echo "$username has correct inactive days: $inactive_days" || echo "$username has incorrect inactive days: $actual_inactive"

}

check_group() {
	username=$1
	group=$2

	id -nG "$username" | grep -qw "$group" && echo "$username is in group $group" || echo "$username is not in group $group"
}

# User 1

echo -e "\n User 1"

check_user alice
id alice &>/dev/null && {
	check_home alice "/home/frontend/alice"
	check_shell alice "/bin/sh"
	./alice_passwd.sh
}


# User 2

echo -e "\n User 2"

check_user bob
id bob &>/dev/null && {
	check_home bob "/"
	check_shell bob "/sbin/nologin"
	check_expiry bob 15
}


# User 3

echo -e "\n User 3"

check_user carol
id carol &>/dev/null && {
	check_home carol "/home/carol"
	check_comment carol "Backend Developer"
	check_locked carol
}


# User 4

echo -e "\n User 4"

check_user dave
id dave &>/dev/null && {
	check_shell dave "/bin/bash"
	check_chage_policy dave 30 5
	./dave_passwd.sh
}


# User 5

echo -e "\n User 5"

check_user eve
id eve &>/dev/null && {
	check_home eve "/opt/security/eve"
	check_shell eve "/bin/bash"
	check_group eve "security"
	./eve_passwd.sh
}









