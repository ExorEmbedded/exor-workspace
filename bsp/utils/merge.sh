#!/bin/bash -e
#
# *EXPERIMENTAL* utility to perform BSP merges:
#   
# Usage:
#   1) ./merge.sh               full from a given tag into the current tree
#   2) ./merge.sh #TICKET_ID    merge single ticket
#
# Prerequisites:
#   - setup repo tree as per REPOS and PKG_REPOS definitions
#
# Important Notes:
#   - you are *STRONGLY ADVISED* to create a new dedicated repo tree since local
#     changes will be wiped!!
#   - use with CAUTION! When used to merge single tickets, may grab unwanted
#     commits from 3rd party repositories following same #ticket-id convention..
#     we should extend it to include a known label
#
# TODO LIST:
#   1) automatic repo cloning
#   2) merge also other brands automatically (e.g. pgd_ca-1.x.x)
#       Currently need to do a manual exact merge as follows:
#            git merge --no-commit -s ours ${from_ref}
#            git diff --binary ${from_ref} --exit-code | git apply -R --index 
#            git commit -m "merge.sh: Merge tag '${MERGE_FROM_VER}' into ${MERGE_TO_REF} (branded)"
#       Then when prompted to push meta-exorint-enterprise, make sure you update recipes with branded branches 
#       (git reset --soft HEAD~ + git ci --amend..)!
#   3) SVN merge handling (e.g. if jmuconfig-app ever has stable branch)
#        OR move hmibrowser to GIT
#   4) if new stable branches are added, recipe patching logic needs to be extended;
#     also need to handle different platforms (bootloader, kernel)
#   5) preserve and use SRCBRANCH to make sure tag really exists on branch

MERGE_FROM_VER="1.999.180"

# full BSP merges should always be done from a specific version tag 
MERGE_FROM_REF="rootfs-${MERGE_FROM_VER}"
# cherry-picks can be done from a branch such as:
#MERGE_FROM_REF="origin/exorint"

MERGE_TO_REF="exorint-1.x.x"

VERBOSE="0"
INTERACTIVE="1"
NOFETCH="0"
NOPUSH="0"

[ -z ${YOCTO_DIR} ] &&              YOCTO_DIR="${HOME}/work/bsp-src/stable/yocto"
[ -z ${PKG_DIR} ] &&                PKG_DIR="${HOME}/work/bsp-src/stable/pkgs"

# custom overrides
[ -e ~/.merge.env ] && . ~/.merge.env
[ -e .merge.env ] && . .merge.env

[ -z ${BOOTLOADER_PKG_DIR} ] &&     BOOTLOADER_PKG_DIR="${PKG_DIR}/uboot"               # no stable branch -> no merge necessary
[ -z ${XLOADER_PKG_DIR} ] &&        XLOADER_PKG_DIR="${PKG_DIR}/uboot"                  # no stable branch -> no merge necessary
[ -z ${PSPLASH_PKG_DIR} ] &&        PSPLASH_PKG_DIR="${PKG_DIR}/ltools-psplash"         # no stable branch -> no merge necessary
[ -z ${LINUX_PKG_DIR} ] &&          LINUX_PKG_DIR="${PKG_DIR}/ltools-psplash"           # no stable branch -> no merge necessary
[ -z ${BASE_PKG_DIR} ] &&           BASE_PKG_DIR="${PKG_DIR}/yocto-base"                # *SPECIAL CARE* in merging migration scripts
[ -z ${ENCLOUD_PKG_DIR} ] &&        ENCLOUD_PKG_DIR="${PKG_DIR}/encloud"                # no stable branch -> no merge necessary
[ -z ${EPAD_PKG_DIR} ] &&           EPAD_PKG_DIR="${PKG_DIR}/ltools-epad"               # MERGE ME: has stable exorint-1.x.x, pgd_ca-1.x.x
[ -z ${JMLAUNCHER_PKG_DIR} ] &&     JMLAUNCHER_PKG_DIR="${PKG_DIR}/jml"                 # MERGE ME: has stable exorint-1.x.x
[ -z ${JMUCONFIG_PKG_DIR} ] &&      JMUCONFIG_PKG_DIR="${PKG_DIR}/jmuconfig"            # MERGE ME: has stable exorint-1.x.x, pgd_ca-1.x.x
[ -z ${JMUCONFIGAPP_PKG_DIR} ] &&   JMUCONFIGAPP_PKG_DIR="${PKG_DIR}/hmibrowser"        # no stable branch -> no merge necessary
[ -z ${LIBENCLOUD_PKG_DIR} ] &&     LIBENCLOUD_PKG_DIR="${PKG_DIR}/libencloud"          # MERGE ME: has stable exorint-1.x.x

