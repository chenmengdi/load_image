//
//  UIImage+image1.m
//  图片加载优化
//
//  Created by 陈孟迪 on 2021/7/14.
//

#import "UIImage+image1.h"
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@implementation UIImage (image1)

//UIKit方式
-(UIImage*)resizeUI:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//CoreGraphics
-(UIImage*)resizeCG:(CGSize)size{
    CGImageRef cgImage = self.CGImage;
    if (cgImage == nil){
        return  nil;
    }
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), cgImage);
    CGImageRef bitmapImageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:bitmapImageRef scale:self.scale orientation:self.imageOrientation];
    return image;
}

//ImageIO
- (UIImage*)resizeIO:(CGSize)size{
    NSData *data = UIImagePNGRepresentation(self);
    if (data == nil){
        return nil;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, nil);
    if (imageSource == nil) {
        return nil;
    }
    CFDictionaryRef property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil);
    NSDictionary *propertys = CFBridgingRelease(property);
    CGFloat height = [propertys[@"PixelHeight"] integerValue]; //图像k宽高，12000
    CGFloat width = [propertys[@"PixelWidth"] integerValue];
    //以较大的边为基准
    int imageSize = (int)MAX(size.width, size.height);
    CFStringRef keys[5];
    CFTypeRef values[5];
    //创建缩略图等比缩放大小，会根据长宽值比较大的作为imageSize进行缩放
    //kCGImageSourceThumbnailMaxPixelSize为生成缩略图的大小。当设置为800，如果图片本身大于800*600，则生成后图片大小为800*600，如果源图片为700*500，则生成图片为800*500
    keys[0] = kCGImageSourceThumbnailMaxPixelSize;
    CFNumberRef thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    values[0] = (CFTypeRef)thumbnailSize;
    keys[1] = kCGImageSourceCreateThumbnailFromImageAlways;
    values[1] = (CFTypeRef)kCFBooleanTrue;
    keys[2] = kCGImageSourceCreateThumbnailWithTransform;
    values[2] = (CFTypeRef)kCFBooleanTrue;
    keys[3] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    values[3] = (CFTypeRef)kCFBooleanTrue;
    keys[4] = kCGImageSourceShouldCacheImmediately;
    values[4] = (CFTypeRef)kCFBooleanTrue;
    
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageRef thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    UIImage *resultImg = [UIImage imageWithCGImage:thumbnailImage];
    return resultImg;
}

//CoreImage
- (UIImage*)resizeCI:(CGSize)size{
    CGImageRef cgImage = self.CGImage;
    if (cgImage == nil){
        return  nil;
    }
    CIImage *ciImageInput = [CIImage imageWithCGImage:cgImage];
    double scale = size.width/self.size.height;
    CIFilter *filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [filter setValue:ciImageInput forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithDouble:scale] forKey:kCIInputScaleKey];
    [filter setValue:@(1.0) forKey:kCIInputAspectRatioKey];
    CIImage *ciImageOutput = [filter valueForKey:kCIOutputImageKey];
    if (!ciImageOutput) {
        return nil;
    }
    CIContext *ciContext = [[CIContext alloc] initWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CGImageRef ciImageRef = [ciContext createCGImage:ciImageOutput fromRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resultImg = [UIImage imageWithCGImage:ciImageRef];
    return  resultImg;
}

//vImage
- (UIImage*)resizeVI:(CGSize)size{
    CGImageRef cgImage = self.CGImage;
    if (cgImage == nil){
        return  nil;
    }

    vImage_CGImageFormat format;
    format.bitsPerComponent = 8;
    format.bitsPerPixel = 32; //ARGB四通道 4*8
    format.colorSpace = nil; //默认sRGB
    format.bitmapInfo = kCGImageAlphaFirst | kCGBitmapByteOrderDefault; // 表示ARGB
    format.version = 0;
    format.decode = nil; //默认色彩映射范围【0, 1.0】
    format.renderingIntent = kCGRenderingIntentDefault;//超出【0，1】范围后怎么处理
    //源图片buffer，输出图片buffer
    vImage_Buffer sourceBuffer, outputBuffer;
    vImage_Error error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, kvImageNoFlags);
    if (error != kvImageNoError) {
         return nil;
    }
    float scale = self.scale;
    int width = (int)size.width;
    int height = (int)size.height;
    int bytesPerPixel = (int)CGImageGetBitsPerPixel(cgImage)/8;
    //设置输出格式
    outputBuffer.width = width;
    outputBuffer.height = height;
    outputBuffer.rowBytes = bytesPerPixel * width;
    outputBuffer.data = malloc(outputBuffer.rowBytes * outputBuffer.height);
    //缩放到当前尺寸上
    error = vImageScale_ARGB8888(&sourceBuffer, &outputBuffer, nil, kvImageHighQualityResampling);
    if (error != kvImageNoError) {
          return nil;
    }
        
    CGImageRef outputImageRef = vImageCreateCGImageFromBuffer(&outputBuffer, &format, nil, nil, kvImageNoFlags, &error);
    UIImage *resultImg = [UIImage imageWithCGImage:outputImageRef];
    return  resultImg;
}

@end
