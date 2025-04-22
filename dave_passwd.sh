#!/usr/bin/expect

# Set the timeout to 10 seconds
set timeout 5

log_user 0

# Set the username, password, and server IP or hostname
set username "dave"
set password "Dave@QA1"
set server "localhost"

# Start the SSH connection
spawn ssh $username@$server

# Look for the password prompt and send the password
expect "password:"
send "$password\r"

# Handle the response
expect {
    # If login is successful, the prompt will be shown
    "*$username@" {
        send_user "Password for Dave correctly set\n"
    }
    
    # If authentication fails, it will show a message
    "Permission denied" {
        send_user "Login failed: Incorrect password\n"
    }
    
    # Timeout case
    timeout {
        send_user "Connection timeout or other error\n"
    }
}

# Exit the script
expect eof

