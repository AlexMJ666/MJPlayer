//
//  MJPlayerView.h
//  MJAVPlayer
//
//  Created by 马家俊 on 16/10/31.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import "MJDownLoad.h"
#import <MediaPlayer/MediaPlayer.h>
#define kMainScreen_Height [UIScreen mainScreen].bounds.size.height
#define kMainScreen_Width [UIScreen mainScreen].bounds.size.width

@protocol MJPlayerViewDelegate <NSObject>
-(void)fullScreenOrShrinkScreenDelegate:(UIButton*)sender;
@end
@interface MJPlayerView : UIView

@property (nonatomic, weak) id<MJPlayerViewDelegate> mjPlayerViewDelegate;
@property (nonatomic ,strong) AVPlayer *player;

/**初始化播放器
 *
 *  @param vedioUrlStr 视频url
 */
-(void)initMJPlayer:(NSString*)vedioUrlStr;

/**开始播放
 */
-(void)StartPlay;

@end
