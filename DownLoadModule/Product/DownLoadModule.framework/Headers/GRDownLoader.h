//
//  GRDownLoader.h
//  DownLoadModule_Example
//
//  Created by 冉东军 on 2020/2/12.
//  Copyright © 2020 1049646716@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DownLoaderState) {
    /** 下载暂停 */
    DownLoaderStatePause,
    /** 正在下载 */
    DownLoaderStateDowning,
    /** 已经下载完成 */
    DownLoaderStateSuccess,
    /** 下载失败 */
    DownLoaderStateFailed
};

typedef void(^ProgressBlockType)(float progress);
typedef void(^TotalSizeBlockType)(long long totalSize);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FailedBlockType)(void);

@interface GRDownLoader : NSObject

/**
  下载器接口
 */
- (void)downLoaderWithURL:(NSURL *)url totalSize:(TotalSizeBlockType)totalSizeBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock;

/**
  如果当前已经下载, 继续下载, 如果没有下载, 从头开始下载
 */
- (void)downLoaderWithURL:(NSURL *)url;

/**
 暂停下载, 可以恢复, 缓存没有删除
 */
- (void)pauseCurrentTask;

/**
 开始继续任务
*/
- (void)resumeCurrentTask;

/**
 取消下载任务, 这次任务已经被取消,
 */
- (void)cancelCurrentTask;

/**
  取消下载并清除缓存
 */
- (void)cancelAndClearCache;

//数据
@property (nonatomic, assign,readonly) DownLoaderState state;
@property (nonatomic, assign, readonly) float progress;

//事件
@property (nonatomic, copy) TotalSizeBlockType totalSizeBlock;
@property (nonatomic, copy) ProgressBlockType progressBlock;
@property (nonatomic, copy) SuccessBlockType successBlock;
@property (nonatomic, copy) FailedBlockType faildBlock;

@end

NS_ASSUME_NONNULL_END
