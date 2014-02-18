//
//  ViewController.m
//  FlapFlap
//
//  Created by wk on 2/9/14.
//  Copyright (c) wktzjz@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "NewGameScene.h"
#import "UIView+AutoLayout.h"
#import "MainScene.h"

@interface ViewController() <GameSceneDelegate>
{
    BOOL _pause;
}

@property (nonatomic, strong) SKView *gameView;
@property (nonatomic, strong) NewGameScene *gameScene;
@property (nonatomic, strong) UIButton *pauseButton;

- (void)didTapPauseButton:(id)sender;
- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification;
- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification;
@end


@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveApplicationWillResignActiveNotification:)
                                   name:UIApplicationWillResignActiveNotification
                                 object:[UIApplication sharedApplication]];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveApplicationDidBecomeActiveNotification:)
                                   name:UIApplicationDidBecomeActiveNotification
                                 object:[UIApplication sharedApplication]];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveGameSceneStart:)
                                   name:@"gameStart"
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(didReceiveGameSceneEnd:)
                                   name:@"gameEnd"
                                 object:nil];

    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle
- (void)loadView
{
  self.view  = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

//- (void)viewDidLoad
- (void)viewWillLayoutSubviews
{
//  [super viewDidLoad];
    [super viewWillLayoutSubviews];

  [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

//  SKView *skView = (SKView *)[self view];
//  [skView setShowsFPS:YES];
//  [skView setShowsNodeCount:YES];
//
//  SKScene *scene = [NewGameScene sceneWithSize:skView.bounds.size];
//  [scene setScaleMode:SKSceneScaleModeAspectFill];
//
//  [skView presentScene:scene];
    _gameView = [[SKView alloc] initWithFrame:self.view.bounds];
    
    [_gameView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:_gameView];
    
     if (!_gameView.scene) {
        [_gameView setShowsFPS:YES];
        [_gameView setShowsNodeCount:YES];
        
        _gameScene = [NewGameScene sceneWithSize:_gameView.bounds.size];
        [_gameScene setScaleMode:SKSceneScaleModeAspectFit];
        
        [_gameView presentScene:_gameScene];
     }
    
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_pauseButton setAlpha:0.0];
    [_pauseButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_pauseButton setTitle:NSLocalizedString(@"X", nil) forState:UIControlStateNormal];
    [_pauseButton.titleLabel setFont:[UIFont fontWithName:@"PressStart2P" size:20.0]];
    [_pauseButton addTarget:self
                     action:@selector(didTapPauseButton:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_pauseButton];
    
    [_pauseButton autoSetDimensionsToSize:CGSizeMake(44.0, 44.0)];
    [_pauseButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:2.0];
    [_pauseButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:2.0];

    _pause = NO;
   
}

#pragma mark - Control actions
- (void)didTapPauseButton:(id)sender {
//    [_gameView setPaused:YES];
    
    if(!_pause){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gamePause" object:self];
//        [_gameView setPaused:YES];
        [_pauseButton setTitle:NSLocalizedString(@"X", nil) forState:UIControlStateNormal];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"gamePause" object:self];
        _pause = YES;
    }else{
         [[NSNotificationCenter defaultCenter] postNotificationName:@"gameContinue" object:self];
//        [_gameView setPaused:NO];
        [_pauseButton setTitle:NSLocalizedString(@"GO", nil) forState:UIControlStateNormal];
        
        _pause = NO;
    }

}

#pragma mark - Notifications

- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification {
    [_gameView setPaused:YES];
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [_gameView setPaused:NO];
}

- (void)didReceiveGameSceneStart:(NSNotification *)notification {
    
    [_pauseButton setAlpha:0.0];
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [_pauseButton setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)didReceiveGameSceneEnd:(NSNotification *)notification {
    
    [_pauseButton setAlpha:1.0];
    
    [UIView animateWithDuration:0.33
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [_pauseButton setAlpha:0.0];
                     } completion:^(BOOL finished) {
                         _pause = NO;
                     }];
}

//#pragma mark - Game scene delegate
//
//- (void)gameSceneDidStartGame:(MainScene *)scene {
// 
//     [_pauseButton setAlpha:0.0];
//    
//    [UIView animateWithDuration:0.1
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                        
//                         [_pauseButton setAlpha:1.0];
//                     } completion:^(BOOL finished) {
//                       
//                     }];
//}
//
//- (void)gameSceneDidEndGame:(MainScene *)scene {
//
//    
//    [UIView animateWithDuration:0.33
//                          delay:1.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                    
//                         [_pauseButton setAlpha:0.0];
//                     } completion:nil];
//}

@end
