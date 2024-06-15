#import <LocalAuthentication/LocalAuthentication.h>
#import <Foundation/Foundation.h>
#import <CaptainHook/CaptainHook.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <rootless.h>
// YT Headers
#import "Tweaks/YouTubeHeader/ASCollectionElement.h"
#import "Tweaks/YouTubeHeader/ELMCellNode.h"
#import "Tweaks/YouTubeHeader/ELMNodeController.h"
#import "Tweaks/YouTubeHeader/YTIElementRenderer.h"
#import "Tweaks/YouTubeHeader/YTISectionListRenderer.h"
#import "Tweaks/YouTubeHeader/YTReelModel.h"
#import "Tweaks/YouTubeHeader/YTVideoWithContextNode.h"
#import "Tweaks/YouTubeHeader/ASCollectionView.h"
#import "Tweaks/YouTubeHeader/ELMContainerNode.h"
#import "Tweaks/YouTubeHeader/YTIFormattedString.h"
#import "Tweaks/YouTubeHeader/GPBMessage.h"
#import "Tweaks/YouTubeHeader/YTIStringRun.h"
#import "Tweaks/YouTubeHeader/QTMIcon.h"
#import "Tweaks/YouTubeHeader/YTColor.h"
#import "Tweaks/YouTubeHeader/YTColorPalette.h"
#import "Tweaks/YouTubeHeader/YTCommonColorPalette.h"
#import "Tweaks/YouTubeHeader/YTPageStyleController.h"
#import "Tweaks/YouTubeHeader/YTHotConfig.h"
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTISectionListRenderer.h"
#import "Tweaks/YouTubeHeader/YTWatchNextResultsViewController.h"
#import "Tweaks/YouTubeHeader/YTIMenuConditionalServiceItemRenderer.h"
#import "Tweaks/YouTubeHeader/YTPlaybackStrippedWatchController.h"
#import "Tweaks/YouTubeHeader/YTSlimVideoDetailsActionView.h"
#import "Tweaks/YouTubeHeader/YTSlimVideoScrollableActionBarCellController.h"
#import "Tweaks/YouTubeHeader/YTSlimVideoScrollableDetailsActionsView.h"
#import "Tweaks/YouTubeHeader/YTTouchFeedbackController.h"
#import "Tweaks/YouTubeHeader/YTWatchViewController.h"
// YT Headers - snackbar
#import "Tweaks/YouTubeHeader/YTHUDMessage.h"
#import "Tweaks/YouTubeHeader/GOOHUDManagerInternal.h"

@interface YTITopbarLogoRenderer : NSObject // Enable Premium logo - @bhackel
@property(readonly, nonatomic) YTIIcon *iconImage;
@end

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



%hook YTVersionUtils

// Works down to 16.29.4
+ (NSString *)appVersion {
    NSString *appVersion = %orig;
    if ([appVersion compare:@"17.33.2" options:NSNumericSearch] == NSOrderedAscending)
        return @"17.33.2";
    return appVersion;
}

%end

%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return YES; }
%end

%hook YTIPlayerResponse
- (BOOL)isPlayableInBackground {return YES;}
- (BOOL)isMonetized { return NO; }
%end

%hook YTIPlayabilityStatus

- (BOOL)isPlayableInBackground { return YES; }

%end

%hook MLVideo

- (BOOL)playableInBackground { return YES; }

%end

%hook YTDataUtils

+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }

%end

%hook YTAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { %orig(nil); }

%end

%hook YTAccountScopedAdsInnerTubeContextDecorator

- (void)decorateContext:(id)context { %orig(nil); }

%end

%hook YTReelInfinitePlaybackDataSource

- (void)setReels:(NSMutableOrderedSet <YTReelModel *> *)reels {
    [reels removeObjectsAtIndexes:[reels indexesOfObjectsPassingTest:^BOOL(YTReelModel *obj, NSUInteger idx, BOOL *stop) {
        return [obj respondsToSelector:@selector(videoType)] ? obj.videoType == 3 : NO;
    }]];
    %orig;
}

%end

BOOL isAdString(NSString *description) {
    if ([description containsString:@"brand_promo"]
        || [description containsString:@"carousel_footered_layout"]
        || [description containsString:@"carousel_headered_layout"]
        || [description containsString:@"feed_ad_metadata"]
        || [description containsString:@"full_width_portrait_image_layout"]
        || [description containsString:@"full_width_square_image_layout"]
        || [description containsString:@"home_video_with_context"]
        || [description containsString:@"landscape_image_wide_button_layout"]
        // || [description containsString:@"product_carousel"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]
        || [description containsString:@"shelf_header"]
        // || [description containsString:@"statement_banner"]
        || [description containsString:@"square_image_layout"] // install app ad
        || [description containsString:@"text_image_button_layout"]
        || [description containsString:@"text_search_ad"]
        || [description containsString:@"video_display_full_layout"]
        || [description containsString:@"video_display_full_buttoned_layout"])
        return YES;
    return NO;
}

NSData *cellDividerData;

%hook YTIElementRenderer

- (NSData *)elementData {
    NSString *description = [self description];
    if ([description containsString:@"cell_divider"]) {
        if (!cellDividerData) cellDividerData = %orig;
        return cellDividerData;
    }
    if ([self respondsToSelector:@selector(hasCompatibilityOptions)] && self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData && cellDividerData) return cellDividerData;
    // if (isAdString(description)) return cellDividerData;
    return %orig;
}

%end

%hook YTInnerTubeCollectionViewController

- (void)loadWithModel:(YTISectionListRenderer *)model {
    if ([model isKindOfClass:%c(YTISectionListRenderer)]) {
        NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
        NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            if (![renderers isKindOfClass:%c(YTISectionListSupportedRenderers)])
                return NO;
            YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
            YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
            YTIElementRenderer *elementRenderer = firstObject.elementRenderer;
            NSString *description = [elementRenderer description];
            return isAdString(description)
                || [description containsString:@"post_shelf"]
                || [description containsString:@"product_carousel"]
                || [description containsString:@"statement_banner"];
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    }
    %orig;
}

%end
