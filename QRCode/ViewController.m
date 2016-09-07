//
//  ViewController.m
//  QRCode
//
//  Created by LiliEhuu on 16/9/6.
//  Copyright © 2016年 LiliEhuu. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeGenerator.h"
#import "QRCodeScanner.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //转换成UIImage对象
    self.qrCodeImageView.image = [QRCodeGenerator qrCodeImageForString:@"http:www.ehuu.com" imageSize:CGRectGetWidth(self.qrCodeImageView.bounds)*3 avatarImage:[UIImage imageNamed:@"meinv.jpg"] avatarSize:CGSizeMake(100, 100)];
}


- (IBAction)scanner:(UIBarButtonItem *)sender
{
    QRCodeScanner *scanner = [QRCodeScanner qrCodeScannerWithSuccess:^(QRCodeScanner *__weak scanner, NSString *content) {
        NSLog(@"扫描出的信息：%@", content);
        [scanner dismissViewControllerAnimated:YES completion:nil];
    } failtrue:^(QRCodeScanner *__weak scanner, NSError *error) {
        [scanner dismissViewControllerAnimated:YES completion:nil];
    } cancel:^(QRCodeScanner *__weak scanner) {
        [scanner dismissViewControllerAnimated:YES completion:nil];
    }];
    
    scanner.codeType = ScanCodeTypeBarCode;
    scanner.showMsg = @"将条形码置于框中，即可完成扫描";
    
    [self presentViewController:scanner animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end




