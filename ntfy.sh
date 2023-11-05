#!/bin/bash

# Written by Kyser Clark
#
# KyserClark.com
# @KyserClark
# github.com/KyserClark
# linkedin.com/in/KyserClark/
#
# This tool makes ntfy more usable and easier for everyone to send push notifications
# from their terminal with fewer keystrokes.

SHOULD_NOTIFY=true
TEMP_MESSAGE=""

CONFIG_FILE="/etc/ntfy/server.yml"

safe_echo() {
  echo "$@" || return 0
}

# Function to update ntfy server base-url
update_base_url() {
# Check if IP is "0.0.0.0" and resolve to the actual IP address
  if [ "$IP" = "0.0.0.0" ]; then
    IP="$(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)"
  fi

  # Build the new base URL with the current IP and PORT
  local new_base_url="http://${IP}:${PORT}"
  
  # Use sed to update the base-url in the /etc/ntfy/server.yml
  # and add error handling for permission denied or other sed errors.
  if ! sed -i "s|^[[:space:]]*base-url:.*|base-url: ${new_base_url}|I" "$CONFIG_FILE" > /dev/null 2>&1; then
    return 1
  fi
}

# Function to load configuration or use defaults
load_config() {
  # Defaults
  local default_ip="$(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)"
  local default_port="80"
  local default_topic="Topic"
  local default_message="Command Finished"

  # Assume CONFIG_FILE is the path to your YAML configuration file
  local config_exists=false
  local ip_is_default=false

  if [ -f "$CONFIG_FILE" ]; then
    config_exists=true
    IP=$(python3 -c 'import yaml, sys; config = yaml.safe_load(open(sys.argv[1])); print(config.get("IP", "0.0.0.0"))' "$CONFIG_FILE")
    if [ "$IP" = "0.0.0.0" ]; then
  IP=$(ip route get 1.2.3.4 | awk '{print $7}' | head -n 1)
  ip_is_default=true
  # Use sed to update the IP in the configuration file to the actual IP address
  sed -i "s|^IP:.*|IP: $IP|" "$CONFIG_FILE" > /dev/null 2>&1
    fi
    PORT=$(python3 -c 'import yaml, sys; config = yaml.safe_load(open(sys.argv[1])); print(config.get("PORT", sys.argv[2]))' "$CONFIG_FILE" "$default_port")
    TOPIC=$(python3 -c 'import yaml, sys; config = yaml.safe_load(open(sys.argv[1])); print(config.get("TOPIC", sys.argv[2]))' "$CONFIG_FILE" "$default_topic")
    MESSAGE=$(python3 -c 'import yaml, sys; config = yaml.safe_load(open(sys.argv[1])); print(config.get("MESSAGE", sys.argv[2]))' "$CONFIG_FILE" "$default_message")
  else
    IP=$default_ip
    PORT=$default_port
    TOPIC=$default_topic
    MESSAGE=$default_message
  fi

  # If the IP was originally "0.0.0.0", update the base-url accordingly
  if [ "$config_exists" = true ] && [ "$ip_is_default" = true ]; then
  update_base_url # This will use the global IP and PORT variables updated above
  fi
}

save_config() {
  if ! python3 -c 'import sys
from ruamel.yaml import YAML
yaml = YAML()
yaml.preserve_quotes = True
try:
  with open(sys.argv[1], "r") as f:
    config = yaml.load(f)
  config["IP"] = sys.argv[2]
  config["PORT"] = sys.argv[3]
  config["TOPIC"] = sys.argv[4]
  config["MESSAGE"] = sys.argv[5]
  with open(sys.argv[1], "w") as f:
    yaml.dump(config, f)
except Exception as e:
  print(e)
  sys.exit(1)' "$CONFIG_FILE" "$IP" "$PORT" "$TOPIC" "$MESSAGE"; then
    safe_echo "Failed to update config. See the error message above."
    return 1
  fi
}

# Function to print the current configuration
print_settings() {
  safe_echo "Current settings:"
  safe_echo "IP: $IP"
  safe_echo "Port: $PORT"
  safe_echo "Topic: $TOPIC"
  safe_echo "Message: $MESSAGE"
}

