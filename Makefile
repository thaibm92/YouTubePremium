TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64

ifndef YOUTUBE_VERSION
YOUTUBE_VERSION = xx.xx.x
endif

TWEAK_NAME = YouTubePremium
BUNDLE_ID = com.google.ios.youtube
DISPLAY_NAME = YouTube

$(TWEAK_NAME)_INJECT_DYLIBS = .theos/obj/YouPiP.dylib
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/YouPiP
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
      	@echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
      	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/
