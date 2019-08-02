#!/bin/bash
#
# Load/Unload Redpine RS9113 kernel modules
#
# Based on Redpine sample scripts (run them with 'sh -x' to grab parameters)
#
# Optional variables 
#     IFACE     wifi interface to be created
#     MODE      running mode of interface (STA|AP)

count=0;

. /etc/exorint.funcs

log()
{
    echo "$@" | logger -t wifi
}

# Check WiFi disable bit in Jumper Flag Area
if [ "$( offsetjumperarea_bit 6 )" -eq 1 ] && [ "$(exorint_ver_carrier)" != "CA16" ]; then
    #log_verb "Disabled via Jumper Flag Area 6"
    exit 0
fi

# Now (2019/04/11) is used Jumper flag area, but we have to maintain for compatibility with old protos.
# Check WiFi disable bit in SW Flag Area
if [ "$( exorint_swflagarea_bit 16 )" -eq 1 ]; then
    #log "Disabled via SW Flag Area 16"
    exit 0
fi

#Get specific gpio number for this platform
if [ -e /etc/default/wifi_gpio ]; then
    . /etc/default/wifi_gpio
fi

cd /lib/modules/$(uname -r)/kernel/drivers/EXTERNAL/kmod-wifi-rs9113

[ -z "$IFACE" ] && IFACE="wifi0"

# Set TEST=1 for certification testing
case "$TEST" in
    1)
        DRIVER_MODE=2 ;;
    *)
        DRIVER_MODE=1 ;;
esac

# COEX MODE:
#                           1    WLAN STATION /WIFI-Direct/WLAN PER
#                           2    WLAN ACCESS POINT(including muliple APs on different vaps)
#                           3    WLAN ACCESS POINT + STATION MODE(on multiple vaps)
#                           4    BT CLASSIC MODE/BT CLASSIC PER MODE
#                           5    WLAN STATION + BT CLASSIC MODE
#                           6    WLAN ACCESS POINT + BT CLASSIC MODE
#                           8    BT LE MODE /BT LE PER MODE
#                           9    WLAN STATION + BT LE MODE
#                           12   BT CLASSIC + BT LE MODE
#                           13   WLAN STATION + BT CLASSIC MODE + BT LE MODE
#                           14   WLAN ACCESS POINT + BT CLASSIC MODE+ BT LE MODE
#                           16   ZIGBEE MODE/ ZIGBEE PER MODE
#                           17   WLAN STATION + ZIGBEE
#                           32   ZIGBEE COORDINATOR MODE
#                           48   ZIGBEE ROUTER MODE
[ -z "$MODE" ] && MODE=$(sys_params -l network/wifi/interfaces/[name=$IFACE]/mode || true)
# if it's a valid numeric, leave unchanged otherwise remap according to known types
case "$MODE" in
    1|2|3|4|5|6|8|9|12|13|14|16|17|32|48)
        ;;
    STA|"")
        COEX_MODE=1 ;;
    AP)
        COEX_MODE=2 ;;
    *)
        log "invalid coex_mode: $COEX_MODE"
        exit 1 ;;
esac

# Antenna int/ext mode is read from SEEPROM 30:0 - currently allocated for CAREL only
if [ -z $ANTMODE ]; then
    ANTMODE=0 # default to internal antenna
    [ "$(exorint_ver_carrier)" = "CA16" ] && [ "$(exorint_seeprom_byte 30)" = "1" ] && ANTMODE=1

    # Antenna int/ext mode is read from SEEPROM 14:5 - currently allocated for Exor only
    [ "$(exorint_ver_carrier)" = "JSXX" ] && [ "$(offsetjumperarea_bit 5)" = "1" ] && ANTMODE=1
    log "Detected ANTMODE: $ANTMODE (0:internal 1:external)"
fi

