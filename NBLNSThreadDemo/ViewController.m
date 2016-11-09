//
//  ViewController.m
//  NBLNSThreadDemo
//
//  Created by snb on 16/11/3.
//  Copyright © 2016年 neebel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITextView *threadInfoTextView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSThread *downloadThread;

@end


@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    //以block形式执行,类方法
    __weak typeof(self) weakSelf = self;
    [NSThread detachNewThreadWithBlock:^{
        [[NSThread currentThread] setName:@"block线程"];
        [NSThread sleepForTimeInterval:0.5];
        NSString *info = [NSString stringWithFormat:@"detach新线程执行Block,thread info:%@", [NSThread currentThread]];
        [weakSelf performSelectorOnMainThread:@selector(fillLabel:) withObject:info waitUntilDone:NO];
    }];
    
    //以方法形式执行，类方法
    [NSThread detachNewThreadSelector:@selector(detachThreadExcuteMethod) toTarget:self withObject:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Getter

- (UITextView *)threadInfoTextView
{
    if (!_threadInfoTextView) {
        UITextView *threadInfoTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 200)];
        threadInfoTextView.textColor = [UIColor redColor];
        threadInfoTextView.text = @"线程执行信息：";
        _threadInfoTextView = threadInfoTextView;
    }
    
    return _threadInfoTextView;
}

- (UIButton *)startButton
{
    if (!_startButton) {
        UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 280, 150, 30)];
        [startButton setTitle:@"点击开始下载图片" forState:UIControlStateNormal];
        [startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [startButton addTarget:self action:@selector(startDownload) forControlEvents:UIControlEventTouchUpInside];
        _startButton = startButton;
    }

    return _startButton;
}

- (NSThread *)downloadThread
{
    if (!_downloadThread) {
        //以方法形式执行，实例方法,需要手动开始
        NSThread *downloadThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadPicture) object:nil];
        [downloadThread setName:@"download thread"];
        _downloadThread = downloadThread;
    }
    
    return _downloadThread;
}


- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 330, 150, 60)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor lightGrayColor];
        _imageView = imageView;
    }
    
    return _imageView;
}

#pragma mark - Private

- (void)initUI
{
    [self.view addSubview:self.threadInfoTextView];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.imageView];
}

#pragma mark - Action

- (void)detachThreadExcuteMethod
{
    [[NSThread currentThread] setName:@"method线程"];
    [NSThread sleepForTimeInterval:0.5];
    NSString *info = [NSString stringWithFormat:@"detach新线程执行方法，thread info:%@",[NSThread currentThread]];
    NSMutableString *str = [NSMutableString stringWithString:info];
    for (NSInteger i = 0; i < 5; i++) {
        [str appendString:[NSString stringWithFormat:@"\n第%@次循环", [NSNumber numberWithInteger:i].stringValue]];
    }
    [self performSelectorOnMainThread:@selector(fillLabel:) withObject:str waitUntilDone:NO];
}


- (void)downloadPicture
{
    NSError *error;
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:
                         [NSURL URLWithString:@"https://www.baidu.com/img/bd_logo1.png"]
                                                      options:0 error:&error];
    if(imageData == nil) {
        NSLog(@"Error: %@", error);
    } else {
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        [self performSelectorOnMainThread:@selector(fillPicture:) withObject:image waitUntilDone:NO];
    }
}


- (void)startDownload
{
    //线程执行完成后会死掉，如果再次调用其start方法会crash
    //线程正在执行中，如果再次调用其start方法也会crash
    if ([self.downloadThread isFinished] || [self.downloadThread isExecuting]) {
        return;
    }
    
    [self.downloadThread start];
}


- (void)fillPicture:(UIImage *)image
{
    self.imageView.image = image;
}


- (void)fillLabel:(NSString *)info
{
    NSMutableString *str = [NSMutableString stringWithString:self.threadInfoTextView.text];
    [str appendString:@"\n\n"];
    [str appendString:info];
    self.threadInfoTextView.text = str;
}

@end
