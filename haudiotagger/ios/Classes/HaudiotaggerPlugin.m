#import "HaudiotaggerPlugin.h"
#if __has_include(<haudiotagger/haudiotagger-Swift.h>)
#import <haudiotagger/haudiotagger-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "haudiotagger-Swift.h"
#endif

@implementation HaudiotaggerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHaudiotaggerPlugin registerWithRegistrar:registrar];
}
@end
