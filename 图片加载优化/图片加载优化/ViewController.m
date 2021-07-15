//
//  ViewController.m
//  图片加载优化
//
//  Created by 陈孟迪 on 2021/7/14.
//

#import "ViewController.h"
#import "MyTableViewCell.h"
#import "ImageModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)NSMutableArray *randomArr;
@property(nonatomic,strong)NSArray *arr;
@end
@implementation ViewController
{
    int _size;
    int _currentPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片";
    _size = 5;
    _currentPage = 0;
    self.arr = @[
        @"https://c-ssl.duitang.com/uploads/item/201812/30/20181230144326_yzofb.jpg",
        @"https://c-ssl.duitang.com/uploads/item/201412/01/20141201173308_skFWP.png",
        @"https://b-ssl.duitang.com/uploads/item/201501/29/20150129123814_2ct8w.thumb.700_0.jpeg",
        @"http://img.mp.sohu.com/q_mini,c_zoom,w_640/upload/20170709/bc9dc6ef05624777b5ac4705c3ece08a_th.jpg",
        @"https://b-ssl.duitang.com/uploads/item/201505/09/20150509155448_5kd2X.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201707/27/20170727150703_x4KGT.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201808/12/20180812192736_buqos.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201805/26/20180526103125_lfcft.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201901/04/20190104094406_mknrj.jpg",
        @"https://c-ssl.duitang.com/uploads/item/202002/23/20200223210119_xcmyb.jpg",
        @"https://c-ssl.duitang.com/uploads/item/201409/03/20140903184335_Ae4Nn.jpeg",
        @"https://b-ssl.duitang.com/uploads/item/201510/24/20151024100416_KSwyi.thumb.700_0.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201602/22/20160222200524_iFfWr.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201507/11/20150711014653_nGczP.png",
        @"https://c-ssl.duitang.com/uploads/item/201506/11/20150611095643_wJGVd.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201607/12/20160712155653_mwWKB.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201605/27/20160527231822_iTtwu.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201610/14/20161014222256_HUPYe.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201601/13/20160113212708_QYFxX.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/202006/19/20200619190208_ddbjg.jpg",
        @"https://c-ssl.duitang.com/uploads/item/201504/14/20150414H5624_Th2cu.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201411/22/20141122143424_NZYmt.png",
        @"https://c-ssl.duitang.com/uploads/item/201802/13/20180213122737_Pdthy.thumb.1000_0.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201812/01/20181201170431_dsgtd.jpg",
        @"https://c-ssl.duitang.com/uploads/item/201703/02/20170302215050_nKaTw.jpeg",
        @"https://c-ssl.duitang.com/uploads/blog/202105/13/20210513185629_d2d84.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201808/22/20180822114709_nvNKc.jpeg",
        @"https://c-ssl.duitang.com/uploads/blog/202103/03/20210303111543_c4499.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/202005/23/20200523195248_yyzvs.jpg",
        @"https://c-ssl.duitang.com/uploads/item/202005/21/20200521203450_oowhb.jpeg",
        @"https://c-ssl.duitang.com/uploads/blog/202011/30/20201130184425_3bc2d.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201609/17/20160917121450_a4ECL.jpeg",
        @"https://c-ssl.duitang.com/uploads/blog/202011/27/20201127013951_10a9d.jpg",
        @"https://c-ssl.duitang.com/uploads/blog/202009/10/20200910063447_nEwvy.jpeg",
        @"https://c-ssl.duitang.com/uploads/item/201812/01/20181201032810_fJS4P.jpeg"];
    [self createUI];
    
}

- (void)loadData:(BOOL)isRefresh{
    if (_currentPage == 0) {
        [self.dataArr removeAllObjects];
    }
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i < _size; i++) {
        int y = (arc4random() % 8) + 2;
        [self getDifferentRandomWithNum:y];
        NSMutableArray *aa = [NSMutableArray array];
        for (int i = 0; i < self.randomArr.count; i++) {
            int index = [[NSString stringWithFormat:@"%@",self.randomArr[i]] intValue];
            [aa addObject:self.arr[index]];
        }
        ImageModel *imageModel = [[ImageModel alloc]init];
        imageModel.imageArry = aa;
        [list addObject:imageModel];
    }
    if (isRefresh == YES){
        [self.myTableView.mj_header endRefreshing];
    }
    [self.myTableView.mj_footer endRefreshing];
    [self.dataArr addObjectsFromArray:list];
    [self.myTableView reloadData];
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil){
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)createUI{
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.estimatedRowHeight = 100;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:self.myTableView];
    
    self.myTableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        self->_currentPage = 0;
        [self loadData:YES];
    }];
    
    self.myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self->_currentPage += 1;
        [self loadData:NO];
    }];
    [self loadData:NO];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil){
        cell = [[MyTableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
    }
    ImageModel *model = self.dataArr[indexPath.row];
    cell.imageModel = model;

    [cell layoutIfNeeded];
    if (model.cellHeight <= 0) {
        model.cellHeight = [cell getCellHeight];
        [self.dataArr replaceObjectAtIndex:indexPath.row withObject:model];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageModel *model = self.dataArr[indexPath.row];
    return model.cellHeight;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return  0;
}

-(NSMutableArray *)getDifferentRandomWithNum:(NSInteger )num{
    self.randomArr = [NSMutableArray array];
    
    NSInteger random;
    
    for (;;) {
        
        
        random=arc4random_uniform(self.arr.count-1);
        
        
        if(self.randomArr.count==0){
            [self.randomArr addObject:[NSNumber numberWithInteger:random]];
            
            
            
            continue;//进行下一次循环
            
            
            
        }
        
        
        
        BOOL isHave=[self.randomArr containsObject:[NSNumber numberWithInteger:random]];//判断数组中有没有
        
        if(isHave){
            
            
            continue;
            
        }
        
        [self.randomArr addObject:[NSNumber numberWithInteger:random]];
        
        if(self.randomArr.count==num){
            return self.randomArr;
        }
    }//self.randomArr是存储随机数的数组，如果是在按钮点击是获取随机数，在按钮点击的开始就要把数组清空，防止连续数组内容叠加
    
}
@end
