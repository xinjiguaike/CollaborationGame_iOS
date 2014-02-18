//
//  MainScene.m
//  FlapFlap
//
//  Created by wk on 2/9/14.
//  Copyright (c) wktzjz@gmail.com. All rights reserved.
//

#import "MainScene.h"
#import "NewGameScene.h"
#import "Player.h"
#import "Obstacle.h"
#import "Ground.h"
//#import "OWActivities.h"
#import "JFUser.h"

#define FString(format, ...) [NSString stringWithFormat:(format), ## __VA_ARGS__]

static const uint32_t kPlayerCategory = 0x1 << 0;
static const uint32_t kPipeCategory = 0x1 << 1;
static const uint32_t kGroundCategory = 0x1 << 2;

static const CGFloat kGravity = -10;
static const CGFloat kDensity = 1.15;
static const CGFloat kMaxVelocity = 400;
static const CGFloat kDeadVelocity = 20;

static const CGFloat kPipeSpeed = 4;
static const CGFloat kPipeWidth = 64;
static const CGFloat kPipeGap = 120;
static const CGFloat kPipeFrequency = 2;

static const NSInteger kNumLevels = 20;

static const CGFloat randomFloat(CGFloat Min, CGFloat Max){
    return floor(((rand() % RAND_MAX) / (RAND_MAX * 1.0)) * (Max - Min) + Min);
}

@implementation MainScene {
    Player         *_player;
    SKSpriteNode   *_ground;
    SKLabelNode   *_againbutton;
    SKLabelNode   *_sharebutton;
    SKLabelNode    *_scoreLabel;
    SKLabelNode    *_deadScoreLabel;
    NSInteger      _score;
    NSTimer        *_pipeTimer;
    NSTimer        *_scoreTimer;
    BOOL           _dead;
    BOOL           _gameRunning;
    BOOL         _touchingGround;
    NSTimeInterval _updateTimeDelta;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _totalTime;
    SKAction *_pipeSound;
    SKAction *_punchSound;
    SKAction *_flySound;
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        _score = -1;
        _dead = NO;
        _gameRunning= YES;
        _touchingGround = NO;
        
        srand((time(nil) % kNumLevels)*10000);
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg-tile"];
        background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        
        [self addChild:background];
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        //    [self setBackgroundColor:[SKColor colorWithRed:.45 green:.77 blue:.81 alpha:1]];
        
        [self.physicsWorld setGravity:CGVectorMake(0, kGravity)];
        [self.physicsWorld setContactDelegate:self];
        
        //    _ground = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:.87 green:.84 blue:.59 alpha:1] size:CGSizeMake(self.size.width, 64)];
        _ground = [Ground spriteNodeWithColor:[SKColor colorWithRed:.87 green:.84 blue:.59 alpha:1] size:CGSizeMake(self.size.width, 64)];
        [_ground setPosition:CGPointMake(self.size.width/2, _ground.size.height/2)];
        [self addChild:_ground];
        
        _ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ground.size];
        [_ground.physicsBody setCategoryBitMask:kGroundCategory];
        [_ground.physicsBody setCollisionBitMask:kPlayerCategory];
        [_ground.physicsBody setAffectedByGravity:NO];
        [_ground.physicsBody setDynamic:NO];
        
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"PressStart2P"];
        //  _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
        [_scoreLabel setZPosition:1.0];
        [_scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        [_scoreLabel setPosition:CGPointMake(10.0, size.height - 42.0)];
        [_scoreLabel setText:@"0"];
        
        
        //      _againbutton  = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //      [_againbutton setText:@"Play Again"];
        //      [_againbutton setFontSize:18];
        //      [_againbutton setPosition:CGPointMake(CGRectGetMidX(self.frame)-5,CGRectGetMidY(self.frame)+100)];
        //       [_againbutton setAlpha:0.0];
        //      [self addChild:_againbutton];
        
        [self addChild:_scoreLabel];
        
        [self setupPlayer];
        
        _pipeSound = [SKAction playSoundFileNamed:@"pipe.mp3" waitForCompletion:NO];
        _punchSound = [SKAction playSoundFileNamed:@"punch.mp3" waitForCompletion:NO];
        _flySound =  [SKAction playSoundFileNamed:@"punch.wav" waitForCompletion:NO];
        
        
        //弃用，放入update里面 以便控制游戏
        //    _pipeTimer = [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(addObstacle) userInfo:nil repeats:YES];
        //
        //    [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(startScoreTimer) userInfo:nil repeats:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gameStart" object:self];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveGamePause:)
                                                     name:@"gamePause"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveGameContinue:)
                                                     name:@"gameContinue"
                                                   object:nil];
        
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupPlayer
{
    //  _player = [Player spriteNodeWithColor:[SKColor colorWithWhite:1 alpha:1] size:CGSizeMake(32, 32)];
    _player = [Player spriteNodeWithImageNamed:@"hero1"];
    [_player setScale:2.5f];
    [_player setPosition:CGPointMake(self.size.width/2, self.size.height/2+200)];
    [self addChild:_player];
    [self animateHero];
    
    _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.size];
    [_player.physicsBody setDensity:kDensity];
    [_player.physicsBody setAllowsRotation:YES];
    
    [_player.physicsBody setCategoryBitMask:kPlayerCategory];
    [_player.physicsBody setContactTestBitMask:kPipeCategory | kGroundCategory];
    [_player.physicsBody setCollisionBitMask:kGroundCategory | kPipeCategory];
}

