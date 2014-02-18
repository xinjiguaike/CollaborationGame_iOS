//
//  AppDelegate.h
//  FlapFlap
//
//  Created by wk on 2/9/14.
//  Copyright (c) wktzjz@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScene.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
