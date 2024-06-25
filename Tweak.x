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
- (BOOL)shouldBlockUpgradeDialog { return YES; }
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
/*
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
*/
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
/*
%hook YTAdShieldUtils
+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }
%end
*/
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

NSString *getAdString(NSString *description) {
    if ([description containsString:@"brand_promo"])
        return @"brand_promo";
    if ([description containsString:@"carousel_footered_layout"])
        return @"carousel_footered_layout";
    if ([description containsString:@"carousel_headered_layout"])
        return @"carousel_headered_layout";
    if ([description containsString:@"feed_ad_metadata"])
        return @"feed_ad_metadata";
    if ([description containsString:@"full_width_portrait_image_layout"])
        return @"full_width_portrait_image_layout";
    if ([description containsString:@"full_width_square_image_layout"])
        return @"full_width_square_image_layout";
    if ([description containsString:@"landscape_image_wide_button_layout"])
        return @"landscape_image_wide_button_layout";
    if ([description containsString:@"post_shelf"])
        return @"post_shelf";
    if ([description containsString:@"product_carousel"])
        return @"product_carousel";
    if ([description containsString:@"product_engagement_panel"])
        return @"product_engagement_panel";
    if ([description containsString:@"product_item"])
        return @"product_item";
    if ([description containsString:@"statement_banner"])
        return @"statement_banner";
    if ([description containsString:@"square_image_layout"])
        return @"square_image_layout";
    if ([description containsString:@"text_image_button_layout"])
        return @"text_image_button_layout";
    if ([description containsString:@"text_search_ad"])
        return @"text_search_ad";
    if ([description containsString:@"video_display_full_layout"])
        return @"video_display_full_layout";
    if ([description containsString:@"video_display_full_buttoned_layout"])
        return @"video_display_full_buttoned_layout";
    return nil;
}

