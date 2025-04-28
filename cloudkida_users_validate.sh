#!/bin/bash

# Functions
results="{\"maximum_marks\": 100, \"obtained_maximum_marks\": 0, \"tasks\": []}"

if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt install -y jq
fi

if ! command -v sshpass &> /dev/null; then
    echo "sshpass not found, installing..."
    sudo apt install -y sshpass
fi

check_user() {
    username=$1
    id "$username" &>/dev/null && return 0 || return 1
}

check_home() {
    username=$1
    expected_home=$2
    actual_home=$(getent passwd "$username" | cut -d: -f6)
    if [[ -d "$actual_home" ]]; then
        [[ "$expected_home" == "$actual_home" ]] && return 0 || return 1
    else
        return 1
    fi
}



home_exist() {
    username=$1
    home=$(getent passwd "$username" | cut -d: -f6)
    if ls -l /home/ | grep /home/bob ; then
	    return 1
    else
	    return 0
    fi
}


check_shell() {
    username=$1
    expected_shell=$2
    actual_shell=$(getent passwd "$username" | cut -d: -f7)
    [[ "$expected_shell" == "$actual_shell" ]] && return 0 || return 1
}


check_expiry() {
    username=$1
    expected_days=$2
    expiry=$(chage -l "$username" | grep "Account expires" | cut -d: -f2 | xargs)
    expected_date=$(date -d "+$expected_days days" +"%b %d, %Y")
    [[ "$expiry" == "$expected_date" ]]
}

check_comment(){
    username=$1
    expected_comment=$2
    actual_comment=$(getent passwd "$username" | cut -d: -f5)
    [[ "$expected_comment" == "$actual_comment" ]]
}


check_locked() {
    username=$1
    status=$(passwd -S "$username" | awk '{print $2}')
    [[ "$status" == "L" || "$status" == "LK" ]]
}



check_chage_policy() {
    username=$1
    max_days=$2
    inactive_days=$3

    actual_max=$(chage -l "$username" | grep "Maximum" | awk -F: '{print $2}' | xargs)
    expiry_date=$(chage -l "$username" | grep "Password expires" | awk -F: '{print $2}' | xargs)
    inactive_date=$(chage -l "$username" | grep "inactive" | awk -F: '{print $2}' | xargs)

    expiry_epoch=$(date -d "$expiry_date" +%s)
    inactive_epoch=$(date -d "$inactive_date" +%s)

    actual_inactive=$(( (inactive_epoch - expiry_epoch) / 86400 ))

    [[ "$actual_max" == "$max_days" ]] && [[ "$actual_inactive" == "$inactive_days" ]]
}



check_group() {
    username=$1
    group=$2
    id -nG "$username" | grep -qw "$group"
}


check_password() {
    local username=$1
    local expected_password=$2
    local result

    # Try to authenticate using sshpass (which can automate the password entry in SSH)
    result=$( sshpass -p $expected_password ssh -o StrictHostKeyChecking=no $username@localhost exit 2>&1)

    echo $result
    # Check the result for success or failure
    if [[ "$result" =~ "Permission denied" ]]; then
        return 1  # Password incorrect
    else
        return 0  # Password correct
    fi
}


#---------------------------------------------------------------------Tests-------------------------------------------------------------

#-------------------------------------------------User 1---------------------------------------------

test1_obtained_marks=0
failed_properties=()

if check_user alice; then
    test1_obtained_marks=5

    if check_home alice "/home/frontend/alice"; then
        test1_obtained_marks=$((test1_obtained_marks + 5))
    else
        failed_properties+=("Home")
    fi

    if check_shell alice "/bin/sh"; then
        test1_obtained_marks=$((test1_obtained_marks + 5))
    else
        failed_properties+=("Shell")
    fi

    # ./alice_passwd.sh  # Uncomment if needed
    if check_password alice "Alice@123"; then
        test1_obtained_marks=$((test1_obtained_marks + 5))  # Add marks if password is correct
    else
        failed_properties+=("Password")
    fi

    if [ "$test1_obtained_marks" -eq 20 ]; then
        test1_status="pass"
        test1_message="User 1 set-up correctly"
    else
        test1_status="fail"
        test1_message="User 1 not set-up correctly: ${failed_properties[*]}"
    fi
else
    test1_status="fail"
    test1_message="User 1 does not exist"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 1, \"name\": \"User 1\", \"obtained_marks\": $test1_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test1_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test1_obtained_marks")



#-----------------------------------------------User 2------------------------------------------------



test2_obtained_marks=0
failed_properties=()