# Function to start the ntfy service
start_ntfy() {
    SHOULD_NOTIFY=false
    NTFY_CONTAINER_NAME="ntfy_service_container"

    # Helper function to check if the error is permission-related
    check_permission_error() {
        local status=$1
        if [ $status -eq 1 ]; then
            safe_echo "Permission denied, try running with sudo."
            exit 1
        fi
    }

    # Check if any container with the given name exists (even if not running)
    DOCKER_ID=$(docker ps -aq --filter "name=$NTFY_CONTAINER_NAME" 2>/dev/null)
    local ps_exit_status=$?
    check_permission_error $ps_exit_status  # Check for permission error after running docker ps

    if [[ -z $DOCKER_ID ]]; then
        # If no container with that name exists, try to run a new container
        docker run --name $NTFY_CONTAINER_NAME -v /var/cache/ntfy:/var/cache/ntfy \
           -v /etc/ntfy:/etc/ntfy \
           -p "$PORT:80" \
           -itd \
           binwiederhier/ntfy \
           serve \
           --cache-file /var/cache/ntfy/cache.db > /dev/null 2>&1
        local run_exit_status=$?
        if [ $run_exit_status -ne 0 ]; then
            check_permission_error $run_exit_status  # Check for permission error after trying to run container
            safe_echo "Failed to start ntfy service. Error code: $run_exit_status."
            return 1
        fi
        safe_echo "ntfy service container started at http://$IP:$PORT"
    else
        safe_echo "A ntfy service container with name '$NTFY_CONTAINER_NAME' already exists."
    fi
}

# Function to stop the ntfy service
stop_ntfy() {
    NTFY_CONTAINER_NAME="ntfy_service_container"

    # Helper function to check if the error is permission-related
    check_permission_error() {
        local status=$1
        if [ $status -eq 1 ]; then
            safe_echo "Permission denied, try running with sudo."
            exit 1
        fi
    }

    # Check for running container with the given name
    DOCKER_ID=$(docker ps -q --filter "name=$NTFY_CONTAINER_NAME" 2>/dev/null)
    check_permission_error $?  # Check for permission error after running docker ps

    if [[ -n $DOCKER_ID ]]; then
        # Stop the running container
        docker stop $NTFY_CONTAINER_NAME >/dev/null 2>&1
        check_permission_error $?  # Check for permission error after trying to stop container
        safe_echo "ntfy service container stopped."
    else
        safe_echo "No running ntfy service container found."
    fi

    # Check for any container (stopped included) with the given name
    DOCKER_ID=$(docker ps -aq --filter "name=$NTFY_CONTAINER_NAME" 2>/dev/null)
    check_permission_error $?  # Check for permission error after running docker ps

    if [[ -n $DOCKER_ID ]]; then
        # Remove the stopped container without asking for confirmation
        docker rm $NTFY_CONTAINER_NAME >/dev/null 2>&1
        check_permission_error $?  # Check for permission error after trying to remove container
        safe_echo "ntfy service container removed."
    elif [ $? -eq 0 ]; then
        safe_echo "No ntfy service container found to remove."
    fi
}

# Function to display usage
usage() {
  SHOULD_NOTIFY=false
  safe_echo "ntfy tool written by Kyser Clark to make ntfy more usable and easier for everyone to send push notifications."
  safe_echo "from their terminal with fewer keystrokes."
  safe_echo ""
  safe_echo "Usage: ntfy [options]"
  safe_echo ""
  safe_echo "Typical usage: [command] && ntfy"
  safe_echo "Another example: [command] || ntfy -m 'Different Message' -t 'New_Topic'"
  safe_echo "Start tool with: sudo ntfy --start"
  safe_echo ""
  safe_echo "If you are running this tool in a virtual machine (VM), ensure your your network interface is in bridged mode."
  safe_echo ""
  safe_echo "Options:"
  safe_echo "  --start         Start the ntfy service"
  safe_echo "  --stop          Stop the ntfy service"
  safe_echo "  --ip            Set the IP address (can accept a valid interface name)"
  safe_echo "  --port          Set the port"
  safe_echo "  --message       Set the default message to send"
  safe_echo "  --topic         Set the default topic"
  safe_echo "  -m              Use a temporary message for the current command"
  safe_echo "  -t              Use a temporary topic for the current command"
  safe_echo "  --settings      Display current ntfy settings"
  safe_echo "  -h, --help      Display this help message"
}

# Load the configuration from the config file or use defaults
load_config

