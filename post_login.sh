set -x

passwd

# Create xinit script
cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i 's/^twm/#twm/g' ~/.xinitrc
sed -i 's/^xclock -geometry/#xclock -geometry/g'  ~/.xinitrc
sed -i 's/^xterm -geometry/#xterm -geometry/g'  ~/.xinitrc
sed -i 's/^exec xterm/#exec xterm/g' ~/.xinitrc
echo "exec startkde" >>  ~/.xinitrc

git config --global user.email ""
git config --global user.name "JinShil"
