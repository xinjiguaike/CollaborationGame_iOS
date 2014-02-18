//
//  MainScene.h
//  FlapFlap
//
//  Created by wk on 2/9/14.
//  Copyright (c) wktzjz@gmail.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "WXApiObject.h"
#import "WXApi.h"


@protocol GameSceneDelegate;
@protocol RespForWeChatViewDelegate;

@interface MainScene : SKScene <SKPhysicsContactDelegate,WXApiDelegate>

@property (nonatomic, weak) id <GameSceneDelegate> gameDelegate;
@property (nonatomic, weak) id<RespForWeChatViewDelegate,NSObject> delegate;
@end

@protocol GameSceneDelegate <NSObject>
@required
- (void)gameSceneDidStartGame:(MainScene *)scene;
- (void)gameSceneDidEndGame:(MainScene *)scene;
@end

@protocol RespForWeChatViewDelegate <NSObject>
- (void) RespTextContent:(NSInteger)text;
- (void) RespImageContent;
- (void) RespLinkContent;
- (void) RespMusicContent;
- (void) RespVideoContent;
- (void) RespAppContent;
- (void) RespNonGifContent;
- (void) RespGifContent;
- (void) RespFileContent;
@end
