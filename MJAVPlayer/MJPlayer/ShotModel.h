//
//  ShotModel.h
//  MJAVPlayer
//
//  Created by 马家俊 on 16/11/25.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, ShotPosition){
    ShotPositionTop,
    ShotPositionMiddle,
    ShotPositionBottom,
    ShotPositionMove
};

@interface ShotModel : NSObject
{
    NSString* shotID;
    NSString* shotText;
    UIColor * shotColor;
    ShotPosition shotPosition;
    NSString* shotTime;
}
@property (nonatomic, strong) NSString* shotID;
@property (nonatomic, strong) NSString* shotText;
@property (nonatomic, strong) UIColor * shotColor;
@property (nonatomic, strong) NSString* shotTime;
@property (nonatomic, assign) ShotPosition shotPosition;
@end