[ "${VERBOSE}" = "2" ] && set -x

# REPOS: Table containing top-level repos
#
#               name/directory (base is YOCTO_DIR)
REPOS=""
REPOS="${REPOS} bsp"
REPOS="${REPOS} poky"
REPOS="${REPOS} meta-openembedded"
REPOS="${REPOS} meta-exorint"
REPOS="${REPOS} meta-exorint-enterprise"
REPOS="${REPOS} meta-branding-exorint"
### Other repos (e.g. utils)
#REPOS="${REPOS} usbupdater"  # stable is currently set to master => no merge necessary

# PKG_REPOS: Table containing internal source repositories to be merged
#
#                       name           source path                 recipe  (.bb or .inc depending on where SRCREV is defined)
PKG_REPOS=""
PKG_REPOS="${PKG_REPOS} bootloader     ${BOOTLOADER_PKG_DIR}       meta-exorint/recipes-bsp/bootloader/bootloader.inc" 
PKG_REPOS="${PKG_REPOS} xloader        ${XLOADER_PKG_DIR}          meta-exorint/recipes-bsp/xloader/xloader.inc"
PKG_REPOS="${PKG_REPOS} psplash        ${PSPLASH_PKG_DIR}          meta-exorint/recipes-core/psplash/psplash_git.bb"
PKG_REPOS="${PKG_REPOS} linux          ${LINUX_PKG_DIR}            meta-exorint/recipes-kernel/linux/linux.inc"
PKG_REPOS="${PKG_REPOS} base           ${BASE_PKG_DIR}             meta-exorint-enterprise/recipes-enterprise/base/base.inc"
PKG_REPOS="${PKG_REPOS} encloud        ${ENCLOUD_PKG_DIR}          meta-exorint-enterprise/recipes-enterprise/encloud/encloud_git.bb"
PKG_REPOS="${PKG_REPOS} epad           ${EPAD_PKG_DIR}             meta-exorint-enterprise/recipes-enterprise/epad/epad_git.bb"
PKG_REPOS="${PKG_REPOS} jmlauncher     ${JMLAUNCHER_PKG_DIR}       meta-exorint-enterprise/recipes-enterprise/jmlauncher/jmlauncher_git.bb"
PKG_REPOS="${PKG_REPOS} jmuconfig      ${JMUCONFIG_PKG_DIR}        meta-exorint-enterprise/recipes-enterprise/jmuconfig/jmuconfig.bb"
PKG_REPOS="${PKG_REPOS} jmuconfig-app  ${JMUCONFIGAPP_PKG_DIR}     meta-exorint-enterprise/recipes-enterprise/jmuconfig-app/jmuconfig-app_svn.bb"
PKG_REPOS="${PKG_REPOS} libencloud     ${LIBENCLOUD_PKG_DIR}       meta-exorint-enterprise/recipes-enterprise/libencloud/libencloud_git.bb"
PKG_REPOS_NCOLS="3"

WARNINGS_NUM="0"
PROG_NAME="$(basename $0)"
VERSION="0.0.6 (alpha)"
COMMIT_MSG="${PROG_NAME}: Merge tag '${MERGE_FROM_VER}' into ${MERGE_TO_REF}"

usage ()
{
    msg "Usage: ${PROG_NAME} [OPTIONS]                                      "
    msg
    msg "OPTIONS:                                                           "
    msg "         - TICKET_ID  if specified, the single ticket is merged    "
    msg "                      (e.g. ./merge.sh "#123"),                    "
    msg "                      otherwise do a full BSP merge                "
}

