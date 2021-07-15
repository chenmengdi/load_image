//
//  MyTableViewCell.m
//  图片加载优化
//
//  Created by 陈孟迪 on 2021/7/14.
//

#import "MyTableViewCell.h"
#import "MyCollectionViewCell.h"

@interface MyTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching>
@property(nonatomic,strong)UICollectionView *myCollectionView;
@property(nonatomic,strong)UICollectionViewFlowLayout *myFlowLayout;
@property(nonatomic, strong) NSMutableDictionary *imgs;
@property(nonatomic, strong) NSMutableArray *imgURLArray;
@property(nonatomic, strong) NSMutableDictionary *tasks;

@end
@implementation MyTableViewCell
{
    UIView *topView;
    UIView *bottomView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
    }
    return self;
}

-(NSMutableDictionary *)imgs{
    if (_imgs == nil) {
        _imgs = [NSMutableDictionary dictionary];
    }
    return _imgs;
}

-(NSMutableArray *)imgURLArray{
    
    if (_imgURLArray == nil) {
        _imgURLArray = [NSMutableArray array];
    }
    return _imgURLArray;
}

-(NSMutableDictionary *)tasks{
    if (_tasks == nil) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

-(CGFloat)getCellHeight{
    int number = (int)ceilf(self.imgURLArray.count/3);
    if (self.imgURLArray.count < 3){
        number = 1;
    }
    return 90 + number * ((kWidth-10*5)/3) + 20 + (number-1)*10;
}

- (void)createUI{
    
    topView = [[UIView alloc]init];
    topView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(@(60));
    }];
    
    self.myFlowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.myFlowLayout.footerReferenceSize = CGSizeZero;
    self.myFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 0) collectionViewLayout:self.myFlowLayout];
    self.myCollectionView.delegate = self;
    self.myCollectionView.dataSource = self;
    self.myCollectionView.prefetchDataSource = self;
    self.myCollectionView.scrollEnabled = NO;
    self.myCollectionView.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:self.myCollectionView];
    
    [self.myCollectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    
    [self.myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(topView.mas_bottom);
        make.bottom.equalTo(self.contentView).mas_offset(@(-30));
    }];
    
    bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.myCollectionView.mas_bottom);
        make.height.mas_equalTo(@(30));
    }];
    
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    for (NSIndexPath *indexPath in indexPaths) {
        NSURL *currentURL = [NSURL URLWithString:[self.imgURLArray objectAtIndex:indexPath.row]];
        if (!self.imgs[currentURL]) {
            [self update:indexPath];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
    for (NSIndexPath * indexPath in indexPaths){
        NSURL *currentURL = [NSURL URLWithString:[self.imgURLArray objectAtIndex:indexPath.row]];
        if (self.tasks[currentURL]) {
            dispatch_queue_t queue = self.tasks[currentURL];
            dispatch_suspend(queue);
            self.tasks[currentURL] = nil;
        }
    }
    
}

-(void)update:(NSIndexPath *)indexPath{
    NSURL *currentURL = [NSURL URLWithString:[self.imgURLArray objectAtIndex:indexPath.row]];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self) weakSelf = self;
    
    //异步下载图片
    dispatch_async(queue, ^{
        UIImage *images = [UIImage imageWithData:[NSData dataWithContentsOfURL:currentURL]];
        CGSize size = CGSizeMake(images.size.width/10, images.size.height/10);
        [images resizeCG:size];
        weakSelf.imgs[currentURL] = images;
        
        //更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            MyCollectionViewCell *cell = (MyCollectionViewCell *)[weakSelf.myCollectionView cellForItemAtIndexPath:indexPath];
            cell.image = images;
        });
    });
    self.tasks[currentURL] = queue;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"numberOfItemsInSection");
    return self.imgURLArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSLog(@"numberOfSectionsInCollectionView");
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForItemAtIndexPath");
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    // 获取URL
    NSURL *imgURL = [NSURL URLWithString:self.imgURLArray[indexPath.row]];
    
    if (self.imgs[imgURL]) {
        cell.image = self.imgs[imgURL];
    }else{
        [self update:indexPath];
    }
    
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake( 10, 10, 10, 10);//分别为上、左、下、右
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake((kWidth-20-10*3)/3, (kWidth-10*5)/3);
    return size;
}

- (void)setImageModel:(ImageModel *)imageModel{
    _imageModel = imageModel;
    
    self.imgURLArray = [imageModel.imageArry mutableCopy];
    [self.myCollectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