//小鸟动画 需要更多素材
- (void)animateHero
{
    NSArray *animationFrames = @[
                                 [SKTexture textureWithImageNamed:@"hero1"],
                                 [SKTexture textureWithImageNamed:@"hero2"]
                                 ];
    [_player     runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:animationFrames
                                             timePerFrame:0.1f
                                                   resize:NO
                                                  restore:YES]]
                   withKey:@"flyingHero"];
}

- (void)addObstacle
{
    CGFloat centerY = randomFloat(kPipeGap, self.size.height-kPipeGap);
    CGFloat pipeTopHeight = centerY - (kPipeGap/2);
    CGFloat pipeBottomHeight = self.size.height - (centerY + (kPipeGap/2));
    
    // Top Pipe
    //  Obstacle *pipeTop = [Obstacle spriteNodeWithColor:[SKColor colorWithRed:.34 green:.49 blue:.18 alpha:1] size:CGSizeMake(kPipeWidth, pipeTopHeight)];
    Obstacle* pipeTop = [Obstacle spriteNodeWithImageNamed:@"pipe-top"];
    pipeTop.size = CGSizeMake(kPipeWidth, pipeTopHeight);
    
    [pipeTop setPosition:CGPointMake(self.size.width+(pipeTop.size.width/2), self.size.height-(pipeTop.size.height/2))];
    [self addChild:pipeTop];
    
    pipeTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeTop.size];
    [pipeTop.physicsBody setAffectedByGravity:NO];
    [pipeTop.physicsBody setDynamic:NO];
    
    [pipeTop.physicsBody setCategoryBitMask:kPipeCategory];
    [pipeTop.physicsBody setCollisionBitMask:kPlayerCategory];
    
    // Bottom Pipe
    //  Obstacle *pipeBottom = [Obstacle spriteNodeWithColor:[SKColor colorWithRed:.34 green:.49 blue:.18 alpha:1] size:CGSizeMake(kPipeWidth, pipeBottomHeight)];
    Obstacle* pipeBottom = [Obstacle spriteNodeWithImageNamed:@"pipe-bottom"];
    pipeBottom.size = CGSizeMake(kPipeWidth, pipeBottomHeight);
    [pipeBottom setPosition:CGPointMake(self.size.width+(pipeBottom.size.width/2), (pipeBottom.size.height/2))];
    [self addChild:pipeBottom];
    
    pipeBottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipeBottom.size];
    [pipeBottom.physicsBody setAffectedByGravity:NO];
    [pipeBottom.physicsBody setDynamic:NO];
    
    [pipeBottom.physicsBody setCategoryBitMask:kPipeCategory];
    [pipeBottom.physicsBody setCollisionBitMask:kPlayerCategory];
    
    // Move top pipe
    SKAction *pipeTopAction = [SKAction moveToX:-(pipeTop.size.width/2) duration:kPipeSpeed];
    SKAction *pipeTopSequence = [SKAction sequence:@[pipeTopAction, [SKAction runBlock:^{
        [pipeTop removeFromParent];
    }]]];
    
    [pipeTop runAction:[SKAction repeatActionForever:pipeTopSequence]];
    
    // Move bottom pipe
    SKAction *pipeBottomAction = [SKAction moveToX:-(pipeBottom.size.width/2) duration:kPipeSpeed];
    SKAction *pipeBottomSequence = [SKAction sequence:@[pipeBottomAction, [SKAction runBlock:^{
        [pipeBottom removeFromParent];
    }]]];
    
    [pipeBottom runAction:[SKAction repeatActionForever:pipeBottomSequence]];
}

