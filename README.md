
NOTE: pulseadio -is- required in the Dockerfile/resulting image AND the host running the client, if the host is linux. In the nomachine client window, navigate the mouse to the top right to get the "page turn" animation, click, go to Audio, Change settings, and ensure "Built-in Audio Analog Stereo" is selected, NOT autodetect.

### ctrl / caps-lock swap
Ensure no caps lock keyremapping is happening on the host, then run apt-get install x11-xserver-utils in the nomachine container, then run xmodmap with a file whose contents is:
```
clear Lock
keycode 0x42 = Control_R
add Control = Control_R
```

The value 0x42 is the hex equivalent of the number printed from the `xev` command, which is in the x11-utils package. In other words, force 0x42 to be a Control_R character.

### Restarting dwm
Execute `pkill -TERM dwm` after running `make clean && make install`.


### Notes

#### Host-level configuration

On the host, don't do this!

```
setxkbmap -option caps:ctrl_modifier
```

Instead, run `xmodmap .xmod` in the same way that this codebase does on the host so it doesn't screw up nomachine.


### Notes on configuring the environment

Make sure you install the nomachine client, pulseaudio if the client is installed on windows, and Docker.

#### Docker

Make sure you run `systemctl enable docker` so that Docker will run after login (see: https://wiki.archlinux.org/index.php/systemd)

#### NoMachine

May need to run `/usr/NX/bin/nxplayer` manually.
Also may need to run build-and-run.sh to start the container as root, then exit back to the non-root user, and run ./build-and-run.sh as the non-root user.
