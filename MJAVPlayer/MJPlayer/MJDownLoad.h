//
//  MJDownLoad.h
//  MJAVPlayer
//
//  Created by 马家俊 on 16/11/4.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#define UserDefaults [NSUserDefaults standardUserDefaults]
#define GetFileName  [[strUrl stringByReplacingOccurrencesOfString:@"/" withString:@""]  stringByReplacingOccurrencesOfString:@"." withString:@""]
@interface MJDownLoad : NSObject
/*!单例模式获取MJDownLoad对象
 *\returns  returns:        返回ParkApply对象
 */
+ (MJDownLoad *)shareInstanceManager;

/*!获取url进行下载
 */
-(void)downLoadWithUrl:(NSString*)strUrl;

/*!获取本地url
 *\returns  returns:        返回NSString 本地URL或者空字符串
 */
-(NSString*)getLocalVedio:(NSString*)strUrl;
@end
