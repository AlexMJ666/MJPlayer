//
//  ShotLabel.h
//  MJAVPlayer
//
//  Created by 马家俊 on 16/11/25.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMainScreen_Height [UIScreen mainScreen].bounds.size.height
#define kMainScreen_Width [UIScreen mainScreen].bounds.size.width

@interface ShotLabel : UILabel
@property (nonatomic, strong) NSString* shotText;
@property (nonatomic, strong) UIColor* shotColor;
@property (nonatomic, assign) NSInteger shotWay;
@end
