//
//  MJDownLoad.m
//  MJAVPlayer
//
//  Created by 马家俊 on 16/11/4.
//  Copyright © 2016年 MJJ. All rights reserved.
//

#import "MJDownLoad.h"

static MJDownLoad *g_MJDownLoad;

@implementation MJDownLoad

+ (MJDownLoad *)shareInstanceManager
{
    @synchronized(self)
    {
        if (!g_MJDownLoad)
        {
            g_MJDownLoad = [[MJDownLoad alloc] init];
        }
    }
    return g_MJDownLoad;
}

-(void)downLoadWithUrl:(NSString*)strUrl
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) ;
    NSString *documentsDire = [paths objectAtIndex:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *fileName = GetFileName;
    NSString *fileNameWithMP4 = [fileName stringByAppendingString:@".mp4"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString* createPath = [NSString stringWithFormat:@"%@/VedioCache/%@", documentsDire,fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath])
    {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else
    {
        NSLog(@"FileDir is exists.");
    }
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",createPath,fileNameWithMP4];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *requst = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:requst progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        [UserDefaults setObject:fullPath forKey:fileName];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"下载完成！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"%@",fullPath);
    }];
    [task resume];
}

-(NSString*)getLocalVedio:(NSString *)strUrl
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) ;
    NSString *documentsDire = [paths objectAtIndex:0];
    NSString *fileName = GetFileName;
    NSString* urlPath = [NSString stringWithFormat:@"%@/VedioCache/%@/%@.mp4", documentsDire,fileName,fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:urlPath]) {
        return urlPath;
    }else
    {
        return @"";
    }
}

@end