msg ()
{
    echo "# $@"
}

info ()
{
    msg "[info] $@"
}

warn ()
{
    msg "[*WARNING*] $@"
    WARNINGS_NUM=$[WARNINGS_NUM + 1]
}

err ()
{
    msg "[ERROR] $@" 1>&2
    return 1
}

crit ()
{
    msg "[**CRITICAL**] $@"
    return 1
}

note ()
{
    msg "[NOTE] $@"
}

dbg ()
{
    if [ "${VERBOSE}" = "1" ]; then
        msg "[dbg] $@"
    fi
}

prompt ()
{
    if [ "${INTERACTIVE}" = "0" ]; then
        msg "[non-interactive] $@"
        return 0
    fi

    while true; do
        info "$@"
        msg
        read -n1 -r -s -p "# Press SPACE/ENTER to continue or 'q' to quit" char
        echo
        msg
        case ${char} in
           "")
            return 0
            ;;
           q)
            msg "Quit requested - exiting."
            exit 0
            ;;
           *) 
            ;;
        esac
    done
}

prompt_warn ()
{
    warn "$@"
    prompt "$@"
}

git_checkout ()
{
    local to_ref=$1

    git clean -fdx . >/dev/null
    git reset --hard HEAD >/dev/null
    git checkout ${to_ref} >/dev/null 2>&1 || return 1
    git reset --hard origin/${to_ref} >/dev/null
}

# Equivalent of merge -s 'theirs' which no longer exists
# [http://jeetworks.org/unconditionally-accepting-all-merging-in-changes-during-a-git-merge/]
git_merge_theirs ()
{
    local from_ref=$1

    info "Merging from '${from_ref}'"

    git merge --no-commit -s ours ${from_ref} >/dev/null
    git diff --binary ${from_ref} --exit-code | git apply -R --index 2>/dev/null
}

git_pick ()
{
    local repo=$1
    local from_ref=$2
    local ticket=$3

    info "Cherry-picking on '${repo}'"

    commits=$(git log --oneline ${from_ref} | grep "${ticket} " | cut -d ' ' -f 1)
    if [ "${commits}" = "" ]; then
        info "no commits for ticket '${ticket}'"
        return 0
    fi
    reverse_commits=$(echo ${commits} | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }')
    for cid in ${reverse_commits}; do
        prompt "Applying commit: ${cid}"
        git cherry-pick -n -X theirs ${cid} || prompt "Cherry-pick failed - please fix manually (see 'git status')"
    done
}

git_show_recipe_field ()
{
    local recipe=$1
    local ref=$2
    local field=$3

    if [ ! -d .git ]; then
        err "No valid git repo found in: $(pwd)"
        return 1
    fi

    git show $ref:$recipe 2>/dev/null | grep "^${field} =" | cut -d '=' -f 2 | tr -d ' ' | tr -d '"'
}

# Change source revision
yocto_sub_srcrev ()
{
    local file=$1
    local ref=$2

    sed -i "s/\(^SRCREV\ =\ \)\".*/\1\"${ref}\"/" ${file}
}

# Simple PR increment
yocto_inc_pr ()
{
    local file=$1
    local pr=$2
    local pr2

    if [ -z ${pr} ]; then
        # autoincrement value found in file
        # PR = "[<letters>]<numbers>" 
        sed -i 's/\(^PR = "\)\([^0-9]*\)\([0-9]*\)/echo \1\\"\2$((\3+1))\\"/ge' ${file}
    else
        pr2=$(echo $pr | sed 's/\([^0-9]*\)\([0-9]*\)/echo \1$((\2+1))/ge')
        dbg "pr2: ${pr2}" 
        sed -i "s/\(^PR\ =\ \)\".*/\1\"${pr2}\"/" ${file}
    fi
}

