//
//  QRCodeGenerator.h
//  QRCode
//
//  Created by LiliEhuu on 16/9/6.
//  Copyright © 2016年 LiliEhuu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface QRCodeGenerator : NSObject

/**
 *  生成普通二维码
 *
 *  @param string 二维码携带的信息
 *  @param size   二维码大小
 *
 *  @return 返回二维码图片
 */
+ (UIImage *)qrCodeImageForString:(NSString *)string imageSize:(CGFloat)size;

/**
 *  基于普通二维码生成带头像的二维码
 *
 *  @param qrCode      普通的二维码
 *  @param avatarImage 头像
 *  @param avatarSize  头像大小
 *
 *  @return 返回带头像的二维码
 */
+ (UIImage *)qrCodeImage:(UIImage *)qrCode avatarImage:(UIImage *)avatarImage avatarSize:(CGSize)avatarSize;

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
+ (UIImage *)qrCodeImageForString:(NSString *)string imageSize:(CGFloat)size avatarImage:(UIImage *)avatarImage avatarSize:(CGSize)avatarSize;


@end




