# Ubiquiti shutdown script

## Description

We put here all the material we use to make it easy to shutdown the Ubiquiti router used for the iCub.


## Author

The main author for this repository is [Dorian Goepp](mailto:dorian.goepp@inria.fr).


## Usage

If you use the iCub, you know that there is a router to be switched on in order to do networking with the robot or talk to the internet in that side of the C104.

Until now, there was no simple way to switch it off without risking to break it. Today, a nice button has been added on iCub01's desktop. It looks like this

![power icon](power-button.png)

and sits nearby the short-cut to open a terminal on PC104. When you double-click it, a terminal window will show up and if no error is displayed the router is already shutting down. You can safely power the router off as soon as none of the lights above the Ethernet plugs blinks again.


## Installation

The files are written with the assumption that this repository has been put in the folder `/home/icub/router-scripts`. If this could change, the file to change is `routershutdown.desktop` (which appears as "Router off" in the file manager).

We also assume that the computer's **public key** has been successfuly installed on the router. You can read the next sub-section for how to do it.

> **Note:** the servers SSH key has to be already registered on the computer running this shutdown script. One way is to manually connect one time to the router and accept its key.

> **Warning:** We use authorized public keys to connect to the router without password. Remember to set one before trying to run the script on a new machine.


### Setup public key authentication in EdgeOS

Let's say that you already generated a public-private key pair for SSH.

> **Warning:** **Do not** write in `~/.ssh/authorized_keys` on the router for it will be overwritten on next boot.

To add a public key to the Edge router, first send it there (for instance with `scp`)

Then use the special Vyatta/EdgeOS configuration commands to enable it. There is a short [tutorial](http://www.dahl-jacobsen.dk/tips/2014/04/06/SSH-login-with-RSA-keys-on-Vyatta-EdgeOS.html) from DJ's Tips. We reproduce the simple situation bellow. If you face problems, refer to the full tutorial.

```
configure
loadkey <user> /path/to/id_rsa.pub
save
exit
```


## How we built this all

### Write a script for vyatta/EdgeOS

Ubiquiti uses a fork of the open source operating system for networking devices vyatta. It's name is EdgeOS. We tell you this because this operating system comes with a shell that might feel unusual for Unix users. For instance, to display information on all ports, you type `show interfaces`. Tab completion is different from usual and the '?' key has role similar to the usual `--help`.

Therefore, when logged in, we can switch of the router with `shutdown` and a press of the Enter key, or `shutdown at 00` for immediate shutdown (without confirmation).

Also, since this interface is special, we need to prepend the command with the proper environment variables, setup in `/opt/vyatta/bin/vyatta-op-cmd-wrapper` (see [this thread](https://help.ubnt.com/hc/en-us/articles/204976164-EdgeMAX-How-to-run-operational-mode-command-from-scripts-)).

A working script to shutdown can be

```
run=/opt/vyatta/bin/vyatta-op-cmd-wrapper
$run shutdown at 00
```


### Local script to execute the shutdown sequence on the router

With the public key authentication, this one-liner will shutdown the router immediately.

```
ssh miraikan@10.0.0.254 'bash -c "/opt/vyatta/bin/vyatta-op-cmd-wrapper shutdown at 00"'
```

Alternatively, one could use
```
ssh miraikan@10.0.0.254 'bash -s' < shutdown_icubrouter.sh
```

where the `shutdown_icubrouter.sh` script reads

```
run=/opt/vyatta/bin/vyatta-op-cmd-wrapper
$run shutdown at 00
```


### Polishing the user interaction

To make everything simpler to use, we created a `routershutdown.desktop` file that displays a clickable icon to launch the shutdown script. It has to be executable and is attached in this repository.

We also added one line to the script, waiting for the user to press a key. This way she knows that something has actually happened. Otherwise, the terminal window would stay for less than a second, or we could even make it not appear. This is the line:

```
read -rsp $'Press any key to continue...\n' -n1 key
```