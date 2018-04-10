uSO1 BSP README
===============

#### Last modified:  `03/02/2016`

<br>

### Intro

The `bsptool` command provides the following functionality to manage Exorint
BSP / Yocto repositories more efficiently:

  * simple `build` command;
  * execution of `git`, `bitbake` or custom commands on all configured repos;
  * building of an RPM repository;
  * deployment (currently only to mounted partitions);
  * centralized and version-controlled configuration.

### Workspace

This is the recommended FS layout for the BSP build environment:

       ~work/                       # base project working directory
            {stable,unstable}       # stable and unstable build dirs
                git/                # GIT source repositories
                build/              # Yocto build dir (refer to Yocto docs for info on content)
                shared/             # shared data
                    sstate-cache/   # shared state directory
            downloads/              # shared downloads
            delivering/             # where files are deployed (e.g licenses and images produced by Jenkins)

#### Getting sources

For more notes on first-time setup, including public key access to Unfuddle repositories: [https://exorint.unfuddle.com/a#/projects/1/notebooks/16/pages/2073/latest]().

To prepare an unstable build:

    $ mkdir -p work/unstable/git
    $ cd work/unstable/git
    $ git clone -b exorint git@exorint.unfuddle.com:exorint/yocto-bsp.git bsp

To build a stable BSP, follow the same procedure, but using work/stable/git as base for sources, and then checking out the stable branch, e.g.:

    $ cd bsp
    $ ./bsptool cmd git checkout exorint-1.x.x

#### Configuration

Some environment variables can be overridden in `bsptool.local` (defaults 
in `bsptool.defaults`), while other Yocto-specific variables can be modified via 
`conf/local.conf`.

When setting up the build environment, `bsptool` copies configuration files
from the `conf` directory into Yocto's environment.

If you modify repositories, make sure the `REPOS` variable in
`bsptool.defaults` and `conf/bblayers.conf` are aligned.

#### Build

    $ cd bsp
    $ ./bsptool world           # clones and builds child repos

#### Other Usage

For information on usage please refer to `./bsptool help`.

#### Tested on

  * Ubuntu 12.04
  * Ubuntu 14.04


### Layer Organization

  * `poky` provides core Yocto recipes and functionality;
  * `meta-openembedded` provides extra upstream system and utility recipes;
  * `meta-exorint` provides *public* Exorint-specific recipes and overrides;
  * `meta-exorint-enterprise` provides *private* Exorint-specific recipes and overrides;
  * `meta-branding-<xyz>` provides brand-specific package recipes and image definitions -
  currently only meta-branding-exorint is provided.


### Filesystem Layout

  Default Yocto conventions are followed for installation variabiles. Here is a
  subset of the most important ones:

<table>
  <tr><td align="right">`${prefix}`</td><td>`/usr`</td></tr>
  <tr><td align="right">`${bindir}`</td><td>`/usr/bin`</td></tr>
  <tr><td align="right">`${sbindir}`</td><td>`/usr/sbin`</td></tr>
  <tr><td align="right">`${libdir}`</td><td>`/usr/lib`</td></tr>
  <tr><td align="right">`${sysconfdir}`</td><td>`/etc`</td></tr>
  <tr><td align="right">`${localstatedir}`</td><td>`/var`</td></tr>
  <tr><td align="right">`${datadir}`</td><td>`/usr/share`</td></tr>
</table>


### Developer Notes

##### General

  * IMPORTANT: no automatic `INCPR` mechanism is used, so developers must
    remember to increment `PR` versions when modifying recipes (not so much for
    Yocto build, but to release new packages to the package management
    system).
  
##### Versioning

  * The current development branch for all Yocto layers is `exorint`;
  * The current stable branch for all Yocto layers is `exorint-1.x.x`;
  * Individual packages will generally have a `master` main branch and may have
    a corresponding `exorint-1.x.x` stable branch;
  * Releases will be marked via a unique tag on all BSP repositories.

##### Packaging

  * Exorint packages are not released in source format, so the current policy
    is to download the source from git repositories and to checkout a specific
    tag. See the [Recipes](#_recipes) Section for info on how to do this.
  
##### <a name="_recipes"></a> Recipes

This Section refers to `meta-exorint` repository unless otherwise specified.
Some useful tips:

  * Exorint recipes for proprietary packages should be placed
    under `recipes-enterprise`;
  * you can inherit from the `exorint-src` class to retrieve package
    source code. The default path for Exorint packages will be used, so in most
    cases no extra variables other than the standard `SRCREV` will need to be
    specified (if the repository name matches the package name). Other available
    variables to customise the download URL are documented in the source code under
    `classes/exorint-src.bbclass`;
  * `jmuconfig` is an example of JS-based recipe (no compilation required);
  * `jmuconfig-app` is an example of Qt-based recipe;
  * in `packagegroups` you can find some samples of virtual packages;
  * other recipes in `recipes-*` provide *Exorint-specific* bbappends for recipes in other layers. 
    *Generic/reusable* ovverides should be placed in the current Exorint branch
    of the appropriate layer (and shared to public if required by license).

##### Official repositories (for upstream remotes)
  * [git://git.yoctoproject.org/poky]()
  * [git://git.openembedded.org/meta-openembedded]()
  * [git://git.yoctoproject.org/meta-ti]()

### References
  * [Internal Yocto Documentation](README-YOCTO.md)
