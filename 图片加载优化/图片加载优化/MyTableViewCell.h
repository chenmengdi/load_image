//
//  MyTableViewCell.h
//  图片加载优化
//
//  Created by 陈孟迪 on 2021/7/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyTableViewCell : UITableViewCell

@property (nonatomic,strong)ImageModel *imageModel;

-(CGFloat)getCellHeight;
@end

NS_ASSUME_NONNULL_END
