# ntfy

Simplifying push notifications from your terminal, the `ntfy` tool is written by Kyser Clark to make it easier for everyone to send notifications with fewer keystrokes.
ntfy was not created by Kyser Clark, but this tool makes ntfy easier to use, which is why it's called `ntfy`.

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
  
The IP should auto-resolve to your primary IP address that points to the internet. The port is 8686 by default. And the default topic is 'Topic'.  
  
If you don't like these defaults, feel free to change them. 
I made it easy to change any of these values by doing --ip, --port, and --topic respectfully. 
The default message is 'Command Finished'. You can change it with --message.
Set temporary message and temporary topic with -m and -t respectfully. 
  
This tool is designed to self-host a docker container on your local area network (LAN).  
If you run `ntfy` on a virtual machine (VM), ensure your VM is in bridge mode.   
Otherwise, the ntfy server can't communicate with other devices on your network.  
  
For more info, refer to NetworkChuck's video: [https://www.youtube.com/watch?v=poDIT2ruQ9M&ab_channel=NetworkChuck](https://www.youtube.com/watch?v=poDIT2ruQ9M&ab_channel=NetworkChuck)  
This is where I first learned about and how to use ntfy. 
My tool cuts down on keystrokes and makes it easier to set up and modify. 
   
If you encounter any bugs or issues, please let me (Kyser Clark) know.   
As of now, the install.sh file is for Debian-based systems. If you run a different version of Linux, you'll have to install dependencies manually.

This tool has been tested on the following versions of Linux:
* Kali Linux 2023.3
* Ubuntu 22.04.3 LTS (Jammy Jellyfish)
* Parrot OS Security Edtion 5.2 (Electro Ara)
* Linux Mint 21.2 "Victoria" (Cinnamon Edition)

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

Send a custom message and use a different topic if a command fails:
```
[command] || ntfy -m 'Different Message' -t 'New_Topic'

```
Start tool with: 
```
sudo ntfy --start
```
Change default settings with:
```
sudo ntfy --ip [IP-ADDRESS/INTERFACE] --port [PORT] --topic [CUSTOM-TOPIC] --message [CUSTOM-MESSAGE] 
```
Change temporary values with:
```
ntfy -t [TEMPORARY-TOPIC] -m [TEMPORARY-MESSAGE]
```

## Options
* --start         Start the ntfy service
* --stop          Stop the ntfy service
* --ip            Set the IP address (can also accept a valid interface name)
* --port          Set the listening port
* --message       Set the default message to send
* --topic         Set the default topic to send
* -m              Use a temporary message for the current command
* -t              Use a temporary topic for the current command
* --settings      Display current ntfy settings
* -h, --help      Display this help message

## About the Author

Kyser Clark is an experienced cybersecurity professional. For a full bio check out these locations:

* Website: [KyserClark.com](https://KyserClark.com)
* GitHub: [@KyserClark](https://github.com/KyserClark)
* LinkedIn: [linkedin.com/in/KyserClark](https://linkedin.com/in/KyserClark)
