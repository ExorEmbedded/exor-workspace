#!/bin/sh

export TMPDIR=/mnt/.psplash

if [[ "$(cat /boot/version_tag 2> /dev/null)" == "u" ]] ; then

echo  "Unstable BSP"
psplash-write "MSG          
  
     
   
  ###################################
  #                                 #
  #       ENGINEERING  SAMPLE       #
  #                                 #
  #        INTERNAL USE ONLY        #
  #                                 #
  ###################################   
  
    
     
      
  "
fi

