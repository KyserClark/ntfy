# ntfy

Simplifying push notifications from your terminal, the `ntfy` tool is written by Kyser Clark to make it easier for everyone to send notifications with fewer keystrokes.
ntft was not created by Kyser Clark, but this tool makes ntfy easier to use, which is why it's called `ntfy`.

## Installation

To install `ntfy`, run the following commands:
```
wget https://github.com/KyserClark/ntfy/archive/refs/heads/main.zip
```
```
unzip main.zip
```
```
cd ntfy-main
```
```
sudo bash install.sh
```
Make sure you download the ntfy mobile app and configure it accordingly.   
Essentially, all you have to do is point the server URL to your host IP address/port and create a topic, and you're off to the races.  
This tool is designed to self-host a docker container on your local area network (LAN).  
If you run `ntfy` on a virtual machine (VM), ensure your VM is in bridge mode.   
Otherwise, the ntfy server can't communicate with other devices on your network. 
For more info, refer to NetworkChuck's video: [https://www.youtube.com/watch?v=poDIT2ruQ9M&ab_channel=NetworkChuck](https://www.youtube.com/watch?v=poDIT2ruQ9M&ab_channel=NetworkChuck)  
This is where I first learned about and how to use ntfy. 
My tool cuts down on keystrokes and makes it easier to setup and modify.  
If you encounter any bugs or issues, please let me (Kyser Clark) know.   
This was only tested on Kali Linux 2023.3

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
Start tool with: 
```
ntfy --start"
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
