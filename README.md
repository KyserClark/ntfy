# nfty

Simplifying push notifications from your terminal, the `ntfy` tool is written by Kyser Clark to make it easier for everyone to send notifications with fewer keystrokes.

## Installation

To install `ntfy`, run the following commands:
```
git clone https://github.com/KyserClark/ntfy.git
```
```
cd ntfy
```
```
sudo bash install_ntfy.sh
```

## Usage
Execute ntfy with options like so:  
```
ntfy [options]
```

### Examples:

Run a command and send a notification if successful:

```
[command] && ntfy
```

Send a custom message or use a different topic if a command fails:
```
[command] || ntfy -m 'Different Message' -t 'New_Topic'

```

## Options
* --start         Start the ntfy service
* --stop          Stop the ntfy service
* --ip            Set the IP address
* --port          Set the port
* --message       Set the default message to send
* --topic         Set the default topic
* -m              Use a temporary message for the current command
* -t              Use a temporary topic for the current command
* --settings      Display current ntfy settings
* -h, --help      Display this help message

## About the Author

Kyser Clark is an experienced cybersecurity professional. For a full bio check out these locations:

* Website: KyserClark.com
* GitHub: @KyserClark
* LinkedIn: linkedin.com/in/KyserClark
