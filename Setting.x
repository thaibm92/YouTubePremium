#import <LocalAuthentication/LocalAuthentication.h>
#import <Foundation/Foundation.h>
#import <CaptainHook/CaptainHook.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <rootless.h>
// YT Headers
#import "YouTubeHeader/ASCollectionElement.h"
#import "YouTubeHeader/ELMCellNode.h"
#import "YouTubeHeader/ELMNodeController.h"
#import "YouTubeHeader/YTIElementRenderer.h"
#import "YouTubeHeader/YTISectionListRenderer.h"
#import "YouTubeHeader/YTReelModel.h"
#import "YouTubeHeader/YTVideoWithContextNode.h"
#import "YouTubeHeader/ASCollectionView.h"
#import "YouTubeHeader/ELMContainerNode.h"
#import "YouTubeHeader/YTIFormattedString.h"
#import "YouTubeHeader/GPBMessage.h"
#import "YouTubeHeader/YTIStringRun.h"
#import "YouTubeHeader/QTMIcon.h"
#import "YouTubeHeader/YTColor.h"
#import "YouTubeHeader/YTColorPalette.h"
#import "YouTubeHeader/YTCommonColorPalette.h"
#import "YouTubeHeader/YTPageStyleController.h"
#import "YouTubeHeader/YTHotConfig.h"
#import "YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "YouTubeHeader/YTISectionListRenderer.h"
#import "YouTubeHeader/YTWatchNextResultsViewController.h"
#import "YouTubeHeader/YTIMenuConditionalServiceItemRenderer.h"
#import "YouTubeHeader/YTPlaybackStrippedWatchController.h"
#import "YouTubeHeader/YTSlimVideoDetailsActionView.h"
#import "YouTubeHeader/YTSlimVideoScrollableActionBarCellController.h"
#import "YouTubeHeader/YTSlimVideoScrollableDetailsActionsView.h"
#import "YouTubeHeader/YTTouchFeedbackController.h"
#import "YouTubeHeader/YTWatchViewController.h"
// YT Headers - snackbar
#import "YouTubeHeader/YTHUDMessage.h"
#import "YouTubeHeader/GOOHUDManagerInternal.h"
// YTNoPaidPromo
#import "YouTubeHeader/YTPlayerOverlay.h"
#import "YouTubeHeader/YTPlayerOverlayProvider.h"

@interface YTITopbarLogoRenderer : NSObject // Enable Premium logo - @bhackel
@property(readonly, nonatomic) YTIIcon *iconImage;
@end

// YouTube Premium Logo - @arichornlover & @bhackel
%hook YTHeaderLogoController
- (void)setTopbarLogoRenderer:(YTITopbarLogoRenderer *)renderer {
    YTIIcon *iconImage = renderer.iconImage;
    iconImage.iconType = 537;
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

//-------------------------
