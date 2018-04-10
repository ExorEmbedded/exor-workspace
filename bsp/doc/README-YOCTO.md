Internal Yocto Documentation
============================

### Quick Reference


#### Debugging

##### Dependency graphs

Output a dot-formatted dependency graph of all package and task dependencies of given target:

    bitbake -g [target]

##### Environment

Dump the full parsing environment for a given parsing configuration - very useful for debugging 
behaviour of recipes:

    bitbake -e [target]


#### Recipes

##### Assignment notation

     =  assign with delayed expansion of variables
    :=  assign with immediate expansion of variables
    .=  append without space
    +=  append with space
    =.  prepend without space
    =+  prepend with space
    ?=  set default value

##### Setting overrides

Given the following custom `OVERRIDES` in configuration:

    OVERRIDES = "poky:arm:beaglebone"

, setting

    MYFLAGS = "-O3"
    MY_FLAGS_arm = "-mtune=armv7" 

will result in:

    MY_FLAGS = "-mtune=armv7" 

Whereas:

    MY_FLAGS_append_arm = "-mtune=armv7" 

will result in:

    MY_FLAGS = "-O3 -mtune=armv7" 

##### Defining custom packages

    PACKAGES = "${PN} ${PN}-extra"
    FILES_${PN}-extra += "${datadir}/extra"

##### Inline python

Variables can contain Python code snippets. 

As an example of parsing variable values:

    MAJOR = "${@'.'.join(d.getVar('PV',1).split('.')[0:2])}"

For configurable dependencies:

    DEPENDS += "${@base_contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)}"

##### Patching with quilt

###### To workaround missing standard output problems

    export PSEUDO_UNLOAD = 1

If conflicts arise:

  - comment patches that don't apply in recipe
  - `bitbake -c devshell <recipe>`
  - `quilt import` patches manually
  - `apply -f` and edit files by comparing with `.rej` files
  - `quilt refresh` and copy patches back to recipe


### Notes

##### Making BusyBox configuration changes

  First enter a devshell to have appropriate target environment:
  - $ ./bsptool bb busybox -c devshell

  Then: 
  - $ cp ../defconfig .config
  - $ make menuconfig
  - copy the generated `.config` back to repo `${META_EXORINT}/recipes-core/busybox/busybox-<x.y.z>/defconfig`

### References

  * [Yocto Reference Manual](https://www.yoctoproject.org/docs/current/poky-ref-manual/poky-ref-manual.html)
  * [Bitbake Cheat Sheet](http://elinux.org/Bitbake_Cheat_Sheet)
  * [Using Quilt](https://wiki.debian.org/UsingQuilt)
