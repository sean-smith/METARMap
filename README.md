# METARMap

Raspberry Pi project to visualize flight conditions on a map using WS8211 LEDs addressed via NeoPixel

> [!NOTE]  
> This is a fork of the [main repo](https://github.com/prueker/METARMap) where I simplified the installation by adding a python virtual environment and using systemd instead of crontab to continually update it.


## Detailed instructions

I've created detailed instructions about the setup and parts used here: https://slingtsi.rueker.com/making-a-led-powered-metar-map-for-your-wall/

## Software Setup

1. Install [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/) on SD card
2. [Enable Wi-Fi and SSH](https://medium.com/@danidudas/install-raspbian-jessie-lite-and-setup-wi-fi-without-access-to-command-line-or-using-the-network-97f065af722e)
3. Install SD card and power up Raspberry Pi
4. SSH into the Raspberry Pi
5. First clone this repo:

  ```bash
  cd ~
  git clone https://github.com/sean-smith/METARMap && cd METARMap
  ```

5. Install python3 and pip3 in a virtual environment

 ```bash
 python3 -m venv .env
 source .env/bin/activate
 pip3 install -r requirements.txt rpi_ws281x adafruit-circuitpython-neopixel
 python3 -m pip install --force-reinstall adafruit-blinka
 ```

6. Attach WS8211 LEDs to Raspberry Pi, if you are using just a few, you can connect the directly, otherwise you may need to also attach external power to the LEDs. For my purpose with 22 powered LEDs it was fine to just connect it directly. You can find [more details about wiring here](https://learn.adafruit.com/neopixels-on-raspberry-pi/raspberry-pi-wiring).

![image](https://github.com/user-attachments/assets/4bf6f407-2ed9-434b-bf68-a974044c33da)


7. Test the script by running it directly (it needs to run with root permissions to access the GPIO pins):

 ```bash
 sudo $(which python3) metar.py
 ```

8. Make appropriate changes to the **[airports](airports)** file for the airports you want to use and change the **[metar.py](metar.py)** and **[pixelsoff.py](pixelsoff.py)** script to the correct **`LED_COUNT`** (including NULLs if you have LEDS in between airports that will stay off) and **`LED_BRIGHTNESS`** if you want to change it

9. To run the script automatically every 5 minutes, we've provided a systemd service. To install it, run:

 ```bash
 sudo cp metarmap.service /etc/systemd/system/
 sudo cp metarmap.timer /etc/systemd/system/
 sudo systemctl daemon-reload
 sudo systemctl enable metarmap.timer
 sudo systemctl start metarmap.timer
 ```

 Next check on the status of the running program:

 ```bash
 sudo systemctl status metarmap.timer
 sudo systemctl status metarmap.service
 ```

To enable after rebooting the raspberry pi:

```bash
sudo systemctl enable metarmap.timer
```

Next make sure the timer is counting down, it refreshes the LED's every 5 minutes

```bash
sudo systemctl status metarmap.timer
```

10. Enable MOTD for easier login instructions:

```bash
bash motd.sh
```

## Automatic airports.txt file

To copy the `airports.txt` file automatically into `/home/pi/METARMap` folder from the sd card we need to do the following:

1. Move the `copy-file.service` script into the right location:

```bash
sudo mv copy-file.service /etc/systemd/system/
chmod +x copy-file.sh
```

2. Next we need to enable the daemon:

```bash
sudo systemctl daemon-reload
sudo systemctl enable copy-file.service
sudo systemctl start copy-file.service
```

3. Plug in the SD Card and create a file called `boot/airports.txt`

4. Eject the SD card, power on the raspberry pi and it should have sourced the new airports.txt file.

## Additional Wind condition blinking/fading functionality

I recently expanded the script to also take wind condition into account and if the wind exceeds a certain threshold, or if it is gusting, make the LED for that airport either blink on/off or to fade between  two shades of the current flight category color.

If you want to use this extra functionality, then inside the **[metar.py](metar.py)** file set the **`ACTIVATE_WINDCONDITION_ANIMATION`** parameter to **True**.

* There are a few additional parameters in the script you can configure to your liking:
  * `FADE_INSTEAD_OF_BLINK` - set this to either **True** or **False** to switch between fading or blinking for the LEDs when conditions are windy
  * `WIND_BLINK_THRESHOLD` - in Knots for normal wind speeds currently at the airport
  * `ALWAYS_BLINK_FOR_GUSTS` - If you always want the blinking/fading to happen for gusts, regardless of the wind speed
  * `BLINKS_SPEED` - How fast the blinking happens, I found 1 second to be a happy medium so it's not too busy, but you can also make it faster, for example every half a second by using 0.5
  * `BLINK_TOTALTIME_SECONDS` = How long do you want the script to run. I have this set to 300 seconds as I have my crontab setup to re-run the script every 5 minutes to get the latest weather information
  * `HIGH_WINDS_THRESHOLD` - If you want LEDs to flash to Yellow for particularly high winds beyond the normal `WIND_BLINK_THRESHOLD` then set this variable in knots. If you only want normal blinking/fading based on `WIND_BLINK_THRESHOLD` then set the value for `HIGH_WINDS_THRESHOLD` to **`-1`**

## Additional Lightning in the vicinity blinking functionality

After the recent addition for wind condition animation, I got another request from someone if I could add a white blinking animation to represent lightning in the area.
Please note that due to the nature of the METAR system, this means that the METAR for this airport reports that there is Lightning somewhere in the vicinity of the airport, but not necessarily right at the airport.

If you want to use this extra functionality, then inside the **[metar.py](metar.py)** file set the **`ACTIVATE_LIGHTNING_ANIMATION`** parameter to **True**.

* This shares two configuration parameters together with the wind animation that you can modify as you like:
  * `BLINKS_SPEED` - How fast the blinking happens, I found 1 second to be a happy medium so it's not too busy, but you can also make it faster, for example every half a second by using 0.5
  * `BLINK_TOTALTIME_SECONDS` = How long do you want the script to run. I have this set to 300 seconds as I have my crontab setup to re-run the script every 5 minutes to get the latest weather information

## Additional LED dimming functionality based on time of day

This optional functionality allows you to run the LEDs at a dimmed lower level between a certain time of the day.

If you want to use this extra functionality, then inside the **[metar.py](metar.py)** file set the **`ACTIVATE_DAYTIME_DIMMING`** parameter to **True**.
Set the `LED_BRIGHTNESS_DIM` setting to the level you want to run when dimmed.

For time timings of the dimming there are two options:

* Fixed time of day dimming:
  * `BRIGHT_TIME_START` - Set this to the beginning of the day when you want to run at the normal `LED_BRIGHTNESS` level
  * `DIM_TIME_START` - Set this to the time where you want to run at a different `LED_BRIGHTNESS_DIM` level
* Dimming based on local sunrise/sunset:
  * For this to work, you need to install an additional library, run:
    * `sudo pip3 install astral`
  * `USE_SUNRISE_SUNSET` - Set this to **True** to use the dimming based on sunrise and sunset
  * `LOCATION` - set this to the city you want to use for sunset/sunrise timings
    * Use the closest city from the list of supported cities from https://astral.readthedocs.io/en/latest/#cities

## Additional mini display to show METAR information functionality

This optional functionality allows you to connect a small mini LED display to show the METAR information of the airports.

For this functionality to work, you will need to buy a compatible LED display and enable and install a few additional things.

I've written up some details on the display I used and the wiring here: https://slingtsi.rueker.com/adding-a-mini-display-to-show-metar-information-to-the-metar-map/

To support the display you need to enable a few new libraries and settings on the raspberry pi.

* [Enable I2C](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-4-gpio-setup/configuring-i2c)
* `sudo raspi-config`
* Interface Options
* I2C
* reboot the Reboot the Raspberry Pi `sudo reboot`
* Verify your wiring is working and I2C is enabled
  * `sudo apt-get install i2c-tools`
  * `sudo i2cdetect -y 1` - this should show something connected at **3C**
* install python library for the display
  * `sudo pip3 install adafruit-circuitpython-ssd1306`
  * `sudo pip3 install pillow`
* install additional libraries needed to fill the display
  * `sudo apt-get install fonts-dejavu`
  * `sudo apt-get install libjpeg-dev -y`
  * `sudo apt-get install zlib1g-dev -y`
  * `sudo apt-get install libfreetype6-dev -y`
  * `sudo apt-get install liblcms1-dev -y`
  * `sudo apt-get install libopenjp2-7 -y`
  * `sudo apt-get install libtiff5 -y`
* copy new file **[displaymetar.py](displaymetar.py)** into the same folder as **[metar.py](metar.py)**
* Use the latest version of **[metar.py](metar.py)** and **[pixelsoff.py](pixelsoff.py)** for the new functionality
* Configure **[metar.py](metar.py)** and set **`ACTIVATE_EXTERNAL_METAR_DISPLAY`** parameter to **True**.
* Configure the `DISPLAY_ROTATION_SPEED` to your desired timing, I'm using 5 seconds for mine.
* If you want to only show a subset of the airports on the display, create a new file in the folder called **displayairports** and add the airports that you want to be shown on the display to it

## Legend

If you want an interactive Legend to illustrate the possible behaviors you can do so by adding an additional up to 7 LEDs after the last LED based on your number of LEDs of the airports in the **airports** file

* Set `SHOW_LEGEND` to **True** to use this feature
* If you want to skip some LEDs after your last airport before the legend, you can set `OFFSET_LEGEND_BY` to the number of LEDs to skip
* **Note**: The Lightning and Wind Condition LEDs will only show if you are actually using these features based on the `ACTIVATE_LIGHTNING_ANIMATION`, `ACTIVATE_WINDCONDITION_ANIMATION` and `HIGH_WINDS_THRESHOLD` variables.
  * If you are not using any of these, then you only need 4 LEDs for the basic flight conditions for the Legend
  * If you are only using the Wind condition feature, but not the Lightning, you will still need the total of 7 LEDs (but the 5th LED for Lightning will just stay blank) or you'd have to change the order in the code


## Changelist

To see a list of changes to the metar script over time, refer to [CHANGELIST.md](CHANGELIST.md)
