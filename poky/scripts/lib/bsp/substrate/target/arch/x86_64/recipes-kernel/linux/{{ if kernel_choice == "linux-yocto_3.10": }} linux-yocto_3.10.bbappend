FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.1"

COMPATIBLE_MACHINE_{{=machine}} = "{{=machine}}"

{{ input type:"boolean" name:"need_new_kbranch" prio:"20" msg:"Do you need a new machine branch for this BSP (the alternative is to re-use an existing branch)? [y/n]" default:"y" }}

{{ if need_new_kbranch == "y": }}
{{ input type:"choicelist" name:"new_kbranch" gen:"bsp.kernel.all_branches" branches_base:"standard:standard/common-pc-64" prio:"20" msg:"Please choose a machine branch to base this BSP on:" default:"standard/common-pc-64/base" }}

{{ if need_new_kbranch == "n": }}
{{ input type:"choicelist" name:"existing_kbranch" gen:"bsp.kernel.all_branches" branches_base:"standard:standard/common-pc-64" prio:"20" msg:"Please choose a machine branch to base this BSP on:" default:"standard/common-pc-64/base" }}

{{ if need_new_kbranch == "n": }}
KBRANCH_{{=machine}}  = "{{=existing_kbranch}}"

{{ input type:"boolean" name:"smp" prio:"30" msg:"Do you need SMP support? (y/n)" default:"y"}}
{{ if smp == "y": }}
KERNEL_FEATURES_append_{{=machine}} += " cfg/smp.scc"

SRC_URI += "file://{{=machine}}-standard.scc \
            file://{{=machine}}-user-config.cfg \
            file://{{=machine}}-user-patches.scc \
            file://{{=machine}}-user-features.scc \
           "

# uncomment and replace these SRCREVs with the real commit ids once you've had
# the appropriate changes committed to the upstream linux-yocto repo
#SRCREV_machine_pn-linux-yocto_{{=machine}} ?= "b170394a475b96ecc92cbc9e4b002bed0a9f69c5"
#SRCREV_meta_pn-linux-yocto_{{=machine}} ?= "c2ed0f16fdec628242a682897d5d86df4547cf24"
#LINUX_VERSION = "3.10.9"