# Function to validate topic
validate_topic() {
  local topic="$1"
  # Ensure topic length is 20 characters or less
  if [ "${#topic}" -gt 20 ]; then
    safe_echo "Error: Topic must be 20 characters or less."
    exit 1
  fi

  # Ensure topic contains only URL-friendly characters (alphanumeric and some punctuation)
  if ! [[ "$topic" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    safe_echo "Error: Topic contains invalid characters. Only letters, numbers, hyphens, and underscores are allowed."
    exit 1
  fi
}  

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -m)
      shift
      if [[ $# -eq 0 || $1 == -* ]]; then
        safe_echo "Error: '-m' requires a message."
        exit 1
      fi
      TEMP_MESSAGE="$1"
      shift
      ;;
    --message)
  shift
  SHOULD_NOTIFY=false
  if [[ $# -eq 0 || $1 == -* ]]; then
    safe_echo "Error: '--message' requires a message."
    exit 1
  else
    MESSAGE="$1"
    save_config  # Save the new message to the configuration file
    if [ $? -eq 0 ]; then  # Check if save_config was successful
      safe_echo "Default message set to $MESSAGE"
    fi
  fi
  shift
  ;;
    --ip)
      shift
      SHOULD_NOTIFY=false
      if [[ $# -eq 0 || $1 == -* ]]; then
        safe_echo "Error: '--ip' requires an IP address or network interface name."
        exit 1
      fi
      if [[ $# -eq 0 || $1 == -* ]]; then
        safe_echo "Error: '--ip' requires an IP address or network interface name."
        exit 1
      fi
      # Regular expression to validate IPv4 address
ipv4_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

# Check if the argument is a network interface
if [[ -n "$(ip link show "$1" 2> /dev/null)" ]]; then
  # It's a network interface, extract the IP
  IP="$(ip -4 addr show "$1" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
  if [[ -z "$IP" ]]; then
    safe_echo "Error: No IPv4 address assigned to interface $1."
    exit 1
  fi
elif [[ "$1" =~ $ipv4_regex ]]; then
  # Check if each octet is less than or equal to 255
  IFS='.' read -r -a octets <<< "$1"
  valid_ip=true
  for octet in "${octets[@]}"; do
    if ((octet > 255)); then
      valid_ip=false
      break
    fi
  done
  if [[ "$valid_ip" = true ]]; then
    IP="$1"
  else
    safe_echo "Error: Invalid IP address. Each octet must be between 0 and 255."
    exit 1
  fi
else
  safe_echo "Error: Invalid input. Please enter a valid IPv4 address or network interface name."
  exit 1
fi
# Once a valid IP is set, update the base_url.
      save_config
      update_base_url
      safe_echo "IP set to $IP"
      safe_echo "Restart the ntfy service for this to take effect."
      shift
      ;;
    --port)
  shift
  SHOULD_NOTIFY=false
  
  # Check if the user is root
  if [[ $EUID -ne 0 ]]; then
    safe_echo "Permission denied, try using sudo."
    exit 1
  fi


  if [[ $# -eq 0 || $1 == -* ]]; then
    safe_echo "Error: '--port' requires a port number."
    exit 1
  fi
  # Check if the port is a number and within the valid range
  if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 0 ] && [ "$1" -le 65535 ]; then
    PORT="$1"
    safe_echo "Port set to $PORT"
    safe_echo "Restart the ntfy service for this to take effect."
    save_config
  else
    safe_echo "Error: Port must be a number between 0 and 65535."
    exit 1
  fi
  shift
  ;;
    --topic)
      shift
      SHOULD_NOTIFY=false
      if [[ $# -eq 0 || $1 == -* ]]; then
        safe_echo "Error: '--topic' requires a topic name."
        exit 1
      fi
      validate_topic "$1"
      TOPIC="$1"
      save_config  # Save the new topic to the configuration file
      safe_echo "Default topic set to $Topic"
      shift
      ;;
    -t)
  shift # Shift to get the next argument which should be the topic name
  if [[ $# -eq 0 || $1 == -* ]]; then
    safe_echo "Error: '-t' requires a temporary topic name."
    exit 1
  fi
  validate_topic "$1"
  TEMP_TOPIC="$1"
  shift # Shift again after capturing the topic name, to proceed to the next argument
  ;;
    --start)
      SHOULD_NOTIFY=false
      start_ntfy
      exit 0
      ;;
    --stop)
      SHOULD_NOTIFY=false
      stop_ntfy
      exit 0
      ;;
    --settings)
      SHOULD_NOTIFY=false
      print_settings
      exit 0
      ;;
    -h|--help)
      SHOULD_NOTIFY=false
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;  
  esac
done

# Use a temporary topic/message if specified
TOPIC=${TEMP_TOPIC:-$TOPIC}
MESSAGE=${TEMP_MESSAGE:-$MESSAGE}

# Send the notification only if SHOULD_NOTIFY is true
if $SHOULD_NOTIFY; then
  SERVER_URL="http://${IP}:${PORT}/${TOPIC}"
  if curl --fail --silent --show-error --max-time 10 -d "$MESSAGE" "$SERVER_URL" > /dev/null 2>&1; then
    safe_echo "ntfy notification sent to $SERVER_URL"
  else
    status=$?  # Move this line here, and remove the 'local' keyword
    if [ $status -eq 6 ] || [ $status -eq 7 ]; then
      safe_echo "Error: ntfy service could not be reached at $SERVER_URL. Make sure the service is running by using --start"
    else
      safe_echo "Error: Failed to send ntfy notification. curl exit code: $status"
      safe_echo "Make sure the service is running by using --start"
      safe_echo "Make sure nfty settings are correct by using --settings"
      safe_echo "Try restarting nfty with --stop, then do --start again"
    fi
  fi
fi
