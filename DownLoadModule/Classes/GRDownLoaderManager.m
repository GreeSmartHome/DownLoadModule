//
//  GRDownLoaderManager.m
//  DownLoadModule_Example
//
//  Created by 冉东军 on 2020/2/13.
//  Copyright © 2020 1049646716@qq.com. All rights reserved.
//

#import "GRDownLoaderManager.h"
#import "NSString+MD5.h"

@interface GRDownLoaderManager ()

@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

@implementation GRDownLoaderManager

static GRDownLoaderManager *_shareInstance;
+ (instancetype)shareInstance {
    if (_shareInstance == nil) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

// key: md5(url)  value: XMGDownLoader 存储多个下载任务
- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

- (void)downLoaderWithURL:(NSURL *)url totalSize:(TotalSizeBlockType)totalSizeBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock
{
    // 1. url
    NSString *urlMD5 = [url.absoluteString md5Str];
    
    // 2. 根据 urlMD5 , 查找相应的下载器
    GRDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (!downLoader) {
        downLoader = [[GRDownLoader alloc]init];
        [self.downLoadInfo setValue:downLoader forKey:urlMD5];
    }
    
    __weak typeof(self) weakSelf = self;
    [downLoader downLoaderWithURL:url totalSize:^(long long totalSize) {
       
        totalSizeBlock(totalSize);
    } progress:^(float progress) {
       
        progressBlock(progress);
    } success:^(NSString * _Nonnull filePath) {
        
        //移除这个下载器
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        
        //拦截block
        if (successBlock) {
             successBlock(filePath);
        }
        
    } failed:^{
        //移除这个下载器
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        if (failedBlock) {
            failedBlock();
        }
    }];
    
}

/**
  暂停下载
 */
- (void)pauseWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5Str];
    GRDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader) {
        [downLoader pauseCurrentTask];
    }
}

/**
  开始继续下载
*/
- (void)resumeWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5Str];
    GRDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader) {
        [downLoader resumeCurrentTask];
    }
}

/**
 取消下载
*/
- (void)cancelWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5Str];
    GRDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader) {
        [downLoader cancelCurrentTask];
    }
}

/**
 暂停所有下载任务
*/
- (void)pauseAllTask {
    //取出的所有对象都调用一个方法
    [self.downLoadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
}
/**
 继续所有下载任务
*/
- (void)resumeAllTask {
    
    [self.downLoadInfo.allValues performSelector:@selector(resumeCurrentTask) withObject:nil];
}

@end
