//
//  UIImage+image1.h
//  图片加载优化
//
//  Created by 陈孟迪 on 2021/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (image1)
-(UIImage*)resizeUI:(CGSize)size;
-(UIImage*)resizeCG:(CGSize)size;
- (UIImage*)resizeIO:(CGSize)size;
- (UIImage*)resizeCI:(CGSize)size;
- (UIImage*)resizeVI:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
