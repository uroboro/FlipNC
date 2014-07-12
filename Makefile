include theos/makefiles/common.mk

BUNDLE_NAME = FlipNC
FlipNC_FILES = FlipNCController.m
FlipNC_INSTALL_PATH = /Library/WeeLoader/Plugins
FlipNC_FRAMEWORKS = UIKit CoreGraphics
FlipNC_LIBRARIES = flipswitch

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard backboardd"
