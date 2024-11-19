#import <YouTubeHeader/_ASDisplayView.h>
#import <YouTubeHeader/YTIElementRenderer.h>
#import <YouTubeHeader/YTInnerTubeCollectionViewController.h>
#import <YouTubeHeader/YTISectionListRenderer.h>
#import <YouTubeHeader/YTReelModel.h>
#import <HBLog.h>

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

- (BOOL)isMonetized { return NO; }

%new(@@:)
- (NSMutableArray *)playerAdsArray {
    return [NSMutableArray array];
}

%new(@@:)
- (NSMutableArray *)adSlotsArray {
    return [NSMutableArray array];
}

%end

%hook YTIPlayabilityStatus

- (BOOL)isPlayableInBackground { return YES; }

%end

%hook YTIClientMdxGlobalConfig

%new(B@:)
- (BOOL)enableSkippableAd { return YES; }

%end

%hook MLVideo

- (BOOL)playableInBackground { return YES; }

%end

%hook YTAdShieldUtils

+ (id)spamSignalsDictionary { return @{}; }
+ (id)spamSignalsDictionaryWithoutIDFA { return @{}; }

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

%hook YTLocalPlaybackController

- (id)createAdsPlaybackCoordinator { return nil; }

%end

%hook MDXSession

- (void)adPlaying:(id)ad {}

%end

%hook YTReelInfinitePlaybackDataSource

- (YTReelModel *)makeContentModelForEntry:(id)entry {
    YTReelModel *model = %orig;
    if ([model respondsToSelector:@selector(videoType)] && model.videoType == 3)
        return nil;
    return model;
}

%end

/*
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
    if ([description containsString:@"shopping_carousel"])
        return @"shopping_carousel";
    if ([description containsString:@"shopping_item_card_list"])
        return @"shopping_item_card_list";
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
}*/

NSString *getAdString(NSString *description) {
    for (NSString *str in @[
            @"brand_promo",
            @"carousel_footered_layout",
            @"carousel_headered_layout",
            @"eml.expandable_metadata",
            @"feed_ad_metadata",
            @"full_width_portrait_image_layout",
            @"full_width_square_image_layout",
            @"landscape_image_wide_button_layout",
            @"post_shelf",
            @"product_carousel",
            @"product_engagement_panel",
            @"product_item",
            @"shopping_carousel",
            @"shopping_item_card_list",
            @"statement_banner",
            @"square_image_layout",
            @"text_image_button_layout",
            @"text_search_ad",
            @"video_display_full_layout",
            @"video_display_full_buttoned_layout"
    ]) 
        if ([description containsString:str]) return str;

    return nil;
}

static BOOL isAdRenderer(YTIElementRenderer *elementRenderer, int kind) {
    if ([elementRenderer respondsToSelector:@selector(hasCompatibilityOptions)] && elementRenderer.hasCompatibilityOptions && elementRenderer.compatibilityOptions.hasAdLoggingData) {
        HBLogDebug(@"YTX adLogging %d %@", kind, elementRenderer);
        return YES;
    }
    NSString *description = [elementRenderer description];
    NSString *adString = getAdString(description);
    if (adString) {
        HBLogDebug(@"YTX getAdString %d %@ %@", kind, adString, elementRenderer);
        return YES;
    }
    return NO;
}

static NSMutableArray <YTIItemSectionRenderer *> *filteredArray(NSArray <YTIItemSectionRenderer *> *array) {
    NSMutableArray <YTIItemSectionRenderer *> *newArray = [array mutableCopy];
    NSIndexSet *removeIndexes = [newArray indexesOfObjectsPassingTest:^BOOL(YTIItemSectionRenderer *sectionRenderer, NSUInteger idx, BOOL *stop) {
        if (![sectionRenderer isKindOfClass:%c(YTIItemSectionRenderer)])
            return NO;
        NSMutableArray <YTIItemSectionSupportedRenderers *> *contentsArray = sectionRenderer.contentsArray;
        if (contentsArray.count > 1) {
            NSIndexSet *removeContentsArrayIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTIItemSectionSupportedRenderers *sectionSupportedRenderers, NSUInteger idx2, BOOL *stop2) {
                YTIElementRenderer *elementRenderer = sectionSupportedRenderers.elementRenderer;
                return isAdRenderer(elementRenderer, 3);
            }];
            [contentsArray removeObjectsAtIndexes:removeContentsArrayIndexes];
        }
        YTIItemSectionSupportedRenderers *firstObject = [contentsArray firstObject];
        YTIElementRenderer *elementRenderer = firstObject.elementRenderer;
        return isAdRenderer(elementRenderer, 2);
    }];
    [newArray removeObjectsAtIndexes:removeIndexes];
    return newArray;
}

%hook _ASDisplayView

- (void)didMoveToWindow {
    %orig;
    if (([self.accessibilityIdentifier isEqualToString:@"eml.expandable_metadata.vpp"]))
        [self removeFromSuperview];
}

%end

%hook YTInnerTubeCollectionViewController

- (void)displaySectionsWithReloadingSectionControllerByRenderer:(id)renderer {
    NSMutableArray *sectionRenderers = [self valueForKey:@"_sectionRenderers"];
    [self setValue:filteredArray(sectionRenderers) forKey:@"_sectionRenderers"];
    %orig;
}

- (void)addSectionsFromArray:(NSArray <YTIItemSectionRenderer *> *)array {
    %orig(filteredArray(array));
}

%end
