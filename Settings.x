#import "Header.h"

#define TWEAK_VERSION 19.40.4-1.7.3
#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define SECTION_HEADER(s) [sectionItems addObject:[%c(YTSettingsSectionItem) itemWithTitle:@"" titleDescription:[s uppercaseString] accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; }]]

static const NSInteger YouTubePremiumSection = 500;

@interface YTSettingsSectionItemManager (YouTubePremium)
- (void)updateYouTubePremiumSectionWithEntry:(id)entry;
@end

extern NSBundle *YouTubePremiumBundle();

NSBundle *YouTubePremiumBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouTubePremium" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YouTubePremium.bundle")];
    });
    return bundle;
}
/*
NSBundle *tweakBundle = YouTubePremiumBundle();

// Settings Search Bar
%hook YTSettingsViewController
- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == YouTubePremiumSection)
        MSHookIvar<BOOL>(self, "_shouldShowSearchBar") = YES;
}
- (void)setSectionControllers {
    %orig;
    if (MSHookIvar<BOOL>(self, "_shouldShowSearchBar")) {
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
        if (settingsSectionController)
            [searchableVC storeCollectionViewSections:@[settingsSectionController]];
    }
}
%end
*/
// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YouTubePremiumSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController
- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}
%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateYouTubePremiumSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouTubePremiumBundle();
    //Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    # pragma mark - About
    SECTION_HEADER(LOC(@"ABOUT"));

    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://iosmod.net"]];
        }
    ];
    [sectionItems addObject:version];

    # pragma mark - functions
    SECTION_HEADER(LOC(@"FUNCTIONS"));

    YTSettingsSectionItem *noads = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"NOADS")]
    titleDescription:LOC(@"NOADS_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:noads];

    YTSettingsSectionItem *playbackgroud = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"PLAYBACKGROUD")]
    titleDescription:LOC(@"PLAYBACKGROUD_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:playbackgroud];

    YTSettingsSectionItem *youpip = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"YOUPIP")]
    titleDescription:LOC(@"YOUPIP_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:youpip];

    YTSettingsSectionItem *ryd = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"RYD")]
    titleDescription:LOC(@"RYD_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:ryd];

    YTSettingsSectionItem *ytuhd = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"YTUHD")]
    titleDescription:LOC(@"YTUHD_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:ytuhd];

    YTSettingsSectionItem *youquality = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"YOUQUALITY")]
    titleDescription:LOC(@"YOUQUALITY_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:youquality];

    YTSettingsSectionItem *youmute = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"YOUMUTE")]
    titleDescription:LOC(@"YOUMUTE_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:youmute];

    YTSettingsSectionItem *youchoosequlity = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"YOUCHOOSEQUALITY")]
    titleDescription:LOC(@"YOUCHOOSEQUALITY_DESC")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return NO;
    }];
    [sectionItems addObject:youchoosequlity];


    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:YouTubePremiumSection title:@"IOSMOD.NET" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:YouTubePremiumSection title:@"IOSMOD.NET" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YouTubePremiumSection) {
        [self updateYouTubePremiumSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