- (void)startScoreTimer
{
    _scoreTimer = [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(incrementScore) userInfo:nil repeats:YES];
}

- (void)incrementScore
{
    _score++;
    [_scoreLabel setText:[NSNumberFormatter localizedStringFromNumber:@(_score)
                          
                                                          numberStyle:NSNumberFormatterDecimalStyle]];
    if (_score!=0) {
        [self runAction:_pipeSound];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_dead && !_touchingGround){
        return;
    }
    else if (_touchingGround){
        for (UITouch *touch in touches){
            CGPoint location = [touch locationInNode:self];
            if ([_againbutton containsPoint:location]) {
                SKTransition *transition = [SKTransition doorsCloseVerticalWithDuration:.4];
                MainScene *main = [[MainScene alloc] initWithSize:self.size];
                [self.scene.view presentScene:main transition:transition];
            }
            else if ([_sharebutton containsPoint:location]) {
                [self share];
            }
            
        }
    }else{
        [self runAction:_flySound];
        [_player.physicsBody setVelocity:CGVectorMake(_player.physicsBody.velocity.dx, kMaxVelocity)];
    }
    
    //变态玩法 要快速连点 哈哈
    //[_player.physicsBody setVelocity:CGVectorMake(_player.physicsBody.velocity.dx, _player.physicsBody.velocity.dy + kMaxVelocity)];
}

