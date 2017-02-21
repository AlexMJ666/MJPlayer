//
//  ShotLabel.m
//  MJAVPlayer
//
//  Created by 马家俊 on 16/11/25.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import "ShotLabel.h"
#import "ShotModel.h"
@implementation ShotLabel

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

-(void)setLabelProperty:(ShotModel*)model
{
    self.textColor = model.shotColor;
    self.text = model.shotText;
    [self labelAnimation:model.shotPosition];
}

//ShotPositionTop,
//ShotPositionMiddle,
//ShotPositionBottom,
//ShotPositionMove

-(void)labelAnimation:(ShotPosition)shotPos
{
    switch (shotPos) {
        case ShotPositionTop:
            [self delayHiding];
            break;
            
        default:
            break;
    }
}

-(void)delayHiding
{
    self.center = CGPointMake(kMainScreen_Width/2, (kMainScreen_Height/44)*)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    });
}
@end
