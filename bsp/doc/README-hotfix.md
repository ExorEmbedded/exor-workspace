Hotfix Release README
=====================

#### Last modified:  `26/05/2017`

## Intro

This guide should aid in creating ad-hoc hotfix releases for specific customers
which branch off from official releases.

To remain fully compatible with the current versioning system, the policy is to
allocate the "next" version number of the main branch, even if such version
has no relation to the version we are branching from.

## Steps

### 1. Decide a branch name

.. given the *initial version* from which the branch will be created `x.y.z0`,
define the branch name `customer[-bsp]-x.y.z0-hotfix`.

### 2. Reserve a version number for hotfix release

Within your stable branch workspace (e.g. `/home/autosvn/work/stable`), increment version numbers
in `meta-branding-exorint/recipes-image/images/{mainos,config}-version.inc` by 2
and commit/push with a message similar to the following:

e.g. 

    $ git ci -m "VERSION bumped by 2 so x.y.z is allocated to customer[-bsp]-x.y.z-hotfix"
    $ git push origin exorint-1.x.x

### 3. Create a new branch workspace (first hotfix release only)

    $ cd /home/work
    $ cp -a stable customer[-bsp]-x.y.z0-hotfix
    $ cd customer[-bsp]-x.y.z0-hotfix/bsp

### 4. Branch off all repos starting from x.y.z0 (first hotfix release only)

    $ ./bsptool cmd git co -b customer[-bsp]-x.y.z0-hotfix rootfs-x.y.z0
    $ ./bsptool cmd git push origin customer[-bsp]-x.y.z0-hotfix

### 5. Manual changes and set version

a) For each package involved in the patch - if no hotfix branch exists for the package:

    $ git co -b customer-[-bsp]-x.y.x-hotfix revision
    $ git push origin customer-[-bsp]-x.y.x-hotfix

where `revision` is grabbed from the Yocto recipe tagged at `x.y.z0`. For example for EPAD:

    $ meta-exorint-enterprise stewy [exorint-1.x.x] $ git show rootfs-x.y.z0:recipes-enterprise/epad/epad_git.bb | grep SRCREV

Otherwise just checkout/pull and proceed with the hotfixing.

*NOTE*: we assume customers with hotfix requirements are "not agile" and as
such they do not have their own customer-specific unstable/master branches.
Given this assumption, perform the following 4 commits(+push)/cherry-picks for the fix on the following branches:
- 2 commits on package branches (`customer[-bsp]-1.x.x` and `customer-[-bsp]-x.y.z0-hotfix`);
- 2 recipe commits on Yocto repos (`exorint-1.x.x` and `customer-[-bsp]-x.y.z0-hotfix`).

b) When all fixes are complete, set versions in
`meta-branding-exorint/recipes-image/images/{mainos,config}-version.inc` to the
version `x.y.z` allocated in 2).

### 6. Build and test the images

    $ ./bsptool bb [ -m machine ] core-image-mainos-branding-exorint core-image-configos-branding-exorint

Repeat steps 5a) and 6) if any changes are required.

### 7. Perform manual tagging

Using the new version `x.y.z`:

    $ ./bsptool cmd git tag customer[-bsp]-x.y.z-hotfix
    $ ./bsptool cmd git push origin customer[-bsp]-x.y.z-hotfix

## Other important notes

### Changing base version for hotfix branches

If customers require a major update to the state of the art features + fixes
contained in main stable branches (`exorint-1.x.x`), we need to change the
initial version of the hotfix branch from `x.y.z` to `a.b.c`. The steps
required will be the same as discussed above, with an additional step before 4a):
for all packages with customer branding (e.g. EPAD, jmuconfig, ..):

    $ git co customer[-bsp]-1.x.x
    $ git pull
    $ git merge origin/exorint-1.x.x   # and fix any existing conflicts

The hotfix branch will then start from this new `customer[-bsp]-1.x.x`. 

This step is a *MUST* because our current development workflow does not require
customer branches to be updated directly when changes to `exorint-1.x.x` are
made, so they will generally be outdated.
