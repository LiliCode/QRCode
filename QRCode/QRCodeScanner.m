//
//  QRCodeScanner.m
//  QRCode
//
//  Created by LiliEhuu on 16/9/6.
//  Copyright © 2016年 LiliEhuu. All rights reserved.
//

#import "QRCodeScanner.h"
#import <AVFoundation/AVFoundation.h>

#define LMargin (20.0f)
#define RMargin (20.0f)
#define TMargin (140.0f)

@interface QRCodeScanner ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong , nonatomic) AVCaptureSession *session;       //捕获会话
@property (strong , nonatomic) AVCaptureDeviceInput *input;     //设备输入
@property (strong , nonatomic) AVCaptureMetadataOutput *output; //设备输出
@property (strong , nonatomic) AVCaptureVideoPreviewLayer *previewLayer;    //实时图像预览层
//数据传出
@property (strong , nonatomic) successUsingBlock successBlock;
@property (strong , nonatomic) failtrueUsingBlock failBlock;
@property (strong , nonatomic) cancelUsingBlock cancelBlock;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *scannerView;   //扫描区域视图
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scannerWidthConstraint;    //扫描区域宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scannerheightConstraint;   //扫描区域高端
//显示消息
@property (weak, nonatomic) IBOutlet UILabel *showMsgLabel;

@end

@implementation QRCodeScanner

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSannerUI];
    
    [self setupScanner];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //开始扫描
    [self.session startRunning];    //防止在viewDidLoad方法中启动时卡顿
}

- (void)setupSannerUI
{
    //扫描视图四周的颜色
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:.3];
    self.topView.backgroundColor = color;
    self.bottomView.backgroundColor = color;
    self.leftView.backgroundColor = color;
    self.rightView.backgroundColor = color;
    //扫描视图描边
    self.scannerView.layer.borderColor = [[UIColor greenColor] CGColor];
    self.scannerView.layer.borderWidth = 1;
}

- (void)setupScanner
{
    //为会话设置输入和输出IO设备
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    //创建预览层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = self.view.bounds;
    //将图层添加到当前View的layer
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)setCodeType:(ScanCodeType)codeType
{
    _codeType = codeType;
    
    switch (codeType)
    {
        case ScanCodeTypeQRCode:
        {
            //设置二维码
            //设置识别区域
            [self.output setRectOfInterest:[self getScanRect]];
            //设置扫描类型
            if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode])
            {
                self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            }
        }break;
            
        case ScanCodeTypeBarCode:
        {
            //设置条码扫描区域尺寸
            CGSize size = [UIScreen mainScreen].bounds.size;
            CGFloat w = size.width - LMargin - RMargin;
            CGFloat h = w / 2.0f;
            self.scannerheightConstraint.constant = h;  //扫描条形码扫描区高度
            self.scannerWidthConstraint.constant = w;   //宽度
            //设置识别区域
            [self.output setRectOfInterest:[self getScanRect]];
            if ([self.output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code])
            {
                self.output.metadataObjectTypes = @[AVMetadataObjectTypeCode39Code,
                                                    AVMetadataObjectTypeCode128Code,
                                                    AVMetadataObjectTypeCode39Mod43Code,
                                                    AVMetadataObjectTypeEAN13Code,
                                                    AVMetadataObjectTypeEAN8Code,
                                                    AVMetadataObjectTypeCode93Code];
            }
        }break;
            
        default: break;
    }
}



- (void)setShowMsg:(NSString *)showMsg
{
    _showMsg = [showMsg copy];
    
    self.showMsgLabel.text = showMsg;
}

- (AVCaptureSession *)session
{
    if (!_session)
    {
        _session = [AVCaptureSession new];
        //高质量采集图像
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    return _session;
}

- (AVCaptureDeviceInput *)input
{
    if (!_input)
    {
        //设备 类型：视频
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入 摄像头
        _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    
    return _input;
}

- (AVCaptureMetadataOutput *)output
{
    if (!_output)
    {
        _output = [AVCaptureMetadataOutput new];
        //主线程中输出
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    
    return _output;
}

/**
 *  生成扫描区域的rect
 *
 *  @return 返回rect
 */
- (CGRect)getScanRect
{
    CGRect SCRect = [UIScreen mainScreen].bounds;
    
    CGFloat x = ((SCRect.size.width - self.scannerWidthConstraint.constant)/2.0f) / SCRect.size.width;
    CGFloat y = TMargin / SCRect.size.height;
    CGFloat w = self.scannerWidthConstraint.constant / SCRect.size.width;
    CGFloat h = self.scannerheightConstraint.constant / SCRect.size.height;
    
    return CGRectMake(y, x, h, w);
}


+ (instancetype)qrCodeScannerWithSuccess:(void (^)(QRCodeScanner *__weak, NSString *))successBlock failtrue:(void (^)(QRCodeScanner *__weak, NSError *))failtrueBlock cancel:(void (^)(QRCodeScanner *__weak))cancelBlock
{
    QRCodeScanner *scanner = [[[NSBundle mainBundle] loadNibNamed:@"QRCodeScanner" owner:self options:nil] firstObject];
    scanner.successBlock = successBlock;
    scanner.failBlock = failtrueBlock;
    scanner.cancelBlock = cancelBlock;
    
    return scanner;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断扫描结果，如果扫描成功 metadataObjects.count > 0
    if (metadataObjects.count > 0)
    {
        //停止扫描
        [self.session stopRunning];
        //获取数据
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects firstObject];
        if (obj.stringValue && obj.stringValue.length)
        {
            if (self.successBlock)
            {
                self.successBlock(self, obj.stringValue);
            }
        }
        else
        {
            //失败
            if (self.failBlock)
            {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"扫描失败"}];
                self.failBlock(self, error);
            }
        }
    }
    else
    {
        //失败
        if (self.failBlock)
        {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"扫描失败"}];
            self.failBlock(self, error);
        }
    }
}


- (IBAction)cancelScan:(UIButton *)sender
{
    [self.session stopRunning];
    if (self.cancelBlock)
    {
        self.cancelBlock(self);
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc
{
    NSLog(@"二维码扫描器释放");
}

@end