# set new SRCREV and autoincrement PR 
yocto_update_recipe ()
{
    info "Updating Yocto recipe for '${name}'"

    local recipe=$1
    local ref=$2
    local prev_pr

    info "Setting SRCREV to '${ref}' and incrementing PR"
    if [ ! -e ${recipe} ]; then
        warn "Merge successful but recipe file '${recipe}' not found - manual SRCREV + PR update will be required"
        return 0
    fi
    yocto_sub_srcrev ${recipe} ${ref}

    prev_pr=$(git show origin/${MERGE_TO_REF}:${recipe} | grep "^PR = " | sed 's/PR = "\(.*\)"/\1/')
    yocto_inc_pr ${recipe} ${prev_pr}

    git add ${recipe}
}
    
# Hard-coded/well-known merging aid for packages:
merge_package_fixes ()
{
    local repo=$1
    local from_ref=$2
    local to_ref=$3

    case ${repo} in

        base)
            git ls-tree -r --name-only "${to_ref}" files/mainos/etc/migrations | \
                egrep "to_[0-9]+_[0-8]" | xargs git co "${to_ref}"
            prompt "Package 'base' requires *SPECIAL CARE*!" \
                "We have preserved 'our' migration files but if any upstream changes" \
                "have been made, they must be merged manually!" \
                "Please make any required changes before proceeding."
            ;;
        *)
            # exact merge from 'theirs' => make sure there are no diffs from ref 
            git diff --quiet ${from_ref} || prompt "Differences found in '${from_ref}' - bad merge? Please fix manually!"
            ;;
    esac
}

merge_package ()
{
    local from_ref
    local to_ref
    local repo_dir
    local recipe_path
    local n_custom_recipes
    local merge_ref
    local merge_from

    info
    info "Merging package '${name}'"
    dbg "src_dir: ${src_dir}, recipe: ${recipe}"

    repo_dir=$(echo $recipe | cut -d '/' -f 1)
    recipe_path=$(echo $recipe | cut -d '/' -f 2-)

    #
    # Grab info from Yocto repository
    #
    pushd ${YOCTO_DIR}/${repo_dir} >/dev/null

    from_ref=$(git_show_recipe_field ${recipe_path} ${MERGE_FROM_REF} SRCREV)
    dbg "from_ref: ${from_ref}"
    to_ref=$(git_show_recipe_field ${recipe_path} ${MERGE_TO_REF} SRCREV)
    dbg "to_ref: ${to_ref}"
    if [ "${to_ref}" = "${from_ref}" ]; then
        info "No merge necessary for '${name}' (ref unchanged)."
        return 0
    fi

#   Drop unreliable SCRBRANCH usage?
#
#    from_branch=$(git_show_recipe_field ${recipe_path} ${MERGE_FROM_REF} SRCBRANCH)
#    dbg "from_branch: ${from_branch}"
#    to_branch=$(git_show_recipe_field ${recipe_path} ${MERGE_TO_REF} SRCBRANCH)
#    dbg "to_branch: ${to_branch}"
#    if [[ "${to_branch}" != "" && "${to_branch}" = "${from_branch}" ]]; then
#        yocto_update_recipe ${recipe_path} ${from_ref}
#        prompt "No merge necessary for '${name}' (branch unchanged) - please check."
#        return 0
#    fi

    [ "${to_ref}" = "" ] &&
        warn "Could not find destination tag (path to recipe may have changed) => merge will be attempted but recipe will need to be updated manually!"

    popd >/dev/null

    #
    # Perform merge in package source repo
    #
    pushd ${src_dir} >/dev/null

    if [ ! -d .git ]; then
        prompt_warn "Skipping repo '${name}' (not a GIT repo)";
        return 0
    fi

    if ! git_checkout ${MERGE_TO_REF}; then
        prompt "Could not find ref to '${MERGE_TO_REF}' - assuming there is no stable branch to be merged.";
        return 0
    fi

    if [ "${NOFETCH}" = "0" ]; then
        info "Performing git pull"
        git fetch origin 
        if ! git_checkout ${MERGE_TO_REF}; then
            prompt "Could not find ref to '${MERGE_TO_REF}' - assuming there is no stable branch to be merged.";
        fi
    fi

    if [ -z "${TICKET_ID}" ]; then

        # make sure merge is necessary and that it has not already occurred - may have been fixed manually
        if git diff --quiet ${from_ref} || git log -1 --pretty="%s" | grep -q "${COMMIT_MSG}"; then
            :
        else
            git_merge_theirs "${from_ref}"
            merge_package_fixes "${name}" "${from_ref}" "${to_ref}"
            git commit -m "${COMMIT_MSG}" >/dev/null || true
        fi
    else
        merge_from="${MERGE_FROM_REF}"
        [ -e .git/refs/remotes/${merge_from} ] || merge_from="origin/master"
        git_pick ${name} ${merge_from} ${TICKET_ID}
        # git will use the cherry-pick from incomplete cherry-pick
        git commit -m "" >/dev/null || true
    fi

    merge_ref=$(git rev-parse HEAD)
    dbg "merge_ref: ${merge_ref}"

    if [ "${merge_ref}" = "${to_ref}" ]; then
        info "No merge necessary for '${name}' (ref unchanged)."
        return 0
    fi

    if [ "${NOPUSH}" = "0" ]; then
        prompt "Package '${name}' ready - please check and continue when you are ready for push."
        git push origin ${MERGE_TO_REF}
    fi

    popd >/dev/null  # exit src_dir

    pushd ${YOCTO_DIR}/${repo_dir} >/dev/null
    yocto_update_recipe ${recipe_path} ${merge_ref}
    popd >/dev/null

    if [ "${NOPUSH}" = "1" ]; then
        prompt "Finished Processing package '${name}' - please check."
    fi
}

