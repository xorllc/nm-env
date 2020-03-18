
NOTE: pulseadio -is- required. In the nomachine client window, navigate the mouse to the top right to get the "page turn" animation, click, go to Audio, Change settings, and ensure "Built-in Audio Analog Stereo" is selected, NOT autodetect.

### ctrl / caps-lock swap
Ensure no caps lock keyremapping is happening on the host, then run apt-get install x11-xserver-utils in the nomachine container, then run xmodmap with a file whose contents is:
```
clear Lock
keycode 0x42 = Control_R
add Control = Control_R
```

The value 0x42 is the hex equivalent of the number printed from the `xev` command, which is in the x11-utils package. In other words, force 0x42 to be a Control_R character.