//游戏主循环 Main Loop
- (void)update:(NSTimeInterval)currentTime
{
    //    if(!_gameRunning)
    if (self.isPaused){
        NSLog(@"game pause update");
        _lastUpdateTime = 0.0;
        _totalTime = 0.0;
        return;
    }
    
    if (_lastUpdateTime > 0.0) {
        _updateTimeDelta = currentTime - _lastUpdateTime;
    } else {
        _updateTimeDelta = 0.0;
    }
    
    _lastUpdateTime = currentTime;
    _totalTime += _updateTimeDelta;
    
    // NSLog(@"_updateTimeDelta:%f",_updateTimeDelta);
    
    //每120毫秒添加水管 然后重新计时
    if (2.0 <=_totalTime && _gameRunning){
        // NSLog(@"in");
        _totalTime = 0;
        [self addObstacle];
        [self incrementScore];
    }
    
    if (_player.physicsBody.velocity.dy > kMaxVelocity) {
        [_player.physicsBody setVelocity:CGVectorMake(_player.physicsBody.velocity.dx, kMaxVelocity)];
    }
    
    CGFloat rotation = ((_player.physicsBody.velocity.dy + kMaxVelocity) / (2*kMaxVelocity)) * M_2_PI;
    [_player setZRotation:rotation-M_1_PI/2];
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode* nodeA = contact.bodyA.node;
    SKNode* nodeB = contact.bodyB.node;
    //  if ([nodeA isKindOfClass:[Player class]]) {
    //    [_pipeTimer invalidate];
    //    [_scoreTimer invalidate];
    //
    //    SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:.4];
    //    NewGameScene *newGame = [[NewGameScene alloc] initWithSize:self.size];
    //    [self.scene.view presentScene:newGame transition:transition];
    //  }
    
    // 2次 碰撞
    if (([nodeA isKindOfClass:[Player class]] && [nodeB isKindOfClass:[Obstacle class]]) ||
        ([nodeB isKindOfClass:[Player class]] && [nodeA isKindOfClass:[Obstacle class]]))
    {
        [self runAction:_punchSound completion:^{
            _dead = YES;
            [_player setZPosition:0.6];
            [_player.physicsBody setVelocity:CGVectorMake(0, -400)];
        }];
        
        //碰撞后画面抖动
        CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //设置抖动幅度
        shake.fromValue = [NSNumber numberWithFloat:-0.07];
        shake.toValue = [NSNumber numberWithFloat:+0.07];
        shake.duration = 0.1;
        shake.autoreverses = YES; //是否重复
        shake.repeatCount = 3;
        
        [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //self.view 是 SKView
            [self.view.layer addAnimation:shake forKey:@"imageView"];
            self.view.alpha = 1.0;
            
        }completion:nil];
        
        //        _dead = YES;
        //        [_player setZPosition:0.6];
        //        [_player.physicsBody setVelocity:CGVectorMake(0, -400)];
    }
    
    
    if (([nodeA isKindOfClass:[Player class]] && [nodeB isKindOfClass:[Ground class]]) ||
        ([nodeB isKindOfClass:[Player class]] && [nodeA isKindOfClass:[Ground class]]))
    {
        _gameRunning = NO;
        _touchingGround =YES;
        //        [_pipeTimer invalidate];
        //        [_scoreTimer invalidate];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gameEnd" object:self];
        
        [self gameOver];
        
        //        SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:.4];
        //        NewGameScene *newGame = [[NewGameScene alloc] initWithSize:self.size];
        //        [self.scene.view presentScene:newGame transition:transition];
    }
    
}

-(void)gameOver
{
    //    self.paused = YES;
    
    _deadScoreLabel  = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
    NSString* score = [NSNumberFormatter localizedStringFromNumber:@(_score) numberStyle:NSNumberFormatterDecimalStyle];
    [_deadScoreLabel setText:[NSString stringWithFormat:@"Score:%@",score]];
    [_deadScoreLabel setFontSize:25];
    [_deadScoreLabel setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) + 100)];
    [_deadScoreLabel setAlpha:0.0];
    [self addChild:_deadScoreLabel];
    
    _againbutton  = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
    [_againbutton setText:@"Again"];
    [_againbutton setFontSize:25];
    [_againbutton setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))];
    [_againbutton setAlpha:0.0];
    [self addChild:_againbutton];
    
    _sharebutton  = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
    [_sharebutton setText:@"Share"];
    [_sharebutton setFontSize:25];
    [_sharebutton setPosition:CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-100)];
    [_sharebutton setAlpha:0.0];
    [self addChild:_sharebutton];
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_againbutton setAlpha:1.0];
                         [_sharebutton setAlpha:1.0];
                         [_deadScoreLabel setAlpha:1.0];
                         _deadScoreLabel.fontColor = [UIColor whiteColor];
                         _againbutton.fontColor = [UIColor grayColor];
                         _sharebutton.fontColor = [UIColor grayColor];
                         
                         // [_againbutton setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         
                         [_player setTexture:[SKTexture textureWithImageNamed:@"bird-dead"]];
                         self.paused = YES;
                     }];
    
}

#pragma mark - Share

