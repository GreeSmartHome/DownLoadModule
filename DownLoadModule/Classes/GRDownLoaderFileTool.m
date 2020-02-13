//
//  GRDownLoaderFileTool.m
//  DownLoadModule_Example
//
//  Created by 冉东军 on 2020/2/12.
//  Copyright © 2020 1049646716@qq.com. All rights reserved.
//

#import "GRDownLoaderFileTool.h"

@implementation GRDownLoaderFileTool
/**
  检查文件是否存在
 */
+ (BOOL)isFileExists: (NSString *)path {
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/**
  获取本地文件大小
*/
+ (long long)fileSizeWithPath: (NSString *)path {
    
    if (![self isFileExists:path]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    long long size = [fileInfo[NSFileSize] longLongValue];
    
    return size;
    
}

/**
  移动文件
*/
+ (void)moveFile:(NSString *)fromPath toPath: (NSString *)toPath {
    
    if (![self isFileExists:fromPath]) {
        return;
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
    
}

/**
  删除文件
*/
+ (void)removeFileAtPath: (NSString *)path {
    
    if (![self isFileExists:path]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
}

@end
