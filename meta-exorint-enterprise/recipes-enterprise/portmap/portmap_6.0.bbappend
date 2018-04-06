python () {
    if oe.utils.contains ('MACHINE_FEATURES', 'fastboot', True, False, d):
	bb.data.setVar('INITSCRIPT_PARAMS', "start 25 5 . start 32 0 6 . stop 81 1 .", d)
}

INITSCRIPT_PARAMS_wu16 = "start 12 5 . start 32 0 6 . stop 81 1 ."
