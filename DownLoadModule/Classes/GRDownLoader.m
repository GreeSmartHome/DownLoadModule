//
//  GRDownLoader.m
//  DownLoadModule_Example
//
//  Created by 冉东军 on 2020/2/12.
//  Copyright © 2020 1049646716@qq.com. All rights reserved.
//

#import "GRDownLoader.h"
#import "GRDownLoaderFileTool.h"
#import "NSString+MD5.h"

#define kCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmp NSTemporaryDirectory()

@interface GRDownLoader () <NSURLSessionDataDelegate>
{
    // 临时文件的大小
    long long _tmpFileSize;
    // 文件的总大小
    long long _totalFileSize;
}
/** 文件的缓存路径 */
@property (nonatomic, copy) NSString *cacheFilePath;
/** 文件的临时缓存路径 */
@property (nonatomic, copy) NSString *tmpFilePath;
/** 下载会话 */
@property (nonatomic, strong) NSURLSession *session;
/** 文件输出流 */
@property (nonatomic, strong) NSOutputStream *outputStream;
/** 下载任务 */
@property (nonatomic, weak) NSURLSessionDataTask *task;

@end

@implementation GRDownLoader
#pragma mark - 懒加载

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
- (void)downLoaderWithURL:(NSURL *)url totalSize:(TotalSizeBlockType)totalSizeBlock progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock {
    
    // 1. 给所有的block赋值
    self.totalSizeBlock = totalSizeBlock;
    self.progressBlock = progressBlock;
    self.successBlock = successBlock;
    self.faildBlock = failedBlock;
    
    //2.开始下载
    [self downLoaderWithURL:url];
    
}
/**
  如果当前已经下载, 继续下载, 如果没有下载, 从头开始下载
 */
- (void)downLoaderWithURL:(NSURL *)url {
  
    // 判断此任务是否存在: 如果当前任务不存在,开始从头下载
    if ([url isEqual:self.task.originalRequest.URL]) {
        
        // 状态 -> 正在下载 返回
        if (self.state == DownLoaderStateDowning){
            return;
        }
        // 状态 -> 暂停 = 恢复
        if (self.state == DownLoaderStatePause){
            //继续任务
            [self resumeCurrentTask];
            return;
        }
    }
    // 当任务存在，但是URL不相同,取消任务 重新下载
    [self cancelCurrentTask];
    
    //1.首先判断本地是否已经下载好，下载好直接 reture
      //    下载中 -> tmp + (url + MD5)
      //    下载完成 -> cache + url.lastCompent
    self.cacheFilePath = [kCache stringByAppendingPathComponent:url.lastPathComponent];
    self.tmpFilePath = [kTmp stringByAppendingPathComponent:url.lastPathComponent];
    
    if ([GRDownLoaderFileTool isFileExists:self.cacheFilePath]) {
        NSLog(@"文件已经下载完毕, 直接返回相应的数据--文件的具体路径, 文件的大小");
        self.state = DownLoaderStateSuccess;
        return;
    }
    // 2. 检测, 临时文件是否存在
    //必须放这里，防止获取到的缓存值不对
    _tmpFileSize = [GRDownLoaderFileTool fileSizeWithPath:self.tmpFilePath];

    // 2.2 不存在: 从0字节开始请求资源 ，存在:继续按当前大小开始下载
    if (![GRDownLoaderFileTool isFileExists:self.tmpFilePath]) {
        // 从0字节开始请求资源
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    // 2. 读取本地的缓存大小,开始下载
    [self downLoadWithURL:url offset:_tmpFileSize];
    
}

//开始任务 ；暂停了几次, 恢复几次, 才可以恢复,
- (void)resumeCurrentTask {
    if (self.task && self.state == DownLoaderStatePause) {
       [self.task resume];
        self.state = DownLoaderStateDowning;
    }
}

/**
 暂停下载, 可以恢复, 缓存没有删除
 */
- (void)pauseCurrentTask {
    if (self.state == DownLoaderStateDowning) {
       [self.task suspend];
        self.state = DownLoaderStatePause;
    }
}

/**
 取消下载任务, 这次任务已经被取消,
 */
- (void)cancelCurrentTask {
    [self.session invalidateAndCancel];
     self.session = nil;
    
     self.state = DownLoaderStatePause;
}

/**
  取消下载并清除缓存
 */
- (void)cancelAndClearCache {
    [self cancelCurrentTask];
    
    //清除缓存
    [GRDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
    
}

#pragma mark - 私有方法
- (void)downLoadWithURL:(NSURL *)url offset: (long long)offset {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.task = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}

#pragma mark - NSURLSessionDataDelegate

/**
 当发送的请求, 第一次接受到响应的时候调用,

 @param completionHandler 系统传递给我们的一个回调代码块, 我们可以通过这个代码块, 来告诉系统,如何处理, 接下来的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 取资源总大小
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpResponse.allHeaderFields[@"Content-Range"] ;
        _totalFileSize = [[[rangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
        
    }
    
    // 判断, 本地的缓存大小 与 文件的总大小
    if (_tmpFileSize == _totalFileSize) {
        NSLog(@"文件已经下载完成, 移动数据");
        //1. 移动临时缓存的文件 -> 下载完成的路径
        [GRDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        
        //2. 取消请求
        completionHandler(NSURLSessionResponseCancel);
        
        //3.修改状态
        self.state = DownLoaderStateSuccess;
        
        return;
    }
    
    if (_tmpFileSize > _totalFileSize) {
        
        NSLog(@"缓存有问题, 删除缓存, 重新下载");
        // 删除缓存
        [GRDownLoaderFileTool removeFileAtPath:self.tmpFilePath];
        
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 重新发送请求  0
        [self downLoadWithURL:response.URL offset:0];
        return;
        
    }
    
    // 继续接收数据, 确定开始下载数据
    NSLog(@"继续接收数据");
    self.state = DownLoaderStateDowning;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}

// 当用户确定, 继续接受数据的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 这就是当前已经下载的大小
    _tmpFileSize += data.length;
    
    self.progress =  1.0 * _tmpFileSize / _totalFileSize;
    
    //往输出流中写入数据
    [self.outputStream write:data.bytes maxLength:data.length];
//    NSLog(@"在接收后续数据");
}

//下载完成调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        NSLog(@"下载完毕, 成功");
        // 移动数据  temp - > cache
        [GRDownLoaderFileTool moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        self.state = DownLoaderStateSuccess;
    }else {
        NSLog(@"有错误==%ld ==%@",(long)error.code,error.localizedDescription);
        if (error.code == -999) {
            self.state = DownLoaderStatePause;
        }else{
            self.state = DownLoaderStateFailed;
        }
        
    }
    [self.outputStream close];
    self.outputStream = nil;
    
}
#pragma mark - 事件/数据传递

- (void)setState:(DownLoaderState)state {
    // 数据过滤
    if(_state == state) {
        return;
    }
    _state = state;
    
    if (_state == DownLoaderStateSuccess && self.successBlock) {
        self.successBlock(self.cacheFilePath);//返回下载完成路径
    }
    
    if (_state == DownLoaderStateFailed && self.faildBlock) {
        self.faildBlock();
    }
    
}

- (void)setProgress:(float)progress {
    _progress = progress;
    
    if (self.progressBlock) {
        self.progressBlock(_progress);
    }
}

@end
