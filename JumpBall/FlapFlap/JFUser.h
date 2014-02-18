//
//  JFUser.h
//  
//
//  Created by Nick Domenicali.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFUser : NSObject

@property (nonatomic, readonly) BOOL isGameCenterEnabled;
@property (nonatomic, readonly) BOOL isAuthenticated;
@property (nonatomic, weak) UIViewController *authenticationViewController;

@property (nonatomic) BOOL hasRatedApp;

-(void)setNewScore:(NSInteger)score;
-(NSInteger)bestScore;

-(void)showLeaderboard;
+(instancetype)localUser;


@end
