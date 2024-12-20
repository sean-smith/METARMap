/usr/bin/sudo pkill -F /home/pi/offpid.pid
/usr/bin/sudo pkill -F /home/pi/metarpid.pid
/usr/bin/sudo /home/pi/METARMap/.env/bin/python3 /home/pi/METARMap/pixelsoff.py & echo $! > /home/pi/offpid.pid
