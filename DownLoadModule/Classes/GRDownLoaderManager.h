//
//  GRDownLoaderManager.h
//  DownLoadModule_Example
//
//  Created by 冉东军 on 2020/2/13.
//  Copyright © 2020 1049646716@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRDownLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GRDownLoaderManager : NSObject

+ (instancetype)shareInstance;

/**
  开始下载
 */
- (void)downLoaderWithURL:(NSURL *)url totalSize:(TotalSizeBlockType)totalSizeBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;
/**
  暂停下载
 */
- (void)pauseWithURL:(NSURL *)url;

/**
 开始继续下载
*/
- (void)resumeWithURL:(NSURL *)url;

/**
 取消下载
*/
- (void)cancelWithURL:(NSURL *)url;

/**
 暂停所有下载任务
*/
- (void)pauseAllTask;
/**
 继续所有下载任务
*/
- (void)resumeAllTask;

@end

NS_ASSUME_NONNULL_END
