include theos/makefiles/common.mk

BUNDLE_NAME = FlipNC
FlipNC_FILES = FlipNCListController.mm
FlipNC_INSTALL_PATH = /Library/PreferenceBundles
FlipNC_FRAMEWORKS = UIKit
FlipNC_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FlipNC.plist$(ECHO_END)
