#!/bin/bash

# Ensure that EC2_PUBLIC_DNS is passed as an environment variable
echo "Using EC2 Public DNS: ${EC2_PUBLIC_DNS}"

# Original script's first argument is the RDS endpoint without the port
ORIGINAL_DB_HOST=$1
DB_PORT=3306
DB_NAME=mydb
DB_USER=admin

# SSH Tunnel Setup
SSH_USER="ec2-user"
SSH_HOST=${EC2_PUBLIC_DNS}  # Use the EC2 Public DNS provided as an environment variable
SSH_KEY_PATH="EC2KeyPair.pem"  # Ensure this path is correct relative to where the script is executed
LOCAL_PORT=3307  # Local port for SSH tunneling

# Establish the SSH tunnel with verbose output redirected for debugging
echo "Establishing SSH tunnel..."
ssh -f -N -L ${LOCAL_PORT}:${ORIGINAL_DB_HOST}:${DB_PORT} -i ${SSH_KEY_PATH} ${SSH_USER}@${SSH_HOST} &
SSH_TUNNEL_PID=$!

# Setup trap to ensure the SSH tunnel is killed on script exit
trap "echo 'Checking and killing SSH Tunnel PID ${SSH_TUNNEL_PID}'; if ps -p ${SSH_TUNNEL_PID} > /dev/null; then kill ${SSH_TUNNEL_PID}; fi" EXIT

# Wait a bit to ensure the tunnel is established
sleep 5

# For the duration of this script, DB_HOST is set to localhost because of SSH tunneling
DB_HOST="127.0.0.1"

# Fetch the password from AWS Secrets Manager
echo "Fetching database password from AWS Secrets Manager..."
SECRET_STRING=$(aws secretsmanager get-secret-value --secret-id db_password --query SecretString --output text)
DB_PASS=$(echo "${SECRET_STRING}" | jq -r .password)

# Use the DB_PASS in your mysql command, connecting through the tunnel
for USER_NAME in "${@:2}"; do
    echo "Creating user '${USER_NAME}' and granting privileges..."
    mysql -h "${DB_HOST}" -P "${LOCAL_PORT}" -u "${DB_USER}" -p"${DB_PASS}" -e "CREATE USER IF NOT EXISTS '${USER_NAME}'@'%' IDENTIFIED BY 'UserPassword!23'; GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${USER_NAME}'@'%'; FLUSH PRIVILEGES;"

    if [ $? -eq 0 ]; then
        echo "Successfully created and granted privileges to user '${USER_NAME}'"
    else
        echo "Failed to create or grant privileges to user '${USER_NAME}'"
    fi
done
