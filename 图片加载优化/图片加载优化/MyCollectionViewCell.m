//
//  MyCollectionViewCell.m
//  图片加载优化
//
//  Created by 陈孟迪 on 2021/7/14.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    self.imageView = [[UIImageView alloc]init];
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.layer.cornerRadius = 10;
    self.imageView.clipsToBounds = YES;
    
//    NSURL *photourl = [NSURL URLWithString:self.url];
//    UIImage *images = [UIImage imageWithData:[NSData dataWithContentsOfURL:photourl]];
    self.imageView.image = self.image;
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

//- (void)setUrl:(NSString *)url{
//    _url = url;
//    NSString *imageStr = [NSString stringWithFormat:@"%@?imageView2/1/w/200/h/200/q/75",self.url];
//    NSURL *photourl = [NSURL URLWithString:self.url];
//    UIImage *images = [UIImage imageWithData:[NSData dataWithContentsOfURL:photourl]];
//    CGSize size = CGSizeMake(images.size.width/10, images.size.height/10);
//    [images resizeUI:size];
//    [images resizeCG:size];
//    [images resizeIO:size];
//    [images resizeCI:size];
//    [images resizeVI:size];
//    self.imageView.image = images;
//}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}


@end
