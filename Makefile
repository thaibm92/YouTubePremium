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
      	@mkdir -p Resources/Frameworks/Alderis.framework && find .theos/obj/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \;
      	@cp -R Tweaks/YTUHD/layout/Library/Application\ Support/YTUHD.bundle Resources/
      	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/
      	@cp -R Tweaks/Return-YouTube-Dislikes/layout/Library/Application\ Support/RYD.bundle Resources/
      	@cp -R Tweaks/YTABConfig/layout/Library/Application\ Support/YTABC.bundle Resources/
      	@cp -R Tweaks/DontEatMyContent/layout/Library/Application\ Support/DontEatMyContent.bundle Resources/
      	@cp -R Tweaks/YTHoldForSpeed/layout/Library/Application\ Support/YTHoldForSpeed.bundle Resources/
      	@cp -R Tweaks/YTVideoOverlay/layout/Library/Application\ Support/YTVideoOverlay.bundle Resources/
      	@cp -R Tweaks/YouMute/layout/Library/Application\ Support/YouMute.bundle Resources/
      	@cp -R Tweaks/YouQuality/layout/Library/Application\ Support/YouQuality.bundle Resources/
      	@cp -R Tweaks/iSponsorBlock/layout/Library/Application\ Support/iSponsorBlock.bundle Resources/
      	@cp -R Tweaks/Reborn/Library/Application\ Support/YouTubeReborn.bundle Resources/
      	@cp -R lang/YouTubeRebornPlus.bundle Resources/
      	@echo -e "==> \033[1mChanging the installation path of dylibs...\033[0m"
