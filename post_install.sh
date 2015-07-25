set -x

# Add user mike
useradd -m -G wheel -s /bin/bash mike
passwd -d mike

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Add Virtualbox stuff
pacman -S --noconfirm virtualbox-guest-utils xorg-xinit

systemctl enable vboxservice
systemctl start vboxservice

# Add KDE
pacman -S --noconfirm plasma
pacman -S --noconfirm konsole
pacman -S --noconfirm kate

# Create xinit script
cat > /home/mike/.xinitrc <<EOF
#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

exec startkde
EOF

# Add run command
cat > /usr/bin/run <<EOF
#!/bin/bash

if [ $# -gt 0 ] ; then
    ($@ &) &>/dev/null
else
    echo "missing argument"
fi
EOF

chmod +x /usr/bin/run


