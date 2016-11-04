//
//  MJPlayerView.m
//  MJAVPlayer
//
//  Created by 马家俊 on 16/10/31.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import "MJPlayerView.h"

#define kTimeLableZreo              @"00:00/00:00"
@interface MJPlayerView()
@property (nonatomic,strong) UIView* bottomControlView;                 //底部控制界面
@property (nonatomic,strong) UISlider* timeProgress;                    //进度条
@property (nonatomic,strong) UILabel* timeLabel;                        //时间显示label
@property (nonatomic,strong) UIButton* playBtn;                         //播放按钮
@property (nonatomic,strong) UIButton* fullScreenBtn;                   //全屏按钮
@property (nonatomic ,strong) AVPlayerItem *playerItem;                 //AVPlyaer的播放资源
@property (nonatomic,strong) NSTimer* playLabelTime;                    //获取播放时间的NSTime
@property (nonatomic,strong) NSTimer* sliderTime;                       //获取进度条时间的NSTime
@end
@implementation MJPlayerView

-(void)StartPlay
{
    [self.player play];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMJPlayerFrame:frame];
    }
    return self;
}

/**获取AVPlayerLayer的layer
 *
 *  @returns 返回AVPlayerLayer对象
 */
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

/**重写get方法
 *
 */
- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}
/**重写set方法
 *
 */
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

#pragma Mark----用代码初始化页面
-(void)initMJPlayerFrame:(CGRect)frame
{
    self.backgroundColor = [UIColor blackColor];
    
    //集合底部控件的view，所有底部控件全在该view上
    self.bottomControlView = [UIView new];
//    self.bottomControlView.layer.borderColor = [UIColor redColor].CGColor;
//    self.bottomControlView.layer.borderWidth = 1;
    [self addSubview:self.bottomControlView];
    
    [self.bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).offset(-40);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
    }];
    //添加播放器控件

    self.timeProgress = [UISlider new];
    self.timeProgress.minimumValue = 0;
    self.timeProgress.maximumValue = 1;
    [self.timeProgress addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    self.timeProgress.minimumTrackTintColor = [UIColor whiteColor];
    self.timeProgress.maximumTrackTintColor = [UIColor grayColor];
    
    [self.timeProgress setThumbImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.timeProgress setThumbImage:[UIImage imageNamed:@"MJPlayer_slider"] forState:UIControlStateHighlighted];
    
    [self.bottomControlView addSubview:self.timeProgress];
    [self.timeProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(0, 40, 10, 40));
    }];
    //添加播放按钮
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"MJPlayer_play"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"MJPlayer_pause"] forState:UIControlStateSelected];
    [self.playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn.selected = YES;
    [self.bottomControlView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomControlView).offset(12);
        make.top.equalTo(self.bottomControlView).offset(6);
        make.width.equalTo(@(18));
        make.height.equalTo(@(20));
    }];
    //添加全屏按钮
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"MJPlayer_fullscreen"] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"MJPlayer_shrinkscreen"] forState:UIControlStateSelected];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenOrShrinkScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomControlView addSubview:self.fullScreenBtn];
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomControlView).offset(-12);
        make.top.equalTo(self.bottomControlView).offset(8);
        make.width.equalTo(@(15));
        make.height.equalTo(@(15));
    }];
    
    //添加时间label
    self.timeLabel = [UILabel new];
    self.timeLabel.text = kTimeLableZreo;
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    [self.bottomControlView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeProgress);
        make.top.equalTo(self.timeProgress.mas_bottom).offset(-12);
        make.width.equalTo(@(200));
        make.height.equalTo(@(21));
    }];
}

-(void)initMJPlayer:(NSString*)vedioUrlStr
{
    NSURL *videoUrl = [NSURL URLWithString:vedioUrlStr];
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

#pragma Mark----timeProgress滑动停止事件
-(void)sliderChange:(UISlider*)sender
{
    CGFloat totalTime = self.playerItem.duration.value / self.playerItem.duration.timescale;
    CMTime changedTime = CMTimeMakeWithSeconds(totalTime*sender.value, 1);
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
    }];
}

#pragma Mark----playBtn播放按钮点击事件
-(void)playOrPause:(UIButton*)sender
{
    if (!sender.selected) {
        [self.player play];
    }else
    {
        [self.player pause];
    }
    sender.selected = !sender.selected;
}

#pragma Mark----fullScreenBtn全屏按钮点击事件
-(void)fullScreenOrShrinkScreen:(UIButton*)sender
{
    sender.selected = !sender.selected;
    
    if (_mjPlayerViewDelegate&&[_mjPlayerViewDelegate respondsToSelector:@selector(fullScreenOrShrinkScreenDelegate:)]) {
        [_mjPlayerViewDelegate fullScreenOrShrinkScreenDelegate:sender];
    }
}

#pragma Mark----播放完成的通知
-(void)playFinished:(NSNotification*)notif
{
}

#pragma Mark----监听playerItem属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([playerItem status] == AVPlayerStatusReadyToPlay) {
        [self listenTimeChange];
    } else if ([playerItem status] == AVPlayerStatusFailed) {
        //.....
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //监听播放器的下载进度
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        //获取缓冲区域
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //计算缓冲总进度
        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        NSLog(@"下载进度：%.2f", timeInterval / totalDuration);
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //监听播放器在缓冲数据的状态
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        [self.player play];
    }
    
}

//监控时间变化
-(void)listenTimeChange
{
    [self.player removeTimeObserver:self.playLabelTime];
    __weak typeof (self)self_ = self;
    self.playLabelTime = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat playTime = self_.player.currentTime.value/self_.player.currentTime.timescale;
        CGFloat totalTime = self_.playerItem.duration.value / self_.playerItem.duration.timescale;
        CGFloat percent = playTime/totalTime;
        self_.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self_ changeTime:playTime],[self_ changeTime:totalTime]];
        self_.timeProgress.value = percent;
    }];
}

//时间转换成播放时间
- (NSString *)changeTime:(CGFloat)time{
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (time/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    return [formatter stringFromDate:timeDate];
}

-(void)dealloc
{
    [self.player removeTimeObserver:self.playLabelTime];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[NSNotificationCenter defaultCenter]removeObserver:self.player.currentItem];
}
@end
