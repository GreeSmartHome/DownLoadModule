//
//  GRViewController.m
//  DownLoadModule
//
//  Created by 1049646716@qq.com on 02/11/2020.
//  Copyright (c) 2020 1049646716@qq.com. All rights reserved.
//

#import "GRViewController.h"
//#import "GRDownLoader.h"
#import <GRDownLoaderManager.h>

@interface GRViewController ()
@property (nonatomic, strong) GRDownLoader *downLoader;

@property (nonatomic, weak) NSTimer *timer;
- (IBAction)resue:(id)sender;
- (IBAction)pasue:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)clearCancel:(id)sender;

@end

@implementation GRViewController

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateState) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}
//开始下载
- (IBAction)resue:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"https://dldir1.qq.com/music/clntupate/mac/QQMusicMac_Mgr.dmg"];
    NSURL *url2 = [NSURL URLWithString:@"http://wppkg.baidupcs.com/issue/netdisk/MACguanjia/BaiduNetdisk_mac_2.2.3.dmg"];

//    [self.downLoader downLoaderWithURL:url];
    
//    [self.downLoader downLoaderWithURL:url totalSize:^(long long totalSize) {
//        NSLog(@"==%lld",totalSize);
//    } progress:^(float progress) {
//        NSLog(@"==%f",progress);
//    } success:^(NSString * _Nonnull filePath) {
//        NSLog(@"==%@",filePath);
//    } failed:^{
//        NSLog(@"==失败");
//    }];
    
    [[GRDownLoaderManager shareInstance] downLoaderWithURL:url totalSize:^(long long totalSize) {
        NSLog(@"==%lld",totalSize);
    } progress:^(float progress) {
        NSLog(@"==%f",progress);
    } success:^(NSString * _Nonnull filePath) {
        NSLog(@"==%@",filePath);
    } failed:^{
        NSLog(@"==失败");
    }];
    
    [[GRDownLoaderManager shareInstance] downLoaderWithURL:url2 totalSize:^(long long totalSize) {
           NSLog(@"==%lld",totalSize);
       } progress:^(float progress) {
           NSLog(@"==%f",progress);
       } success:^(NSString * _Nonnull filePath) {
           NSLog(@"==%@",filePath);
       } failed:^{
           NSLog(@"==失败");
       }];
    
}
//暂停下载
- (IBAction)pasue:(id)sender {
    [self.downLoader pauseCurrentTask];
}
//取消下载
- (IBAction)cancel:(id)sender {
    [self.downLoader cancelCurrentTask];
}
//取消下载并清除缓存
- (IBAction)clearCancel:(id)sender {
    [self.downLoader cancelAndClearCache];
}

- (GRDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[GRDownLoader alloc] init];
    }
    return _downLoader;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self timer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateState{
    
    NSLog(@"==%lu",(unsigned long)self.downLoader.state);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
}


@end
