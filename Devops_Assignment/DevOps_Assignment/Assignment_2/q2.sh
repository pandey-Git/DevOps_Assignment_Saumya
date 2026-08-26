#!/bin/bash

user=$(last | head -2 | tail -1 | awk '{print $1}')

echo "Last logged in user: $user"

echo "Files owned by $user:"
find ~ -user $user

echo "Login time:"
last | head -2 | tail -1