/*
BOOL isAdString(NSString *description) {
    if ([description containsString:@"brand_promo"]
        || [description containsString:@"carousel_footered_layout"]
        || [description containsString:@"carousel_headered_layout"]
        || [description containsString:@"feed_ad_metadata"]
        || [description containsString:@"full_width_portrait_image_layout"]
        || [description containsString:@"full_width_square_image_layout"]
        || [description containsString:@"home_video_with_context"]
        || [description containsString:@"landscape_image_wide_button_layout"]
        || [description containsString:@"post_shelf"]
        || [description containsString:@"product_carousel"]
        || [description containsString:@"product_engagement_panel"]
        || [description containsString:@"product_item"]
        || [description containsString:@"shelf_header"]
        || [description containsString:@"statement_banner"]
        || [description containsString:@"square_image_layout"] // install app ad
        || [description containsString:@"text_image_button_layout"]
        || [description containsString:@"text_search_ad"]
        || [description containsString:@"video_display_full_layout"]
        || [description containsString:@"video_display_full_buttoned_layout"])
        return YES;
    return NO;
}

#define cellDividerDataBytesLength 719
static __strong NSData *cellDividerData;
static uint8_t cellDividerDataBytes[] = {
    0xa, 0x8c, 0x5, 0xca, 0xeb, 0xea, 0x83, 0x5, 0x85, 0x5,
    0x1a, 0x29, 0x92, 0xcb, 0xa1, 0x90, 0x5, 0x23, 0xa, 0x21,
    0x63, 0x65, 0x6c, 0x6c, 0x5f, 0x64, 0x69, 0x76, 0x69, 0x64,
    0x65, 0x72, 0x2e, 0x65, 0x6d, 0x6c, 0x7c, 0x39, 0x33, 0x62,
    0x65, 0x63, 0x30, 0x39, 0x37, 0x37, 0x63, 0x66, 0x64, 0x33,
    0x61, 0x31, 0x37, 0x2a, 0xee, 0x3, 0xea, 0x84, 0xef, 0xab,
    0xa, 0xe7, 0x3, 0x8, 0x4, 0x12, 0x0, 0x18, 0xff, 0xff,
    0xff, 0x7, 0x32, 0xdb, 0x3, 0xfa, 0x3e, 0x4, 0x8, 0x5,
    0x10, 0x1, 0x92, 0x3f, 0x4, 0xa, 0x2, 0x8, 0x1, 0xc2,
    0xb8, 0x89, 0xbe, 0xa, 0x91, 0x1, 0xa, 0x8c, 0x1, 0x38,
    0x1, 0x40, 0x1, 0x50, 0x1, 0x58, 0x1, 0x60, 0x5, 0x70,
    0x1, 0x78, 0x1, 0x80, 0x1, 0x1, 0x90, 0x1, 0x1, 0x98,
    0x1, 0x1, 0xa0, 0x1, 0x1, 0xa8, 0x1, 0x1, 0xc8, 0x1,
    0x1, 0xe0, 0x1, 0x1, 0x88, 0x2, 0x1, 0x90, 0x2, 0x1,
    0x98, 0x2, 0x1, 0xa0, 0x2, 0x1, 0xd0, 0x2, 0x1, 0x98,
    0x3, 0x1, 0xa0, 0x3, 0x1, 0xb0, 0x3, 0x1, 0xd0, 0x3,
    0x1, 0xd8, 0x3, 0x1, 0xe8, 0x3, 0x1, 0xf0, 0x3, 0x1,
    0x98, 0x4, 0x1, 0xd0, 0x4, 0x1, 0xe8, 0x4, 0x1, 0xf0,
    0x4, 0x1, 0xf8, 0x4, 0x1, 0xd8, 0x5, 0x1, 0xe5, 0x5,
    0xcd, 0xcc, 0x4c, 0x3f, 0xed, 0x5, 0xcd, 0xcc, 0x4c, 0x3f,
    0xf5, 0x5, 0x66, 0x66, 0xe6, 0x3f, 0xf8, 0x5, 0x1, 0x88,
    0x6, 0x1, 0x98, 0x6, 0x1, 0xa0, 0x6, 0x1, 0xb8, 0x6,
    0x1, 0xe0, 0x6, 0x1, 0xe8, 0x6, 0x1, 0xf0, 0x6, 0x1,
    0x95, 0x7, 0x0, 0x0, 0x52, 0x44, 0xb8, 0x7, 0x1, 0x10,
    0x5, 0xca, 0xb8, 0x89, 0xbe, 0xa, 0x6, 0xa, 0x4, 0x10,
    0x1, 0x20, 0x1, 0xba, 0xa4, 0xf3, 0x83, 0xe, 0x18, 0xa,
    0x16, 0x74, 0x68, 0x65, 0x6d, 0x65, 0x7c, 0x66, 0x33, 0x33,
    0x38, 0x61, 0x34, 0x35, 0x63, 0x38, 0x62, 0x66, 0x39, 0x30,
    0x35, 0x66, 0x64, 0xb2, 0xb9, 0x9e, 0x8b, 0xe, 0x20, 0xa,
    0x1e, 0x8, 0x1, 0x40, 0x1, 0x50, 0x1, 0x58, 0x1, 0x60,
    0x1, 0x75, 0x0, 0x0, 0x80, 0x3f, 0x85, 0x1, 0x33, 0x33,
    0x33, 0x3f, 0x8d, 0x1, 0x0, 0x0, 0x0, 0x3f, 0xb0, 0x1,
    0x1, 0xa2, 0xaf, 0xe0, 0x8d, 0xe, 0x46, 0xa, 0x44, 0x28,
    0x1, 0x38, 0x1, 0x45, 0xcd, 0xcc, 0xcc, 0x3e, 0x48, 0x1,
    0x70, 0x1, 0x90, 0x1, 0x1, 0x98, 0x1, 0x1, 0xa0, 0x1,
    0x1, 0xe8, 0x1, 0x1, 0x88, 0x2, 0x1, 0x98, 0x2, 0x1,
    0xa0, 0x2, 0x88, 0x27, 0xb8, 0x2, 0x1, 0xc0, 0x2, 0x1,
    0xc8, 0x2, 0x1, 0xd0, 0x2, 0x1, 0xe8, 0x2, 0x1, 0xf0,
    0x2, 0x1, 0xe0, 0x3, 0x1, 0xed, 0x3, 0x0, 0x0, 0x0,
    0x3f, 0xcd, 0x4, 0x0, 0x0, 0x80, 0x3f, 0xd2, 0xbf, 0x99,
    0xa7, 0xe, 0xa, 0xa, 0x8, 0x8, 0x1, 0x10, 0x1, 0x30,
    0x1, 0x78, 0x1, 0xca, 0xc3, 0xc8, 0xa7, 0xe, 0x60, 0x12,
    0x5e, 0x10, 0x1, 0x20, 0x1, 0x98, 0x1, 0x1, 0xa0, 0x1,
    0x1, 0xfd, 0x1, 0x0, 0x0, 0xc0, 0x41, 0x85, 0x2, 0x0,
    0x0, 0xe0, 0x41, 0x8d, 0x2, 0x0, 0x0, 0xe0, 0x41, 0x95,
    0x2, 0x0, 0x0, 0x10, 0x42, 0x9d, 0x2, 0x0, 0x0, 0x10,
    0x42, 0xa5, 0x2, 0x0, 0x0, 0x30, 0x42, 0xad, 0x2, 0x0,
    0x0, 0x30, 0x42, 0xbd, 0x2, 0x0, 0x0, 0x40, 0x41, 0xc5,
    0x2, 0x0, 0x0, 0x80, 0x41, 0xcd, 0x2, 0x0, 0x0, 0x80,
    0x41, 0xd5, 0x2, 0x0, 0x0, 0xc0, 0x41, 0xdd, 0x2, 0x0,
    0x0, 0xc0, 0x41, 0xe5, 0x2, 0x0, 0x0, 0x0, 0x42, 0xed,
    0x2, 0x0, 0x0, 0x0, 0x42, 0x92, 0x94, 0xf6, 0xb2, 0xf,
    0x1d, 0x63, 0x61, 0x70, 0x61, 0x62, 0x69, 0x6c, 0x69, 0x74,
    0x69, 0x65, 0x73, 0x7c, 0x61, 0x37, 0x39, 0x38, 0x35, 0x39,
    0x35, 0x34, 0x37, 0x39, 0x64, 0x62, 0x65, 0x36, 0x64, 0x63,
    0x32, 0x67, 0x9a, 0xe8, 0xf9, 0xa9, 0x6, 0x8, 0x8, 0xcd,
    0xf0, 0xbd, 0xa5, 0x1, 0x10, 0x7, 0xaa, 0xf1, 0xdf, 0xc1,
    0xb, 0x24, 0xa, 0x1c, 0xa, 0x18, 0xa, 0x16, 0x74, 0x68,
    0x65, 0x6d, 0x65, 0x7c, 0x66, 0x33, 0x33, 0x38, 0x61, 0x34,
    0x35, 0x63, 0x38, 0x62, 0x66, 0x39, 0x30, 0x35, 0x66, 0x64,
    0x10, 0x2, 0x10, 0xcd, 0xf0, 0xbd, 0xa5, 0x1, 0xb2, 0xf1,
    0xdf, 0xc1, 0xb, 0x29, 0xa, 0x21, 0xa, 0x1d, 0x63, 0x61,
    0x70, 0x61, 0x62, 0x69, 0x6c, 0x69, 0x74, 0x69, 0x65, 0x73,
    0x7c, 0x61, 0x37, 0x39, 0x38, 0x35, 0x39, 0x35, 0x34, 0x37,
    0x39, 0x64, 0x62, 0x65, 0x36, 0x64, 0x63, 0x10, 0xa, 0x10,
    0xcd, 0xf0, 0xbd, 0xa5, 0x1, 0x12, 0x3e, 0xc2, 0x86, 0xa5,
    0xbb, 0x5, 0x38, 0xa, 0x21, 0x63, 0x65, 0x6c, 0x6c, 0x5f,
    0x64, 0x69, 0x76, 0x69, 0x64, 0x65, 0x72, 0x2e, 0x65, 0x6d,
    0x6c, 0x7c, 0x39, 0x33, 0x62, 0x65, 0x63, 0x30, 0x39, 0x37,
    0x37, 0x63, 0x66, 0x64, 0x33, 0x61, 0x31, 0x37, 0x32, 0x13,
    0x31, 0x37, 0x31, 0x39, 0x31, 0x32, 0x32, 0x35, 0x34, 0x39,
    0x39, 0x39, 0x36, 0x30, 0x31, 0x37, 0x31, 0x33, 0x38,
};

%hook YTIElementRenderer
- (NSData *)elementData {
    if ([self respondsToSelector:@selector(hasCompatibilityOptions)] && self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData) {
        // HBLogInfo(@"YTX adLogging %@", cellDividerData);
        return cellDividerData;
    }
    NSString *description = [self description];
    NSString *adString = getAdString(description);
    if (adString) {
        // HBLogInfo(@"YTX getAdString %@ %@", str, cellDividerData);
        return cellDividerData;
    }
    return %orig;
}
%end


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
            return isAdString(description);
        }];
        [contentsArray removeObjectsAtIndexes:removeIndexes];
    }
    %orig;
}
%end

%ctor {
    cellDividerData = [NSData dataWithBytes:cellDividerDataBytes length:cellDividerDataBytesLength];
    %init;
}
*/