merge_packages ()
{
    local name
    local src_dir
    local recipe

    info 
    info "MERGING SOURCE PACKAGES"

    set ${PKG_REPOS}
    while [ $# -ge ${PKG_REPOS_NCOLS} ]; do
        name=$1
        src_dir=$2
        recipe=$3
        merge_package ${name} ${src_dir} ${recipe}
        shift; shift; shift
    done
}

clean_toprepos ()
{
    info
    info "CLEANING TOP-LEVEL REPOS"

    for repo in ${REPOS}; do
        [ -d ${YOCTO_DIR}/${repo} ] || crit "Could not find top-level repo '${repo}' in dir '${YOCTO_DIR}/${repo}' - please refer to REPO variable."
        pushd ${YOCTO_DIR}/${repo} >/dev/null
        git_checkout ${MERGE_TO_REF}
        popd >/dev/null
    done
}

# Hard-coded/well-known merging aid for top-level Yocto packages:
#   - version.inc files are generally related to BSP se we keep 'ours'
#   - for all the rest we want new updates, so use 'theirs'
merge_toprepos_fixes ()
{
    local repo=$1

    case ${repo} in
        meta-exorint|meta-exorint-enterprise|meta-branding-exorint)
            for version_file in $(git ls-files *version.inc); do
                git co origin/${MERGE_TO_REF} "${version_file}"
            done
            ;;
    esac
}

# Just merge - don't commit/push yet (recipes need to be updated first)
merge_toprepos ()
{
    local commits
    local reverse_commits

    info
    info "MERGING TOP-LEVEL REPOS"

    for repo in ${REPOS}; do
        pushd ${YOCTO_DIR}/${repo} >/dev/null
        if [ "${NOFETCH}" = "0" ]; then 
            info "Fetching repo '${repo}'"
            git fetch origin 
            if ! git_checkout ${MERGE_TO_REF}; then
                prompt "Could not find ref to '${MERGE_TO_REF}' - assuming there is no stable branch to be merged.";
            fi
        fi
        if [ -z "${TICKET_ID}" ]; then
            if git diff --quiet ${MERGE_FROM_REF} || git log -1 --pretty="%s" | grep -q "${COMMIT_MSG}"; then
                :
            else
                git_merge_theirs ${MERGE_FROM_REF}
                merge_toprepos_fixes ${repo}
            fi
        else
            merge_from="${MERGE_FROM_REF}"
            [ -e .git/refs/remotes/${merge_from} ] || merge_from="origin/master"
            git_pick ${repo} ${merge_from} ${TICKET_ID}
        fi
        popd >/dev/null
    done
}

