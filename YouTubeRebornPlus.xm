#import "YouTubeRebornPlus.h"

NSBundle *YouTubeRebornPlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouTubeRebornPlus" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YouTubeRebornPlus.bundle")];
    });
    return bundle;
}
NSBundle *tweakBundle = YouTubeRebornPlusBundle();

