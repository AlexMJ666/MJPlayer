//
//  ShotModel.m
//  MJAVPlayer
//
//  Created by 马家俊 on 16/11/25.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import "ShotModel.h"

@implementation ShotModel
@synthesize shotID;
@synthesize shotText;
@synthesize shotTime;
@synthesize shotColor;
@synthesize shotPosition;
-(id)init
{
    self = [super init];
    if (self) {
        shotColor = [UIColor whiteColor];
        shotTime = @"";
        shotText = @"";
        shotID = @"";
        shotPosition = ShotPositionMove;
    }
    return self;
}
-(id)parseFromDic:(NSDictionary *)dic
{
    if ([self init]) {
    }
    return self;
}
@end
