//
//  NewGameScene.m
//  FlapFlap
//
//  Created by wk on 2/9/14.
//  Copyright (c) wktzjz@gmail.com. All rights reserved.
//

#import "NewGameScene.h"
#import "MainScene.h"
#import "Player.h"

@implementation NewGameScene {
//  SKSpriteNode *_button;
    SKLabelNode* _button;
    Player         *_player;
}

- (id)initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
//    [self setBackgroundColor:[SKColor colorWithRed:.39 green:.67 blue:.70 alpha:1]];

//    _button = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:1 alpha:1] size:CGSizeMake(128, 32)];
//    [_button setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
//      SKTexture *backgroundTexture = [SKTexture textureWithImageNamed:@"background.png"];
//      SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:self.view.frame.size];
//      background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)};
      
      SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg-tile"];
      background.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
      
      [self addChild:background];
      self.scaleMode = SKSceneScaleModeAspectFit;
      
      _button  = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
      [_button setText:@"Stan's Flappy Bird"];
      [_button setFontSize:14];
      [_button setPosition:CGPointMake(CGRectGetMidX(self.frame)-5,CGRectGetMidY(self.frame)+100)];
      [self addChild:_button];
      
      _player = [Player spriteNodeWithImageNamed:@"hero1"];
      [_player setScale:2.5f];
      [_player setPosition:CGPointMake(50, self.size.height/2+100)];
      [self addChild:_player];
      [self animateHero];
      
      _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.size];
      [_player.physicsBody setDensity:20];
      [_player.physicsBody setAllowsRotation:YES];

      NSTimer* _pipeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(pushBird) userInfo:nil repeats:YES];
      NSLog(@"width:%f,height:%f",self.frame.size.width,self.frame.size.height);
//      [_pipeTimer fire];
//      int a = 3; int b = 5; int c= a^b;
//      NSLog(@"c is %i",c);
  }
  return self;
}

-(void)pushBird
{
     [_player.physicsBody setVelocity:CGVectorMake(10, 373)];
    
    if(_player.position.x >= (self.frame.size.width-30)){
       [_player setPosition:CGPointMake(50, self.size.height/2)];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        if ([_button containsPoint:location]) {
            
            SKTransition *transition = [SKTransition doorsCloseVerticalWithDuration:.4];
            MainScene *main = [[MainScene alloc] initWithSize:self.size];
            [self.scene.view presentScene:main transition:transition];
            
        }else if([_player containsPoint:location]){
            
            [_player.physicsBody setVelocity:CGVectorMake(60, 500)];
        }
    }
//    SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:.4];
//  MainScene *main = [[MainScene alloc] initWithSize:self.size];
//  [self.scene.view presentScene:main transition:transition];
//   int x = 1; int y = 2; int z = x^y*y; NSLog(@"%d",z);
 float a = 4.45; int b = 2.1; int c = a/b; NSLog(@"%d",c);
}

//小鸟动画 需要更多素材
- (void)animateHero
{
    SKAction *action1 = [SKAction moveTo:CGPointMake(self.size.width, self.size.height/2+100) duration:3];
    
//    SKAction *pipeTopSequence = [SKAction sequence:@[pipeTopAction, [SKAction runBlock:^{
//        [pipeTop removeFromParent];
//    }]]];
//    
//    [pipeTop runAction:[SKAction repeatActionForever:pipeTopSequence]];
    NSArray *animationFrames = @[
                                 [SKTexture textureWithImageNamed:@"hero1"],
                                 [SKTexture textureWithImageNamed:@"hero2"]
                                 ];
    SKAction *action2 = [SKAction animateWithTextures:animationFrames
                     timePerFrame:0.1f
                           resize:NO
                          restore:YES];
    
    SKAction *sequence = [SKAction group:@[action2]];
    
    [_player     runAction:[SKAction repeatActionForever:
                            sequence]
                   withKey:@"flyingHero"];
//    [_player     runAction:[SKAction repeatActionForever:
//                            action1]
//                   withKey:@"flyingHero"];

}

@end
