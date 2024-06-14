TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64
PACKAGE_VERSION = X.X.X-X.X


DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTubePremium
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