- (UIImage *) screenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)share
{
    GetMessageFromWXResp* resp = [[GetMessageFromWXResp alloc] init];
    NSString* score = [NSNumberFormatter localizedStringFromNumber:@(_score) numberStyle:NSNumberFormatterDecimalStyle];
    resp.text = [NSString stringWithFormat:@"Flappy Bird New High Score:%@",score] ;
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"bird-dead@2x.png"]];
    message.description=[NSString stringWithFormat:@"Flappy Bird New High Score:%@",score];
    
    WXImageObject *ext = [WXImageObject object];
    //     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bird-dead@2x" ofType:@"png"];
    //     ext.imageData = [NSData dataWithContentsOfFile:filePath];
    NSData *dataObj = UIImageJPEGRepresentation([self screenshot], 0.75);
    ext.imageData = dataObj;
    message.mediaObject = ext;
    
    resp.message = message;
    
    resp.bText = NO;
    
    [WXApi sendResp:resp];
    
    //    NSArray *activities = @[FString(@"My high score is %d!\n",(int)[[JFUser localUser] bestScore]), [NSURL URLWithString:@"https://itunes.apple.com/us/app/id123123123123"]];
    //    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:activities applicationActivities:nil];
    //
    //    NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList];
    //    shareVC.excludedActivityTypes = excludeActivities;
    //
    //    [self.scene.view.window.rootViewController presentViewController:shareVC animated:YES completion:^{
    //    //    self.shareLabel.fontColor = [UIColor whiteColor];
    //    }];
    
    //    OWTwitterActivity *twitterActivity = [[OWTwitterActivity alloc] init];
    //    OWMailActivity *mailActivity = [[OWMailActivity alloc] init];
    //    OWPrintActivity *printActivity = [[OWPrintActivity alloc] init];
    //    OWCopyActivity *copyActivity = [[OWCopyActivity alloc] init];
    //
    //    NSMutableArray *activities = [NSMutableArray arrayWithObject:mailActivity];
    //
    //    if( [OWWeChatActivity isWeChatInstalled] )
    //    {
    //        OWWeChatActivity *wechatSessionActivity = [[OWWeChatActivity alloc] initWithAppId:WECHAT_APP_ID messageType:WXMessageTypeTextscene:WXSceneSession];
    //        OWWeChatActivity *wechatTimeLineActivity = [[OWWeChatActivity alloc] initWithAppId:WECHAT_APP_ID messageType:WXMessageTypeTextscene:WXSceneTimeline];
    //        [activities addObjectsFromArray:@[wechatSessionActivity,wechatTimeLineActivity]];
    //    }
    //    if ([MFMessageComposeViewController canSendText]) {
    //        OWMessageActivity *messageActivity = [[OWMessageActivity alloc] init];
    //        [activities addObject:messageActivity];
    //    }
    //
    //    [activities addObjectsFromArray:@[twitterActivity]];
    //
    //    if( NSClassFromString (@"UIActivityViewController") ) {
    //        // ios 6, add facebook and sina weibo activities
    //        OWFacebookActivity *facebookActivity = [[OWFacebookActivity alloc] init];
    //        OWSinaWeiboActivity *sinaWeiboActivity = [[OWSinaWeiboActivity alloc] init];
    //        [activities addObjectsFromArray:@[
    //                                          facebookActivity, sinaWeiboActivity
    //                                          ]];
    //    }
    //
    //    [activities addObjectsFromArray:@[
    //                                      copyActivity, printActivity]];
    //
    //    OWActivityViewController *activityViewController = [[OWActivityViewController alloc] initWithViewController:self activities:activities];
    //    activityViewController.userInfo = @{@"text": mstr};
    //
    //    [activityViewController presentFromRootViewController];
}

#pragma mark - Notifications

- (void)didReceiveGamePause:(NSNotification *)notification {
    //    [_pipeTimer invalidate];
    //    [_scoreTimer invalidate];
    self.paused = YES;
    _gameRunning = NO;
    //    [_pipeTimer setFireDate:[NSDate distantFuture]];
    //     [_scoreTimer setFireDate:[NSDate distantFuture]];
    
}

- (void)didReceiveGameContinue:(NSNotification *)notification {
    //    [_pipeTimer fire];
    //    [_scoreTimer fire];
    self.paused = NO;
    _gameRunning = YES;
    //    [_pipeTimer setFireDate:[NSDate date]];
    //    [_scoreTimer setFireDate:[NSDate date]];
}

@end
