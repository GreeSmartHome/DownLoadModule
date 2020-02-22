//
//  GRDownLoaderFileTool.h
//  DownLoadModule_Example
//
//  Created by 冉东军 on 2020/2/12.
//  Copyright © 2020 1049646716@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GRDownLoaderFileTool : NSObject
/**
  检查文件是否存在
 */
+ (BOOL)isFileExists: (NSString *)path;

/**
  获取本地文件大小
*/
+ (long long)fileSizeWithPath: (NSString *)path;

/**
  移动文件
*/
+ (void)moveFile:(NSString *)fromPath toPath: (NSString *)toPath;

/**
  删除文件
*/
+ (void)removeFileAtPath: (NSString *)path;

@end

NS_ASSUME_NONNULL_END
