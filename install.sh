sudo cp -r galaback /opt/
cd /usr/bin
sudo ln -s /opt/galaback/bin/galaback.sh galaback
mkdir "$HOME/.galaback"
cp -r /opt/galaback/config "$HOME/.galaback/"