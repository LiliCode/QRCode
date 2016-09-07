//
//  QRCodeScanner.h
//  QRCode
//
//  Created by LiliEhuu on 16/9/6.
//  Copyright © 2016年 LiliEhuu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ScanCodeType)
{
    ScanCodeTypeQRCode, //使用二维码
    ScanCodeTypeBarCode //使用条形码
};

@class QRCodeScanner;

typedef void (^successUsingBlock)(__weak QRCodeScanner *scanner, NSString *content);
typedef void (^failtrueUsingBlock)(__weak QRCodeScanner *scanner, NSError *error);
typedef void (^cancelUsingBlock)(__weak QRCodeScanner *scanner);

@interface QRCodeScanner : UIViewController

@property (assign , nonatomic) ScanCodeType codeType;   //条码类型
@property (copy , nonatomic) NSString *showMsg;         //显示消息


/**
 *  创建二维码/条形码扫描器
 *
 *  @param successBlock  扫描成功回调
 *  @param failtrueBlock 扫描失败回调
 *  @param cancelBlock   取消扫描回调
 *
 *  @return 返回扫描器控制器
 */
+ (instancetype)qrCodeScannerWithSuccess:(successUsingBlock)successBlock failtrue:(failtrueUsingBlock)failtrueBlock cancel:(cancelUsingBlock)cancelBlock;


@end
