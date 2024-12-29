#!/bin/bash


sudo tee -a /etc/motd << EOF
 ▗▄▖ ▗▖ ▗▖    ▗▖  ▗▖▗▄▄▄▖▗▄▄▄▖▗▄▖ ▗▄▄▖     ▗▖  ▗▖ ▗▄▖ ▗▄▄▖  ▗▄▄▖
▐▌ ▐▌▐▌▗▞▘    ▐▛▚▞▜▌▐▌     █ ▐▌ ▐▌▐▌ ▐▌    ▐▛▚▞▜▌▐▌ ▐▌▐▌ ▐▌▐▌   
▐▛▀▜▌▐▛▚▖     ▐▌  ▐▌▐▛▀▀▘  █ ▐▛▀▜▌▐▛▀▚▖    ▐▌  ▐▌▐▛▀▜▌▐▛▀▘  ▝▀▚▖
▐▌ ▐▌▐▌ ▐▌    ▐▌  ▐▌▐▙▄▄▖  █ ▐▌ ▐▌▐▌ ▐▌    ▐▌  ▐▌▐▌ ▐▌▐▌   ▗▄▄▞▘
                                                                
                                                                
To refresh the LED's run:

    sudo systemctl restart metarmap.service
    sudo systemctl status metarmap.service

To see how long since the last refresh run:

    sudo systemctl status metarmap.timer

EOF
