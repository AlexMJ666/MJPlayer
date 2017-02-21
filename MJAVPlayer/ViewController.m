//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by CaoJie on 14-5-5.
//  Copyright (c) 2014年 yiban. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MJPlayerView.h"

@interface ViewController ()<MJPlayerViewDelegate>
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong)  MJPlayerView *playerView1;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.playerView1 = [[MJPlayerView alloc]initWithFrame:CGRectMake(0, 0, kMainScreen_Width, kMainScreen_Height/2)];
    [self.view addSubview:self.playerView1];
    self.playerView1.mjPlayerViewDelegate = self;
    [self.playerView1 initMJPlayer:@"http://baobab.wdjcdn.com/1451897812703c.mp4"];
    [self.playerView1 StartPlay];
}

-(void)fullScreenOrShrinkScreenDelegate:(UIButton *)sender
{
    if (sender.selected) {
        [self.navigationController setNavigationBarHidden:YES];
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
        self.playerView1.frame = CGRectMake(0, 0,kMainScreen_Width ,kMainScreen_Height );
    }else
    {
        [self.navigationController setNavigationBarHidden:NO];
        self.playerView1.frame = CGRectMake(0, 0,kMainScreen_Height , kMainScreen_Width/2);
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
    [UIViewController attemptRotationToDeviceOrientation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
