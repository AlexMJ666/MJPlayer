//
//  MJPlayerView.m
//  MJAVPlayer
//
//  Created by 马家俊 on 16/10/31.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import "MJPlayerView.h"

#define kTimeLableZreo              @"00:00/00:00"

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

@interface MJPlayerView()<UIGestureRecognizerDelegate>
{
    NSString* vedioUrl;
    UITapGestureRecognizer *singleTapGestureRecognizer;
}
@property (nonatomic,strong) UIView* bottomControlView;                 //底部控制界面
@property (nonatomic,strong) UISlider* timeProgress;                    //进度条
@property (nonatomic,strong) UILabel* timeLabel;                        //时间显示label
@property (nonatomic,strong) UIButton* playBtn;                         //播放按钮
@property (nonatomic,strong) UIButton* fullScreenBtn;                   //全屏按钮
@property (nonatomic ,strong) AVPlayerItem *playerItem;                 //AVPlyaer的播放资源
@property (nonatomic,strong) NSTimer* playLabelTime;                    //获取播放时间的NSTime
@property (nonatomic,strong) UIButton* downLoadBtn;                      //下载按钮
@property (nonatomic,strong) UIPanGestureRecognizer* panGes;            //控制音量及亮度手势
@property (nonatomic, assign) PanDirection panDirection;      //定义一个实例变量，保存枚举值
@property (nonatomic, strong) UISlider *volumeViewSlider;       //调节滑竿
@property (nonatomic, assign) BOOL isVolume;                    //是否在调节音量
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
    
    
    /*界面 ROUND 2********************************************************************************************/
    self.downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downLoadBtn setImage:[UIImage imageNamed:@"MJPlayer_download"] forState:UIControlStateNormal];
    [self.downLoadBtn setImage:[UIImage imageNamed:@"MJPlayer_not_download"] forState:UIControlStateSelected];
    [self.downLoadBtn addTarget:self action:@selector(downLoadBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.downLoadBtn];
    [self.downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@(49));
        make.width.equalTo(@(40));
    }];
    
    //添加手势
    singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapGestureRecognizer];
    //延迟隐藏控制界面
    [self showAndHideControl:0];
}

#pragma Mark -- 添加手势控制声音及亮度
-(void)addControlVolmeAndLight:(BOOL)isLandscape
{
    if (isLandscape) {
        _panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(controlVolmeAndLight:)];
        [self addGestureRecognizer:_panGes];
    }else
    {
        [self removeGestureRecognizer:_panGes];
    }
}

-(void)initMJPlayer:(NSString*)vedioUrlStr
{
    vedioUrl = vedioUrlStr;
    NSURL *videoUrl = [NSURL URLWithString:vedioUrl];
    if ([[[MJDownLoad shareInstanceManager]getLocalVedio:vedioUrl] isEqualToString:@""]) {
        self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        [[MJDownLoad shareInstanceManager]downLoadWithUrl:vedioUrl];
    }else
    {
        NSURL *sourceMovieUrl = [NSURL fileURLWithPath:[[MJDownLoad shareInstanceManager]getLocalVedio:vedioUrl]];
        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        self.downLoadBtn.selected = YES;
    }
    [self setLightAndVolume];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)singleTap:(UITapGestureRecognizer*)tapGesture
{
    __weak typeof (self)self_ = self;
    [UIView animateWithDuration:0.2f animations:^{
        self_.bottomControlView.alpha = 1;
        self_.downLoadBtn.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2f animations:^{
                self_.bottomControlView.alpha = 0;
                self_.downLoadBtn.alpha = 0;
            }];
        });
    }];
}

#pragma Mark----滑动手势响应事件
-(void)controlVolmeAndLight:(UIPanGestureRecognizer*)ges
{
    //根据位置，确定是调音量还是亮度
    CGPoint locationPoint = [ges locationInView:self];
    
    // 获取滑动速度
    CGPoint speed = [ges velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(speed.x);
            CGFloat y = fabs(speed.y);
            if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    //[self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:speed.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }

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
    [self addControlVolmeAndLight:sender.selected];
    if (_mjPlayerViewDelegate&&[_mjPlayerViewDelegate respondsToSelector:@selector(fullScreenOrShrinkScreenDelegate:)]) {
        [_mjPlayerViewDelegate fullScreenOrShrinkScreenDelegate:sender];
    }
}

#pragma Mark----downLoadBtn下载按钮点击事件
-(void)downLoadBtnPress:(UIButton*)sender
{
    if(!sender.selected)
    {
        [[MJDownLoad shareInstanceManager]downLoadWithUrl:vedioUrl];
    }else
    {
        sender.userInteractionEnabled = NO;
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

//显示隐藏控制界面
-(void)showAndHideControl:(NSInteger)alphaNum
{
    __weak typeof (self)self_ = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f animations:^{
            self_.bottomControlView.alpha = alphaNum;
            self_.downLoadBtn.alpha = alphaNum;
        }];
    });
}

/**
 *  获取系统音量
 */
- (void)setLightAndVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mic:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/**
 *  耳机插入、拔出事件
 */
- (void)mic:(NSNotification*)notify
{
    NSDictionary *dic = notify.userInfo;
    
    NSInteger isEarPhone = [[dic valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (isEarPhone) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 拔掉耳机继续播放
            [self StartPlay];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value
{
    //该value为手指的滑动速度，一般最快速度值不会超过10000，保证在0-1之间，往下滑为正，往上滑为负 所以用 “-=”
    NSLog(@"%f",value);
    if (self.isVolume) {
        self.volumeViewSlider.value -= value / 10000;
    }else
    {
        ([UIScreen mainScreen].brightness -= value / 10000);
    }
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
