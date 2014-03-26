export TARGET = iphone:clang:6.1
export THEOS_PACKAGE_DIR_NAME = packages

include theos/makefiles/common.mk

BUNDLE_NAME = FlipNC
FlipNC_FILES = FlipNCController.m
#FlipNC_FILES = FlipNCController.test.m
FlipNC_INSTALL_PATH = /Library/WeeLoader/Plugins
FlipNC_FRAMEWORKS = UIKit CoreGraphics
FlipNC_LIBRARIES = flipswitch
#FlipNC_CFLAGS = -I/usr/include

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard backboardd"
