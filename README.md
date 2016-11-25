# MJPlayer
基于AVPlayer
使用方法：
在VC中
#import "MJPlayerView.h"

然后在属性中添加
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong)  MJPlayerView *playerView1;

在viewDidLoad中初始化
self.playerView1 = [[MJPlayerView alloc]initWithFrame:CGRectMake(0, 0, kMainScreen_Width, kMainScreen_Height/2)];
    [self.view addSubview:self.playerView1];
    self.playerView1.mjPlayerViewDelegate = self;
    [self.playerView1 initMJPlayer:@"http://baobab.wdjcdn.com/1451897812703c.mp4"];
    [self.playerView1 StartPlay];

实现代理
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
