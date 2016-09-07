//
//  ViewController.m
//  QRCode
//
//  Created by LiliEhuu on 16/9/6.
//  Copyright © 2016年 LiliEhuu. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeGenerator.h"

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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end




