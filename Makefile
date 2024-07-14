TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = YouTube
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTubePremium

$(TWEAK_NAME)_FILES = Tweak.x Settings.x YouTubeRebornPlus.xm Settings.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	@echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
	@cp -R lang/YouTubeRebornPlus.bundle Resources/
