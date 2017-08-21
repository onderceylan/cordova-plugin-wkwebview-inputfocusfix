#import "CDVWKWebViewEngine+InputFocusFix.h"

@implementation CDVWKWebViewEngine (InputFocusFix)
+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CDVWKWebViewEngine *cdvWKWebViewEngine = [[CDVWKWebViewEngine alloc] init];
        [cdvWKWebViewEngine swizzleWKContentViewForInputFocus];
    });
}

- (void) swizzleWKContentViewForInputFocus {
    NSDictionary* settings = self.commandDelegate.settings;
    if (![settings cordovaBoolSettingForKey:@"KeyboardDisplayRequiresUserAction" defaultValue:YES]) {
        [self keyboardDisplayDoesNotRequireUserAction];
    }
}

// https://github.com/Telerik-Verified-Plugins/WKWebView/commit/04e8296adeb61f289f9c698045c19b62d080c7e3
- (void) keyboardDisplayDoesNotRequireUserAction {
    SEL sel = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
    Class WKContentView = NSClassFromString(@"WKContentView");
    Method method = class_getInstanceMethod(WKContentView, sel);
    IMP originalImp = method_getImplementation(method);
    IMP imp = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, id))originalImp)(me, sel, arg0, TRUE, arg2, arg3);
    });
    method_setImplementation(method, imp);
}
@end