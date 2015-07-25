# Create xinit script
cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i 's/twm &\nxclock -geometry 50x50-1+1 &\nxterm -geometry 80x50+494+51 &\nxterm -geometry 80x20+494-0 &\nexec xterm -geometry 80x66+0+0 -name login\n/exec startkde\n/g' ~/.xinitrc
