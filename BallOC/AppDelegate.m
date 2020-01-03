//
//  AppDelegate.m
//  BallOC
//
//  Created by gwh on 2019/12/9.
//  Copyright 2019 gwh. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreMLRecord-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return UIInterfaceOrientationMaskAll;
}

+ (void)load {
    [ccs registerAppDelegate:self];
}

- (void)cc_willInit {
    
    //入口页面
    [self cc_initViewController:VisionObjectRecognitionVC.class withNavigationBarHidden:NO block:^{
        CCLOG(@"ViewController finish");
    }];
}

- (BOOL)cc_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (void)cc_applicationWillResignActive:(UIApplication *)application {

}

- (void)cc_applicationDidEnterBackground:(UIApplication *)application {

}

- (void)cc_applicationWillEnterForeground:(UIApplication *)application {

}

- (void)cc_applicationDidBecomeActive:(UIApplication *)application {

}

- (void)cc_applicationWillTerminate:(UIApplication *)application {

}

@end