if check_user bob; then
    test2_obtained_marks=5

    if home_exist bob "/home/bob"; then
        test2_obtained_marks=$((test2_obtained_marks + 5))
    else
        failed_properties+=("Home")
    fi

    if check_shell bob "/sbin/nologin"; then
        test2_obtained_marks=$((test2_obtained_marks + 5))
    else
        failed_properties+=("Shell")
    fi

    if check_expiry bob 15; then
        test2_obtained_marks=$((test2_obtained_marks + 5))
    else
        failed_properties+=("Expiry")
    fi

    if [ "$test2_obtained_marks" -eq 20 ]; then
        test2_status="pass"
        test2_message="User 2 set-up correctly"
    else
        test2_status="fail"
        test2_message="User 2 not set-up correctly: ${failed_properties[*]}"
    fi
else
    test2_status="fail"
    test2_message="User 2 does not exist"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 2, \"name\": \"User 2\", \"obtained_marks\": $test2_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test2_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test2_obtained_marks")


#-----------------------------------------------User 3------------------------------------------------



test3_obtained_marks=0
failed_properties=()

if check_user carol; then
    test3_obtained_marks=5

    if check_home carol "/home/carol"; then
        test3_obtained_marks=$((test3_obtained_marks + 5))
    else
        failed_properties+=("Home")
    fi

    if check_comment carol "Backend Developer"; then
        test3_obtained_marks=$((test3_obtained_marks + 5))
    else
        failed_properties+=("Comment")
    fi

    if check_locked carol; then
        test3_obtained_marks=$((test3_obtained_marks + 5))
    else
        failed_properties+=("Lock Status")
    fi

    if [ "$test3_obtained_marks" -eq 20 ]; then
        test3_status="pass"
        test3_message="User 3 set-up correctly"
    else
        test3_status="fail"
        test3_message="User 3 not set-up correctly: ${failed_properties[*]}"
    fi
else
    test3_status="fail"
    test3_message="User 3 does not exist"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 3, \"name\": \"User 3\", \"obtained_marks\": $test3_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test3_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test3_obtained_marks")



#-----------------------------------------------User 4------------------------------------------------


test4_obtained_marks=0
failed_properties=()

if check_user dave; then
    test4_obtained_marks=5

    if check_shell dave "/bin/bash"; then
        test4_obtained_marks=$((test4_obtained_marks + 5))
    else
        failed_properties+=("Shell")
    fi

    if check_chage_policy dave 30 5; then
        test4_obtained_marks=$((test4_obtained_marks + 5))
    else
        failed_properties+=("Chage Policy")
    fi

    # ./dave_passwd.sh  # Uncomment if needed
    if check_password dave "Dave@QA1"; then
        test1_obtained_marks=$((test1_obtained_marks + 5))  # Add marks if password is correct
    else
        failed_properties+=("Password")
    fi

    if [ "$test4_obtained_marks" -eq 20 ]; then
        test4_status="pass"
        test4_message="User 4 set-up correctly"
    else
        test4_status="fail"
        test4_message="User 4 not set-up correctly: ${failed_properties[*]}"
    fi
else
    test4_status="fail"
    test4_message="User 4 does not exist"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 4, \"name\": \"User 4\", \"obtained_marks\": $test4_obtained_marks, \"maximum_marks\": 15, \"message\": \"$test4_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test4_obtained_marks")



#-----------------------------------------------User 5------------------------------------------------


test5_obtained_marks=0
failed_properties=()

if check_user eve; then
    test5_obtained_marks=5

    if check_home eve "/opt/security/eve"; then
        test5_obtained_marks=$((test5_obtained_marks + 5))
    else
        failed_properties+=("Home")
    fi

    if check_group eve "security"; then
        test5_obtained_marks=$((test5_obtained_marks + 5))
    else
        failed_properties+=("Group")
    fi

    # ./eve_passwd.sh  # Uncomment if needed
    if check_password eve "Sport@123"; then
        test1_obtained_marks=$((test1_obtained_marks + 5))  # Add marks if password is correct
    else
        failed_properties+=("Password")
    fi

    if [ "$test5_obtained_marks" -eq 20 ]; then
        test5_status="pass"
        test5_message="User 5 set-up correctly"
    else
        test5_status="fail"
        test5_message="User 5 not set-up correctly: ${failed_properties[*]}"
    fi
else
    test5_status="fail"
    test5_message="User 5 does not exist"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 5, \"name\": \"User 5\", \"obtained_marks\": $test5_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test5_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test5_obtained_marks")




echo "$results" | jq

