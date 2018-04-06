inherit core-image-exorint

IMAGE_INSTALL += "base-mainos"
IMAGE_INSTALL += "canutils"

# Poppler libraries needed for the pdf viewer
IMAGE_INSTALL += "poppler"

# Qt mediaplayer dependencies
IMAGE_INSTALL += "qt4-plugin-phonon-backend-gstreamer \
        gst-ffmpeg \
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

IMAGE_INSTALL_append_usom03 += "firmware-imx-vpu-imx6d firmware-imx-vpu-imx6q gst-fsl-plugin"

# SDL library, a requirement for Henrob
IMAGE_INSTALL += "libsdl"

IMAGE_INSTALL_append_wu16 += " gpio-linker"
