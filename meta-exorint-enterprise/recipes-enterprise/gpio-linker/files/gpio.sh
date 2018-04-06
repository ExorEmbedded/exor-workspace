#!/bin/bash -e
#
# Load/Unload GPIO link for Wu16 uS01 (UN67)
#
source /etc/default/gpio

load()
{
    mkdir /dev/gpi/
    for index in ${!INPUT_GPIO_ARRAY[*]}
    do
		echo "Link GPO ${INPUT_NAME_ARRAY[$index]} --> ${INPUT_GPIO_ARRAY[$index]}"
        echo "${INPUT_GPIO_ARRAY[$index]}" > /sys/class/gpio/export
        ln -s /sys/class/gpio/gpio"${INPUT_GPIO_ARRAY[$index]}"/ /dev/gpi/"${INPUT_NAME_ARRAY[$index]}"
        echo "in" > /dev/gpi/"${INPUT_NAME_ARRAY[$index]}/direction"
    done


    mkdir /dev/gpo/
    for index in ${!OUTPUT_GPIO_ARRAY[*]}
    do
		echo "Link GPO ${OUTPUT_NAME_ARRAY[$index]} --> ${OUTPUT_GPIO_ARRAY[$index]}"
        echo "${OUTPUT_GPIO_ARRAY[$index]}" > /sys/class/gpio/export
        ln -s /sys/class/gpio/gpio"${OUTPUT_GPIO_ARRAY[$index]}"/ /dev/gpo/"${OUTPUT_NAME_ARRAY[$index]}"
        echo "out" > /dev/gpo/"${OUTPUT_NAME_ARRAY[$index]}/direction"
    done

}

unload()
{

    for index in ${!INPUT_GPIO_ARRAY[*]}
    do
        rm /dev/gpi/"${INPUT_NAME_ARRAY[$index]}"
        echo "${INPUT_GPIO_ARRAY[$index]}" > /sys/class/gpio/unexport
    done
    rm -r /dev/gpi/

    for index in ${!OUTPUT_GPIO_ARRAY[*]}
    do
        rm /dev/gpo/"${OUTPUT_NAME_ARRAY[$index]}"
        echo "${OUTPUT_GPIO_ARRAY[$index]}" > /sys/class/gpio/unexport
    done
    rm -r /dev/gpo/
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
    sleep 1;
    load
    ;;

esac

