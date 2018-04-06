#!/bin/bash -e
#
# Load/Unload Redpine RS9113 kernel modules
#
# Based on Redpine sample scripts (run them with 'sh -x' to grab parameters)

count=0;

ENABLED="$(grep -A 2 \"wifi\" /usr/share/jmuconfig/network.json | grep '\"enabled\"' | cut -d : -f 2 | tr -d ' ')"
[ "${ENABLED}" = "true" ] || exit 0

. /etc/exorint.funcs

# Check WiFi disable bit in SW Flag Area
[ "$( exorint_swflagarea_bit 16 )" -eq 1 ] && exit 0

#Get specific gpio number for this platform
. /etc/default/wifi_gpio

cd /lib/modules/$(uname -r)/kernel/drivers/EXTERNAL/kmod-wifi-rs9113

#
# based on start_sta.sh, wlan_enable.sh, onebox_insert.sh, common_insert.sh
#
driver_load()
{
    echo "Loading Redpine RS9113 modules" | logger

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
    insmod onebox_nongpl.ko \
            driver_mode=1 \
            firmware_path=/lib/firmware/kmod-wifi-rs9113/ \
            onebox_zone_enabled=0x1 \
            ta_aggr=4 \
            skip_fw_load=0 \
            fw_load_mode=1 \
            sdio_clock=50000 \
            enable_antenna_diversity=0 \
            coex_mode=1 \
            obm_ant_sel_val=2 \
            wlan_rf_power_mode=0x00 \
            bt_rf_power_mode=0x22 \
            zigb_rf_power_mode=0x22 \
            country_code=0
    insmod onebox_gpl.ko

    # Enabled WLAN protocol
    usleep 100000
    onebox_util rpine0 enable_protocol 1

    # Create STA mode interface
    usleep 500000
    onebox_util rpine0 create_vap wifi0 sta sw_bmiss

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

}

unload()
{
    echo "UN-loading Redpine RS9113 modules" | logger --tag="wifi"

    # 
    # based on remove_all.sh
    # 
    rmmod onebox_gpl.ko
    rmmod onebox_nongpl.ko

    rmmod onebox_wlan_gpl.ko
    rmmod onebox_wlan_nongpl.ko
    rmmod wlan_scan_sta.ko
    rmmod wlan_xauth.ko
    rmmod wlan_acl.ko
    rmmod wlan_tkip.ko
    rmmod wlan_ccmp.ko
    rmmod wlan_wep.ko
    rmmod wlan.ko

    rmmod onebox_common_gpl.ko

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
            echo "Wifi 1"
            x=$(ifconfig -a | grep rpine)
            echo $x
            echo "Detected wifi error: rpine trigger" | logger --tag="wifi"
            unload
            sleep 1
            driver_load
            sleep 1
        else
            echo "Detected wifi interface" | logger --tag="wifi"        
            
            if [ "$(ifconfig -a | grep rpine | grep "00:00:00:00:00:00" )" != "" ]
            then
                #First type of error,rpine interface triggered with null mac address
                echo "Wifi 2"
                echo "Detected wifi interface init error" | logger --tag="wifi"
                echo "restart $count!!!" | logger --tag="wifi"
                unload
                sleep 1
                driver_load
                sleep 1
            else
                echo "Wifi 3"
                wifi_ok=$(ifconfig -a | grep rpine);
                echo "Detected wifi: $wifi_ok" | logger --tag="wifi"
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
