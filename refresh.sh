pkill -F /home/pi/offpid.pi || true
pkill -F /home/pi/metarpid.pid || true
/home/pi/METARMap/.env/bin/python3  /home/pi/METARMap/metar.py &>> /home/pi/logfile
