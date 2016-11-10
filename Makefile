
THEOS_DEVICE_IP = 192.168.0.115
include $(THEOS)/makefiles/common.mk
ARCHS = arm64
TWEAK_NAME = WCTimelineSightRetweet
WCTimelineSightRetweet_FILES = Tweak.xm
WCTimelineSightRetweet_FRAMEWORKS = UIKit CoreGraphics
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
