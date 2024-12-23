#import "Header.h"

// YouTube Premium Logo - @arichornlover & @bhackel
@interface YTITopbarLogoRenderer : NSObject
@property(readonly, nonatomic) YTIIcon *iconImage;
@end
//enable logo premium
%hook YTHeaderLogoController
- (void)setTopbarLogoRenderer:(YTITopbarLogoRenderer *)renderer {
    YTIIcon *iconImage = renderer.iconImage;
    //iconImage.iconType = 537;
    iconImage.iconType = YT_PREMIUM_LOGO;
    %orig;
}
- (void)setPremiumLogo:(BOOL)isPremiumLogo {
    isPremiumLogo = YES;
    %orig;
}
- (BOOL)isPremiumLogo {
    return YES;
}
%end
/*
//------new
// YouTube Premium Logo - @arichornlover & bhackel
%hook YTHeaderLogoController
- (void)setTopbarLogoRenderer:(YTITopbarLogoRenderer *)renderer {
    // Modify the type of the icon before setting the renderer
    YTIIcon *icon = [%c(YTIIcon) new];
    icon.iconType = YT_PREMIUM_LOGO; // magic number (537) for Premium icon, hopefully it doesnt change. 158 (YT_DEFAULT_LOGO) is default logo.
    // Use this modified renderer
    %orig;
}
// For when spoofing before 18.34.5
- (void)setPremiumLogo:(BOOL)isPremiumLogo {
    isPremiumLogo = YES;
    %orig;
}
- (BOOL)isPremiumLogo {
    return YES;
}
%end
*/

// Keychain patching
static NSString *accessGroupID() {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess)
            return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];

    return accessGroup;
}

// Fix login for YouTube 18.13.2 and higher
%hook SSOKeychainHelper
+ (NSString *)accessGroup {
    return accessGroupID();
}
+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

// Fix login for YouTube 17.33.2 and higher
%hook SSOKeychainCore
+ (NSString *)accessGroup {
    return accessGroupID();
}

+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

// Hide Upgrade Dialog
%hook YTGlobalConfig
//- (BOOL)shouldBlockUpgradeDialog { return YES; }
- (BOOL)shouldForceUpgrade { return NO;}
- (BOOL)shouldShowUpgrade { return NO;}
- (BOOL)shouldShowUpgradeDialog { return NO;}
%end

// No YouTube Ads
%hook YTHotConfig
- (BOOL)disableAfmaIdfaCollection { return NO; }
%end

// NOYTPremium
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromosheetEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)arg1 { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCaps:(id)arg1 { return NO; }
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end

%hook YTIOfflineabilityFormat
%new
- (int)availabilityType { return 1; }
%new
- (BOOL)savedSettingShouldExpire { return NO; }
%end

// YTNoPaidPromo https://github.com/PoomSmart/YTNoPaidPromo
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {}
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"]) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {}
%end

//----------------------
