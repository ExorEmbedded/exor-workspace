inherit core-image-exorint

IMAGE_INSTALL += "base-mainos"
IMAGE_INSTALL += "canutils"

# Poppler libraries needed for the pdf viewer
IMAGE_INSTALL += "poppler"

# Qt mediaplayer dependencies
#
# TODO FIXME:
#   qt4-plugin-phonon-backend-gstreamer
#   gst-ffmpeg 
IMAGE_INSTALL += "\
        gst-meta-video gst-meta-audio \
        gst-plugins-base gst-meta-base \
        gst-plugins-good \
        gst-plugins-good-meta \
        gst-plugins-good-audioparsers \
        gst-plugins-good-autodetect \
        gst-plugins-good-avi \
        gst-plugins-good-ximagesrc \
        gst-plugins-bad \
        gst-plugins-bad-autoconvert \
        gst-plugins-bad-colorspace \
        gst-plugins-bad-h264parse \
        gst-plugins-bad-mpegdemux \
        gst-plugins-bad-mpegtsdemux \
        gst-plugins-bad-mpegvideoparse \
        gst-plugins-ugly \
        gst-plugins-ugly-meta \
        gst-plugins-ugly-mpeg2dec \
        gst-plugins-ugly-mpegaudioparse \
        gst-plugins-ugly-mpegstream \
        gst-plugins-ugly-x264 "

#IMAGE_INSTALL += "gstreamer1.0-meta-audio \
#	gstreamer1.0-plugins-base-playback \
#	gstreamer1.0-plugins-base-meta \
#	gstreamer1.0-plugins-good-meta \
#	gstreamer1.0-plugins-bad-meta \
#	gstreamer1.0-libav \
#	gstreamer1.0-plugins-ugly-meta \
#"

#IMAGE_INSTALL += "ibtp"

# These two libraries were automatically installed in dora but not here
# in krogoth. Add them again by now as they are needed by chromium
IMAGE_INSTALL += "gconf dbus-glib"

IMAGE_INSTALL_append_usom03 += "firmware-imx-vpu-imx6d firmware-imx-vpu-imx6q gst-fsl-plugin "

# Gstreamer 1.0 plugins for imx
#IMAGE_INSTALL_append_usom03 += "gstreamer1.0-plugins-imx-imxvpu gstreamer1.0-plugins-imx-imxipu gstreamer1.0-plugins-imx-imxaudio gst1.0-fsl-plugin "

# SDL library, a requirement for Henrob
IMAGE_INSTALL += "libsdl"

IMAGE_INSTALL_append_wu16 += " gpio-linker"
