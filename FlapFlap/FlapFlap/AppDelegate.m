//
//  AppDelegate.m
//  FlapFlap
//
//  Created by wk on 2/9/14.
//  Copyright (c) wktzjz@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  ViewController *viewController = [[ViewController alloc] init];
  [_window setRootViewController:viewController];

  [_window setBackgroundColor:[UIColor whiteColor]];
  [_window makeKeyAndVisible];
    
    //向微信注册
  [WXApi registerApp:@"wx1291984e79e78030" withDescription:@"Flappy Bird"];
  return YES;
}

//-(void) RespTextContent:(NSInteger)text
//{
//    GetMessageFromWXResp* resp = [[GetMessageFromWXResp alloc] init];
//    NSString* score = [NSNumberFormatter localizedStringFromNumber:@(text) numberStyle:NSNumberFormatterDecimalStyle];
//    resp.text = [NSString stringWithFormat:@"Flappy Bird New High Score:%@",score] ;
//    resp.bText = YES;
//    
//    [WXApi sendResp:resp];
//}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}
@end
