#!/bin/bash

userdel -r alice &>/dev/null
userdel -r bob &>/dev/null
userdel -r carol &>/dev/null
userdel -r dave &>/dev/null
userdel -r eve &>/dev/null

groupdel security

echo -e "\n\nAll users deleted successfully\n\n"
