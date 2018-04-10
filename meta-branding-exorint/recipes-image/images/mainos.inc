# optimization: prepend files which need to be extracted in update preprocessing [bsp #244]
# preupdate is currently MainOS-specific
IMAGE_COMPRESS_PREPEND_FILES += "./etc/migrations/preupdate.sh"
