//
//  AppDelegate.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "AppDelegate.h"
#import "Common.h"

#import "MainViewController.h"

#import "HGLView.h"
#import "StatusView.h"

#import "ObjectAL.h"

@interface AppDelegate()
{
    // Inside @interface
    HGLView* _glView;
}

// After @interface
@property (nonatomic, strong) IBOutlet HGLView *glView;

@end

@implementation AppDelegate
// At top of file
@synthesize glView=_glView;

bool isBackGround = false;


+ (bool)IsBackGround
{
    return isBackGround;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isBackGround = false;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController* navCon = [[UINavigationController alloc] init];
    [navCon addChildViewController:[[MainViewController alloc] init]];
    self.viewController = navCon;
    [navCon setNavigationBarHidden:YES];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [OALSimpleAudio sharedInstance].honorSilentSwitch = YES;
    [[OALSimpleAudio sharedInstance] preloadBg:BGM_BOSS];
    [[OALSimpleAudio sharedInstance] preloadEffect:SE_GUN];
    [[OALSimpleAudio sharedInstance] preloadEffect:SE_ENEMY_APPROACH];
    [[OALSimpleAudio sharedInstance] preloadEffect:SE_ENEMY_ELIMINATED];
    [[OALSimpleAudio sharedInstance] preloadEffect:SE_UNITLOST];
    [[OALSimpleAudio sharedInstance] preloadEffect:SE_BOM];
    [[OALSimpleAudio sharedInstance] preloadEffect:SE_HIT];
    [[OALSimpleAudio sharedInstance] setBgVolume:0.5];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    isBackGround = true;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    isBackGround = true;
    
    // gamefeat
    {
        UIDevice *device = [UIDevice currentDevice];
        BOOL backgroundSupported = NO;
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            backgroundSupported = device.multitaskingSupported;
        }
        if (backgroundSupported) {
            [GFController backgroundTask];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    StatusView* sv = [StatusView GetInstance];
    if (sv) {
        [sv loadUserInfo];
    }
    isBackGround = true;
    
    // gamefeat
    {
        [GFController conversionCheckStop];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    isBackGround = false;
    [GFController activateGF:GAMEFEAT_MEDIA_ID];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    isBackGround = true;
}

@end

