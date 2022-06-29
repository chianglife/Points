//
//  AppDelegate.m
//  PointsDemo
//
//  Created by Chiang on 2020/11/18.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //需要测试哪个就填哪个VC
    Class class = NSClassFromString(@"VariousThreadViewController");
    id vc = [[class alloc] init];
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController =navCtr;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