push_toprepos ()
{
    info
    info "PUSHING TOP-LEVEL REPOS"

    for repo in ${REPOS}; do
        pushd ${YOCTO_DIR}/${repo} >/dev/null
        if git diff --quiet origin/${MERGE_TO_REF}; then
            info "No changes applied to repo '${repo}'"
            continue;
        fi

        if [ -z "${TICKET_ID}" ]; then
            git commit -m "${COMMIT_MSG}" >/dev/null || true
            git diff --quiet ${MERGE_FROM_REF} ||
                note "Differences found in '${MERGE_FROM_REF}' (could be due to recipe changes)"
        else
            # git will use the commit message from incomplete cherry-pick
            git commit -m "" >/dev/null || true
        fi

        prompt "Are you ready to push changes to repo '${repo}'?"

        if [ "${NOPUSH}" = "0" ]; then
            git push origin ${MERGE_TO_REF}
        fi
        popd >/dev/null
    done
}

# Initialisation and checks
pre ()
{
    clean_toprepos
    check_repos
}

check_repos ()
{
    local name
    local src_dir
    local recipe
    local recipe_count
    local recipe_repos
    local repo_dir
    local repo_dirs

    # check existence of top-level repos 
    for repo in ${REPOS}; do
        [ -d ${YOCTO_DIR}/${repo} ] || crit "Could not find top-level repo '${repo}' in dir '${YOCTO_DIR}/${repo}' - please refer to REPO variable."
    done

    # check existence of package repos and grab repo dirs
    set ${PKG_REPOS}
    while [ $# -ge ${PKG_REPOS_NCOLS} ]; do
        name=$1
        src_dir=$2
        recipe=$3
        repo_dir=$(echo ${recipe} | cut -d '/' -f 1)
        [ -d ${src_dir} ] || crit "Could not find package repo '${name}' in dir '${src_dir}' - please refer to PKG_REPOS variable."
        repo_dirs="${repo_dirs} ${repo_dir}"
        shift; shift; shift
    done

    # unique repo dirs
    recipe_repos=$(echo "${repo_dirs}" | sed 's/ *//' | tr ' ' '\n' | uniq)

    # show a warning if number of local repos doesn't match number of recipes
    for repo in ${recipe_repos}; do
        pushd ${YOCTO_DIR}/${repo} >/dev/null
        n_custom_recipes=$(git ls-files | xargs grep "inherit exorint-src" | wc -l)
        dbg "n_custom_recipes: ${n_custom_recipes}"
        set ${PKG_REPOS}
        n_local_recipes=0
        while [ $# -ge ${PKG_REPOS_NCOLS} ]; do
            recipe=$3
            repo_dir=$(echo ${recipe} | cut -d '/' -f 1)
            if [ "${repo_dir}" = "${repo}" ]; then
                n_local_recipes=$[n_local_recipes+1]
            fi
            shift; shift; shift
        done
        dbg "n_local_recipes: ${n_local_recipes}"
        [ "${n_custom_recipes}" != "${n_local_recipes}" ] &&
            warn "Number of locally defined recipes in '${repo}' (${n_local_recipes}) does not match number of custom recipes (${n_custom_recipes}) - merge may not have full coverage!";
        popd >/dev/null
    done
}

# Post-processing and checks
post ()
{
    true
}

run ()
{
    msg
    info
    info " - ${PROG_NAME} v${VERSION} - "
    info

    msg
    usage
    msg

    TICKET_ID=$1

    msg "Environment Dump:"
    msg "   PKG_DIR: ${PKG_DIR}"
    msg "   YOCTO_DIR: ${YOCTO_DIR}"
    msg

    if [ -z "${TICKET_ID}" ]; then
        msg "Starting merge (full).."
    else
        echo ${TICKET_ID} | grep -q "^#" || err "TICKET_ID must start with '#', e.g: ./${PROG_NAME} \"#123\""
        msg "Starting BSP merge (ticket: ${TICKET_ID}).."
    fi
    msg

    prompt "*IMPORTANT*: please make sure you backup your work - this procedure will reset Yocto and package repositories!!!"
}

run "$@"
pre
merge_toprepos
merge_packages
push_toprepos
post

info "Merging complete with ${WARNINGS_NUM} warning(s)"
