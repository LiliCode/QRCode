//
//  QRCodeGenerator.m
//  QRCode
//
//  Created by LiliEhuu on 16/9/6.
//  Copyright © 2016年 LiliEhuu. All rights reserved.
//

#import "QRCodeGenerator.h"
#import <CoreImage/CoreImage.h>

@implementation QRCodeGenerator



/**
 *  创建二维码图片
 *
 *  @param qrString 二维码携带的信息
 *
 *  @return 返回CoreImage对象
 */
+ (CIImage *)createQRCodeForString:(NSString *)qrString
{
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    // 纠错级别
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];   //option 渲染方式：软件渲染
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}



/**
 *  生成普通二维码
 *
 *  @param string 二维码携带的信息
 *  @param size   二维码大小
 *
 *  @return 返回二维码图片
 */
+ (UIImage *)qrCodeImageForString:(NSString *)string imageSize:(CGFloat)size
{
    //创建二维码
    CIImage *qrCodeImage = [[self class] createQRCodeForString:string];
    //设置大小并返回
    return [[self class] createNonInterpolatedUIImageFormCIImage:qrCodeImage withSize:size];
}

/**
 *  基于普通二维码生成带头像的二维码
 *
 *  @param qrCode      普通的二维码
 *  @param avatarImage 头像
 *  @param avatarSize  头像大小
 *
 *  @return 返回带头像的二维码
 */
+ (UIImage *)qrCodeImage:(UIImage *)qrCode avatarImage:(UIImage *)avatarImage avatarSize:(CGSize)avatarSize
{
    CGSize size = qrCode.size;
    CGSize size2 =CGSizeMake(1.0 / 5.5 * size.width, 1.0 / 5.5 * size.height);
    //创建图形上下文
    UIGraphicsBeginImageContext(size);
    //将二维码绘制到画板
    [qrCode drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //将头像会知道画板
    [[self avatarImage:avatarImage avatarSize:avatarSize] drawInRect:CGRectMake((size.width - size2.width) / 2.0, (size.height - size2.height) / 2.0, size2.width, size2.height)];
    //获取画板上的图片
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    //停止绘制
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

/**
 *  直接生成带头像的二维码
 *
 *  @param string       文字信息
 *  @param imageSize    二维码大小
 *  @param avatarImage  头像图片
 *  @param avatarSize   头像在二维码中的大小
 *
 *  @return 返回带头像的二维码
 */
+ (UIImage *)qrCodeImageForString:(NSString *)string imageSize:(CGFloat)size avatarImage:(UIImage *)avatarImage avatarSize:(CGSize)avatarSize
{
    //生成普通二维码
    UIImage *qrCodeImage = [self.class qrCodeImageForString:string imageSize:size];
    return [self.class qrCodeImage:qrCodeImage avatarImage:avatarImage avatarSize:avatarSize];
}



/**
 *  生成一个带背景的头像
 */
+ (UIImage *)avatarImage:(UIImage *)avatarImage avatarSize:(CGSize)avatarSize
{
    //    UIImage *avatarBackgroudImage = [UIImage imageNamed:@"psb.png"];
    UIImage *avatarBackgroudImage = [self.class blankImage:avatarSize];
    
    CGSize size = avatarBackgroudImage.size;
    
    UIGraphicsBeginImageContext(size);
    
    //背景圆角
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(3, 3, size.width - 6, size.height - 6) cornerRadius:10];
    [backgroundPath addClip];//根据指定的图形进行剪切
    //画背景
    [avatarBackgroudImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    //头像圆角
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(6, 6, size.width - 12, size.height - 12) cornerRadius:10];
    [path addClip];//根据指定的图形进行剪切
    //画头像
    [avatarImage drawInRect:CGRectMake(5, 5, size.width - 10, size.height - 10)];
    
    
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}


/**
 *  生成头像的空白底图
 */
+ (UIImage *)blankImage:(CGSize)blankSize
{
    UIGraphicsBeginImageContextWithOptions(blankSize, YES, 0.0);
    //为了渲染成白色图片，借助view自身的颜色
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, blankSize.width, blankSize.height)];
    view.backgroundColor = [UIColor whiteColor];
    //渲染view
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //获取图片
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}


@end




