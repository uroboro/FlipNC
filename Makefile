include theos/makefiles/common.mk

SOURCE_DIR = sources
EXTENSIONS = c cpp m mm x xm

BUNDLE_NAME = FlipNC
FlipNC_FILES = $(foreach ext, $(EXTENSIONS), $(wildcard $(SOURCE_DIR)/*.$(ext)))
FlipNC_INSTALL_PATH = /Library/WeeLoader/Plugins
FlipNC_FRAMEWORKS = UIKit CoreGraphics
FlipNC_LIBRARIES = flipswitch

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard backboardd"