#
# based on start_sta.sh, wlan_enable.sh, onebox_insert.sh, common_insert.sh
#
driver_load()
{
    log "Loading Redpine RS9113 modules"

    #Un-Reset module WiFi
    if [ "$WIFI_GPIO" != "" ]
    then
        if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
        then
            echo $WIFI_GPIO > /sys/class/gpio/export
        fi;
        echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
        echo 1 > /sys/class/gpio/gpio$WIFI_GPIO/value
        #Don't unexport
        sleep 1
    fi;
    # prerequisites
    modprobe cfg80211

    insmod onebox_common_gpl.ko
    insmod wlan.ko
    insmod wlan_wep.ko
    insmod wlan_tkip.ko
    insmod wlan_ccmp.ko
    insmod wlan_acl.ko
    insmod wlan_xauth.ko
    insmod wlan_scan_sta.ko
    insmod onebox_wlan_nongpl.ko
    insmod onebox_wlan_gpl.ko
    log "driver mode=$DRIVER_MODE"
    log "coex mode=$COEX_MODE"
    log "ant mode=$ANTMODE"
    insmod onebox_nongpl.ko \
            driver_mode=$DRIVER_MODE \
            firmware_path=/lib/firmware/kmod-wifi-rs9113/ \
            onebox_zone_enabled=0x1 \
            ta_aggr=4 \
            skip_fw_load=0 \
            fw_load_mode=1 \
            sdio_clock=50000 \
            enable_antenna_diversity=0 \
            coex_mode=$COEX_MODE \
            wlan_rf_power_mode=0x00 \
            bt_rf_power_mode=0x22 \
            zigb_rf_power_mode=0x22 \
            country_code=0
    insmod onebox_gpl.ko

    usleep 100000

    # Enable WLAN protocol
    case "$COEX_MODE" in
        1|2|3|5|6|9|13|14|17)
            onebox_util rpine0 enable_protocol 1
            ;;
        *)
            ;;
    esac

    # Enable BT protocol
    case "$COEX_MODE" in
        4|5|6|8|9|12|13|14)
            onebox_util rpine0 enable_protocol 2
            ;;
        *)
            ;;
    esac

    # Select type of antenna
    usleep 600000  # not applied without a delay..
    if [ "$ANTMODE" == "1" ]; then
        onebox_util rpine0 ant_sel 3
        onebox_util rpine0 ant_type 2 3
    else
        onebox_util rpine0 ant_sel 2
    fi

    usleep 500000

    if [ "$TEST" == "1" ]; then
        log "Test mode - not creating vap"
        return 0
    fi

    if [ "$COEX_MODE" == "1" ]
    then
        # Station mode
        onebox_util rpine0 create_vap $IFACE sta sw_bmiss

        #onebox_util <base_interface> set_bgscan_params <bgscan_threshold> \
        #												<rssi_tolerance_threshold>
        #												<periodicity>
        #												<active_scan_duration>
        #												<passive_scan_duration>
        #												<two_probe_enable>
        #												<num_of_bgscan_channels>
        #												<channels_to_scan>
        #
        # bgscan disabled (periodicity=0) by default and enabled only when scan is necessary
        # [#766 WU16: WiFi packet loss due to bg scan]
        onebox_util rpine0 set_bgscan_params	1  \
		    									1  \
		    									0 \
		    									5  \
		    									10 \
		    									0  \
		    									14 \
		    									1 2 3 4 5 6 7 8 9 10 11 12 13 14
    elif [ "$COEX_MODE" == "2" ]
    then
        # Acess Point mode
        onebox_util rpine0 create_vap $IFACE ap
    else
        log "WARNING: Unsupported setup (coex_mode=$COEX_MODE)!"
    fi
}

unload()
{
    log "UN-loading Redpine RS9113 modules"

    # 
    # based on remove_all.sh
    # 
    rmmod onebox_gpl
    rmmod onebox_nongpl

    rmmod onebox_wlan_gpl
    rmmod onebox_wlan_nongpl
    rmmod wlan_scan_sta
    rmmod wlan_xauth
    rmmod wlan_acl
    rmmod wlan_tkip
    rmmod wlan_ccmp
    rmmod wlan_wep
    rmmod wlan

    rmmod onebox_common_gpl

    #wifi reset
    if [ "$WIFI_GPIO" != "" ]
    then
        if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
        then
            echo $WIFI_GPIO > /sys/class/gpio/export
        fi;
        echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
        echo 0 > /sys/class/gpio/gpio$WIFI_GPIO/value
        echo $WIFI_GPIO > /sys/class/gpio/unexport
        usleep 100000
    fi;
}

load()
{
    driver_load

    while [ $count -lt 7 ]
    do
        count=$((count+1))
        if [ "$(ifconfig -a | grep rpine)" == "" ]
        then
            #First type of error,rpine interface not triggered
            x=$(ifconfig -a | grep rpine)
            echo $x
            log "Detected wifi error: rpine trigger"
            unload
            sleep 1
            driver_load
            sleep 1
        else
            log "Detected wifi interface"
            
            if [ "$(ifconfig -a | grep rpine | grep "00:00:00:00:00:00" )" != "" ]
            then
                #First type of error,rpine interface triggered with null mac address
                log "Detected wifi interface init error"
                log "restart $count!!!"
                unload
                sleep 1
                driver_load
                sleep 1
            else
                wifi_ok=$(ifconfig -a | grep rpine);
                log "Detected wifi: $wifi_ok"
                break
            fi
        fi
    done
}

case "$1" in
start)
    load
    ;;

stop)
    unload
    ;;

force-reload|restart)
    unload
    load
    ;;

esac
