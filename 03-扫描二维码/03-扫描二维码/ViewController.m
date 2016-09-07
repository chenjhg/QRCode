//
//  ViewController.m
//  03-扫描二维码
//
//  Created by xiaomage on 15/8/19.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width


@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) AVCaptureSession *session;
@property (nonatomic, weak) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic,strong) UIImageView *bgimageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic,copy) UILabel *promptLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (UILabel *)promptLabel
{
    if (!_promptLabel)
    {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.hidden = YES;
        _promptLabel.frame = CGRectMake(80, 50, 200, 40);
        _promptLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_promptLabel];
    }
    return _promptLabel;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    
    // 2.添加输入设备(数据从摄像头输入)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [session addInput:input];
    
    // 3.添加输出数据(示例对象-->类对象-->元类对象-->根元类对象)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    // 3.1.设置输入元数据的类型(类型是二维码数据)
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 4.添加扫描图层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.frame = self.view.bounds;
    [self.view.layer addSublayer:layer];
    self.layer = layer;
    
    UIImage *imagelayer = [UIImage imageNamed:@"backgroundView"];
    UIImageView *bgimageView = [[UIImageView alloc] init];
    bgimageView.frame = CGRectMake(80, 150, kScreenWidth-160, 200);
    bgimageView.image = imagelayer;
    bgimageView.alpha = 0.3;
    [self.view addSubview:bgimageView];
    self.bgimageView = bgimageView;
    [self.view bringSubviewToFront:bgimageView];
    
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(80, CGRectGetMinY(self.bgimageView.frame), kScreenWidth - 160, 2)];
    self.line.image = [UIImage imageNamed:@"qrcode_line"];
    [self.view addSubview:self.line];
    
    // 5.开始扫描
    [session startRunning];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timeAction:(NSTimer *)timer
{
    __block CGRect rect = _line.frame;
    [UIView animateWithDuration:2 animations:^{
        rect.origin.y = CGRectGetMaxY(self.bgimageView.frame);
        _line.frame = rect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2 animations:^{
            rect.origin.y = CGRectGetMinY(self.bgimageView.frame);
            _line.frame = rect;
        }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.session stopRunning];
    [self.timer invalidate];
}

#pragma mark - 实现output的回调方法
// 当扫描到数据时就会执行该方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        NSLog(@"%@", object.stringValue);
        
        // 停止扫描
        [self.session stopRunning];
        
        // 将预览图层移除
        [self.layer removeFromSuperlayer];
        [self.bgimageView removeFromSuperview];
        [self.line removeFromSuperview];
        self.promptLabel.hidden = NO;
        self.promptLabel.text = object.stringValue;
        
    } else {
        NSLog(@"没有扫描到数据");
    }
}

@end
