#!/bin/bash
# Ensure the script runs as root

if [ "$EUID" -ne 0 ]; then
  echo "student" | sudo -S bash "$0" "$@" 2>/dev/null
  exit $?  # Exit after re-invoking
fi

# Initialize grading results
results="{\"maximum_marks\": 100, \"obtained_maximum_marks\": 0, \"tasks\": []}"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
  sudo yum install -y jq &> /dev/null
fi

# Ensure sshpass is installed
if ! command -v sshpass &> /dev/null; then
  sudo yum install -y sshpass &> /dev/null
fi

### Test 1: User 1 existence and properties ###
test1_obtained_marks=0
failed_props=()

# Check if user 'alice' exists
if getent passwd alice &> /dev/null; then
  test1_obtained_marks=$((test1_obtained_marks + 5))
else
  failed_props+=("Existence")
fi

# Check home directory
if [ "$(getent passwd alice | cut -d: -f6)" = "/home/frontend/alice" ] && [ -d "/home/frontend/alice" ]; then
  test1_obtained_marks=$((test1_obtained_marks + 5))
else
  failed_props+=("Home")
fi

# Check login shell
if [ "$(getent passwd alice | cut -d: -f7)" = "/bin/sh" ]; then
  test1_obtained_marks=$((test1_obtained_marks + 5))
else
  failed_props+=("Shell")
fi

# Check password via SSH
if sshpass -p "Alice@123" ssh -o StrictHostKeyChecking=no alice@localhost exit &> /dev/null; then
  test1_obtained_marks=$((test1_obtained_marks + 5))
else
  failed_props+=("Password")
fi

if [ "$test1_obtained_marks" -eq 20 ]; then
  test1_message="User 1 set-up correctly"
else
  test1_message="User 1 not set-up correctly: ${failed_props[*]}"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 1, \"name\": \"User 1\", \"obtained_marks\": $test1_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test1_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test1_obtained_marks")

### Test 2: User 2 existence and properties ###
test2_obtained_marks=0
failed_props=()

if getent passwd bob &> /dev/null; then
  test2_obtained_marks=$((test2_obtained_marks + 5))
else
  failed_props+=("Existence")
fi

# Home existence using custom function logic
if [ "$(getent passwd bob | cut -d: -f6)" = "/home/bob" ] && [ -d "/home/bob" ]; then
  test2_obtained_marks=$((test2_obtained_marks + 5))
else
  failed_props+=("Home")
fi

# Shell check
if [ "$(getent passwd bob | cut -d: -f7)" = "/sbin/nologin" ]; then
  test2_obtained_marks=$((test2_obtained_marks + 5))
else
  failed_props+=("Shell")
fi

# Expiry check: 15 days from now
expiry=$(chage -l bob | grep "Account expires" | cut -d: -f2 | xargs)
expected_date=$(date -d "+15 days" +"%b %d, %Y")
if [ "$expiry" = "$expected_date" ]; then
  test2_obtained_marks=$((test2_obtained_marks + 5))
else
  failed_props+=("Expiry")
fi

if [ "$test2_obtained_marks" -eq 20 ]; then
  test2_message="User 2 set-up correctly"
else
  test2_message="User 2 not set-up correctly: ${failed_props[*]}"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 2, \"name\": \"User 2\", \"obtained_marks\": $test2_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test2_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test2_obtained_marks")

### Test 3: User 3 existence and properties ###
test3_obtained_marks=0
failed_props=()

if getent passwd carol &> /dev/null; then
  test3_obtained_marks=$((test3_obtained_marks + 5))
else
  failed_props+=("Existence")
fi

# Home directory
if [ "$(getent passwd carol | cut -d: -f6)" = "/home/carol" ] && [ -d "/home/carol" ]; then
  test3_obtained_marks=$((test3_obtained_marks + 5))
else
  failed_props+=("Home")
fi

# GECOS/comment field
if [ "$(getent passwd carol | cut -d: -f5)" = "Backend Developer" ]; then
  test3_obtained_marks=$((test3_obtained_marks + 5))
else
  failed_props+=("Comment")
fi

# Locked account?
status=$(passwd -S carol | awk '{print $2}')
if [[ "$status" = "L" || "$status" = "LK" ]]; then
  test3_obtained_marks=$((test3_obtained_marks + 5))
else
  failed_props+=("Lock Status")
fi

if [ "$test3_obtained_marks" -eq 20 ]; then
  test3_message="User 3 set-up correctly"
else
  test3_message="User 3 not set-up correctly: ${failed_props[*]}"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 3, \"name\": \"User 3\", \"obtained_marks\": $test3_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test3_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test3_obtained_marks")

### Test 4: User 4 existence and properties ###
test4_obtained_marks=0
failed_props=()

if getent passwd dave &> /dev/null; then
  test4_obtained_marks=$((test4_obtained_marks + 5))
else
  failed_props+=("Existence")
fi

# Shell
if [ "$(getent passwd dave | cut -d: -f7)" = "/bin/bash" ]; then
  test4_obtained_marks=$((test4_obtained_marks + 5))
else
  failed_props+=("Shell")
fi

# chage policy: max 30 days, inactive 5 days
max_days=$(chage -l dave | grep "Maximum" | cut -d: -f2 | xargs)
inactive=$(chage -l dave | grep "inactive" | cut -d: -f2 | xargs)
if [ "$max_days" = "30" ] && [ "$inactive" = "5" ]; then
  test4_obtained_marks=$((test4_obtained_marks + 5))
else
  failed_props+=("Chage Policy")
fi

# Password via SSH
if sshpass -p "Dave@QA1" ssh -o StrictHostKeyChecking=no dave@localhost exit &> /dev/null; then
  test4_obtained_marks=$((test4_obtained_marks + 5))
else
  failed_props+=("Password")
fi

if [ "$test4_obtained_marks" -eq 20 ]; then
  test4_message="User 4 set-up correctly"
else
  test4_message="User 4 not set-up correctly: ${failed_props[*]}"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 4, \"name\": \"User 4\", \"obtained_marks\": $test4_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test4_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test4_obtained_marks")

### Test 5: User 5 existence and properties ###
test5_obtained_marks=0
failed_props=()

if getent passwd eve &> /dev/null; then
  test5_obtained_marks=$((test5_obtained_marks + 5))
else
  failed_props+=("Existence")
fi

# Home directory
if [ "$(getent passwd eve | cut -d: -f6)" = "/opt/security/eve" ] && [ -d "/opt/security/eve" ]; then
  test5_obtained_marks=$((test5_obtained_marks + 5))
else
  failed_props+=("Home")
fi

# Group membership
if id -nG eve | grep -qw security; then
  test5_obtained_marks=$((test5_obtained_marks + 5))
else
  failed_props+=("Group")
fi

# Password via SSH
if sshpass -p "Sport@123" ssh -o StrictHostKeyChecking=no eve@localhost exit &> /dev/null; then
  test5_obtained_marks=$((test5_obtained_marks + 5))
else
  failed_props+=("Password")
fi

if [ "$test5_obtained_marks" -eq 20 ]; then
  test5_message="User 5 set-up correctly"
else
  test5_message="User 5 not set-up correctly: ${failed_props[*]}"
fi

results=$(echo "$results" | jq ".tasks += [{\"no\": 5, \"name\": \"User 5\", \"obtained_marks\": $test5_obtained_marks, \"maximum_marks\": 20, \"message\": \"$test5_message\"}]")
results=$(echo "$results" | jq ".obtained_maximum_marks += $test5_obtained_marks")

# Output final results as JSON
echo "$results" | jq
