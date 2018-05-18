//
//  PRAlbumViewController.m
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import "KLAlbumViewController.h"
#import <Masonry.h>
#import "KLImageListCell.h"
#import "KLAlbumListCell.h"

#define KLColumCount 4
#define KLItemMargin 4
static  NSString  * const KLImageListCellIdentifier = @"KLImageListCell";
static  NSString  * const KLAlbumCellIdentifier = @"KLAlbumCell";
@interface KLAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,KLImageListCellDelegate>
/**
 多媒体类型
 */
@property(nonatomic,assign)KLAlbumContentType contentType;
/**
 可选最大数量
 */
@property(nonatomic,assign)NSUInteger maxCount;
/**
 如果是选择视频，视频最短的时长
 */

/**navigation上的相册选取按钮*/
@property(nonatomic , strong) UIButton * navgationBtn;
/**tableView底层的遮罩*/
@property(nonatomic , strong) UIButton * tableViewMaskBtn;
@property(nonatomic , strong) UIButton * multipleChoiceBtn;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UICollectionViewFlowLayout* layout;
@property(nonatomic,assign)CGFloat minVideoDuration;
@property(nonatomic,strong)UICollectionView* imageListView;
@property(nonatomic,strong)NSMutableArray* cellArray;
@end

@implementation KLAlbumViewController{
    NSUInteger _currentAlbumIndex;
}


- (instancetype)initWithContentType:(KLAlbumContentType)contentType SelectMaxCount:(NSUInteger)maxCount MinVideoDuration:(CGFloat)minVideoDuration IsMutiChoice:(BOOL)isMutiChoice{
    if(self = [super init] ){
        _contentType = contentType;
        _maxCount = maxCount;
        _mutiChoiceMode = isMutiChoice;
        _minVideoDuration = minVideoDuration;
        _albumsArray = [NSMutableArray array];
        _imagesAssetArray = [NSMutableArray array];
        _selectedImageAssetArray = [NSMutableArray array];
        _cellArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
//    [self requestFromAuthorization];
    
    [self setupUI];
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"dissmiss"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]style:UIBarButtonItemStyleDone target:self action:@selector(exitAlbum)];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
    UIButton* selBtn = [[UIButton alloc]init];
    [selBtn addTarget:self action:@selector(navgationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [selBtn setTitle:@"相册选取" forState:UIControlStateNormal];
    self.navgationBtn = selBtn;
    [self.navgationBtn setImage:[UIImage imageNamed:@"xiasanjiao"] forState:UIControlStateNormal];
    [self.navgationBtn setImage:[UIImage imageNamed:@"shangsanjiao"] forState:UIControlStateSelected];
    [self.navgationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navgationBtn.frame=CGRectMake(20, 20, 150, 40);
    self.navigationItem.titleView = self.navgationBtn;
}

#pragma - mark 导航条点击事件
-(void)exitAlbum{
//     [[NSNotificationCenter defaultCenter]postNotificationName:shredVCDissmiss object:self];
    if(self.delegate  && [self.delegate respondsToSelector:@selector(imagePickerControllerDidCancelSelectImageFromSource:)]){
        [self.delegate imagePickerControllerDidCancelSelectImageFromSource:AssetSourcePhotos];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)navgationBtnClick:(UIButton*)sender{
    [self.view bringSubviewToFront:_tableViewMaskBtn];
    if (self.navgationBtn.selected == YES) {
        [self hiddenAlbumTableView];
        return;
    }else{
        self.navgationBtn.selected = YES;
        [self.tableView reloadData];
        _tableViewMaskBtn.frame = CGRectMake(0, 0, KScreenWidth,KScreenHeight );
        [UIView animateWithDuration:0.3 animations:^{
            _tableView.frame = CGRectMake(0, 0, KScreenWidth,KScale(256) );
        } completion:^(BOOL finished) {
            [self.view bringSubviewToFront:self.tableViewMaskBtn];
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark ui相关

- (void)setupUI{
    self.view.backgroundColor = [UIColor blackColor];
    [self initDropDownList];
    [self initImageList];
    [self getAlbumData];
    self.currentGroup = self.albumsArray.firstObject;
    [self initSelImgCountBtn];
}


- (void)initImageList{
    CGFloat margin = 2;
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    CGFloat itemWH = (self.view.bounds.size.width - (KLColumCount-1) * margin)  / KLColumCount;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    self.layout = layout;
    
    UICollectionView* imageListView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:imageListView];
    [imageListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    imageListView.delegate = self;
    imageListView.dataSource = self;
    imageListView.showsHorizontalScrollIndicator = NO;
    imageListView.showsVerticalScrollIndicator = NO;
    imageListView.scrollsToTop = NO;
    imageListView.delaysContentTouches = NO;
    imageListView.decelerationRate = UIScrollViewDecelerationRateFast;
    imageListView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    [imageListView registerClass:[KLImageListCell class] forCellWithReuseIdentifier:KLImageListCellIdentifier];
    self.imageListView = imageListView;
}


- (void)initSelImgCountBtn{
    [self.view addSubview:self.multipleChoiceBtn];
    [self.multipleChoiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        [make centerX];
        make.bottom.equalTo(self.view).offset(-45);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    [self.multipleChoiceBtn setTitle:[NSString stringWithFormat:@"%zd/%zd",self.selectedImageAssetArray.count,self.maxCount] forState:UIControlStateNormal];
    self.multipleChoiceBtn.hidden = !self.mutiChoiceMode;
}


- (void)initDropDownList{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 70;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = RGBHEXA(0x0f0f0f, 1);
//        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounces = NO;
        
        [_tableView registerClass:[KLAlbumListCell class] forCellReuseIdentifier:KLAlbumCellIdentifier];
        [self.view addSubview:self.tableViewMaskBtn];
        [self.tableViewMaskBtn addSubview:self.tableView];
        self.tableViewMaskBtn.frame = CGRectMake(0, -KScreenHeight, KScreenWidth, KScreenHeight);
        _tableView.frame = CGRectMake(0, -KScale(256), KScreenWidth,KScale(388) );
    }
}


-(UIButton*)tableViewMaskBtn{
    if (_tableViewMaskBtn == nil) {
        _tableViewMaskBtn = [[UIButton alloc]init];
        _tableViewMaskBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [_tableViewMaskBtn addTarget:self action:@selector(hiddenAlbumTableView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tableViewMaskBtn;
}


-(UIButton*)multipleChoiceBtn{
    if (_multipleChoiceBtn == nil) {
        _multipleChoiceBtn = [[UIButton alloc]init];
        [_multipleChoiceBtn setBackgroundImage:[UIImage imageNamed:@"photos_multiple_choice_white"] forState:UIControlStateNormal];
        [_multipleChoiceBtn setBackgroundImage:[UIImage imageNamed:@"photos_multiple_choice_red"] forState:UIControlStateSelected];
        [_multipleChoiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_multipleChoiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _multipleChoiceBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_multipleChoiceBtn addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_multipleChoiceBtn setTitle:@"确定" forState:UIControlStateSelected];
        [self.view addSubview:_multipleChoiceBtn];
    }
    return _multipleChoiceBtn;
}

-(void)hiddenAlbumTableView{
    self.navgationBtn.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.userInteractionEnabled = NO;
        _tableView.frame = CGRectMake(0, -KScale(388), KScreenWidth,KScale(388));
    } completion:^(BOOL finished) {
        self.tableView.userInteractionEnabled = YES;
        self.tableViewMaskBtn.frame = CGRectMake(0, -KScreenHeight, KScreenWidth,KScreenHeight );
    }];
}

#pragma - mark   UICollectionViewDelegate & UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.imagesAssetArray.count == 0 ?  0 : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.showTakePhotoBtn){
        return self.imagesAssetArray.count+1;
    }else{
        return self.imagesAssetArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    

    
    KLImageListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:KLImageListCellIdentifier forIndexPath:indexPath];
    QMUIAsset *imageAsset = nil;
    if(self.showTakePhotoBtn && indexPath.item == 0){
        //第一个按钮，显示为拍照按钮
        cell.postImageView.image = [UIImage imageNamed:@"assetCameraImg"];
        cell.selNumBtn.hidden = YES;
        cell.maskBtn.hidden = NO;
        cell.asset = imageAsset;
        
        
    }else{
        
        if(self.showTakePhotoBtn){
            imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item-1];
        }else{
            imageAsset =  [self.imagesAssetArray objectAtIndex:indexPath.item];
        }
        cell.asset = imageAsset;
//        cell.backgroundColor = RGBARandom;
        cell.delegate = self;
        cell.selNumBtn.hidden = !self.mutiChoiceMode;
        
        
        if([self array:self.selectedImageAssetArray isContainAsset:imageAsset]){
            imageAsset.modelSelect = YES;
        }
        
        if(cell.asset.modelSelect){
            NSUInteger index = [self indexOfAsset:imageAsset InArray:self.selectedImageAssetArray]+1;
            [cell.selNumBtn setTitle:@(index).description forState:UIControlStateNormal];
            cell.isSelected = YES;
        }else{
            cell.isSelected = NO;
            [cell.selNumBtn setTitle:nil forState:UIControlStateNormal];
        }
        
        if(imageAsset.assetType == QMUIAssetTypeVideo && self.minVideoDuration > 0){
            cell.maskBtn.hidden = imageAsset.duration >= self.minVideoDuration;
        }

        // 异步请求资源对应的缩略图
        [imageAsset requestThumbnailImageWithSize:self.layout.itemSize completion:^(UIImage *result, NSDictionary *info) {
            if (!info || [[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                // 模糊，此时为同步调用
                cell.postImageView.image = result;
            }
            //        else if ([collectionView qmui_itemVisibleAtIndexPath:indexPath]) {
            //            // 清晰，此时为异步调用
            //            KLImageListCell * anotherCell = (KLImageListCell *)[collectionView cellForItemAtIndexPath:indexPath];
            //            anotherCell.postImageView.image = result;
            //        }
        }];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    KLImageListCell* imageCell = (KLImageListCell*)cell;
//    [imageCell setSelected:NO];
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.mutiChoiceMode){
        if(indexPath.item == 0){
 
            if(self.contentType ==  KLAlbumContentTypeOnlyPhoto){
                //拍照
                
                NSLog(@"拍照");
                //录像
                if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:SelectCameraCellFromSource:)]){
                    [self.delegate imagePickerController:self SelectCameraCellFromSource:AssetSourceCameraImage];
                }
                
            
            }else{
                //录像
                 NSLog(@"录像");
                if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:SelectCameraCellFromSource:)]){
                    [self.delegate imagePickerController:self SelectCameraCellFromSource:AssetSourceCameraVideo];
                }
            }

         
        }else{
            //单选，直接调用完成选择
            QMUIAsset* asset = self.imagesAssetArray[indexPath.item-1];
            if(asset.assetType == QMUIAssetTypeVideo && asset.duration < self.minVideoDuration){
                return;
            }
            if(self.delegate && [self.delegate  respondsToSelector:@selector(imagePickerController:didSelectImageWithImagesAsset:FromSource:)]){
                [self.delegate imagePickerController:self didSelectImageWithImagesAsset:asset FromSource:AssetSourcePhotos];
            }
        }
    }
}

#pragma - mark KLImageListCellDelegate

- (void)imageListCell:(KLImageListCell *)imageListCell didImageWithAsset:(QMUIAsset *)asset{
//    QMUIAsset* asset = self.imagesAssetArray[indexPath.row];
//    if(!self.multipleChoiceBtn){
//
//        //单选，直接调用完成选择
//        if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectImageWithImagesAsset:)]){
//            [self.delegate imagePickerController:self didSelectImageWithImagesAsset:asset];
//        }
//        return;
//    }
    
    NSIndexPath* removeIndex = nil;
    //多选
    if(self.selectedImageAssetArray.count == self.maxCount){//达到选择上限
        if([self array:self.selectedImageAssetArray isContainAsset:asset]){
            removeIndex = [NSIndexPath indexPathForRow:[self indexOfAsset:asset InArray:self.imagesAssetArray] inSection:0];
            [self.selectedImageAssetArray removeObject:asset];
            [self.cellArray addObject:imageListCell];
            asset.modelSelect = NO;
        }else{
            return;
        }
        
    }else{//未达到上限，可继续选
        if([self array:self.selectedImageAssetArray isContainAsset:asset]){//移除选项
            [self.selectedImageAssetArray removeObject:asset];
             [self.cellArray removeObject:imageListCell];
            asset.modelSelect = NO;
            removeIndex = [NSIndexPath indexPathForRow:[self indexOfAsset:asset InArray:self.imagesAssetArray] inSection:0];
        }else{//添加选择
            [self.selectedImageAssetArray addObject:asset];
             [self.cellArray addObject:imageListCell];
            asset.modelSelect = YES;
        }
    }
    
    //移除选项，删除显中效果
    if(removeIndex) {
        [imageListCell.selNumBtn setTitle:@"" forState:UIControlStateNormal];
        [imageListCell setIsSelected:NO];
    }
    
    //被选中的图片
    for (QMUIAsset* selAsset in self.selectedImageAssetArray) {
        selAsset.modelSelect = YES;
    }
    
    //只有在可见区域才设置选中效果，否则会因为复用问题导致ui混乱
    NSArray<KLImageListCell*>* visibleCells = [self.imageListView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(KLImageListCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([self.selectedImageAssetArray containsObject:obj.asset]){
            NSUInteger index = [self indexOfAsset:obj.asset InArray:self.selectedImageAssetArray]+1;
            [obj.selNumBtn setTitle:@(index).description forState:UIControlStateNormal];
            [obj setIsSelected:YES];
        }
    }];

    [self.multipleChoiceBtn setTitle:[NSString stringWithFormat:@"%zd/%zd",self.selectedImageAssetArray.count,self.maxCount] forState:UIControlStateNormal];
    self.multipleChoiceBtn.selected = self.selectedImageAssetArray.count == self.maxCount?YES:NO;
}


#pragma - mark  UITableViewDelegate & UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KLAlbumListCell* albumCell = [tableView dequeueReusableCellWithIdentifier:KLAlbumCellIdentifier forIndexPath:indexPath];
    QMUIAssetsGroup* assetGroup = self.albumsArray[indexPath.row];
    albumCell.imageView.image = [assetGroup posterImageWithSize:CGSizeMake(64, 64)];
//    albumCell.backgroundColor = RGBARandom;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:assetGroup.name attributes:@{NSForegroundColorAttributeName:RGBHEXA(0xffffff, 1)}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",[assetGroup numberOfAssets]] attributes:@{NSForegroundColorAttributeName:RGBHEXA(0xffffff, 0.5)}];
    [nameString appendAttributedString:countString];
    albumCell.albumNameLal.attributedText = nameString;
    return albumCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentAlbumIndex = indexPath.row;
    [self getAlbumData];
//    [self hiddenAlbumTableView];
    if(self.albumsArray.count > 0){
        self.currentGroup = self.albumsArray[_currentAlbumIndex];
    }
}


#pragma - mark 业务函数

- (void)refreshAlbumView {
    [self getAlbumData];
}

- (BOOL)array:(NSMutableArray<QMUIAsset*>*)array isContainAsset:(QMUIAsset*)asset{
    BOOL result = NO;
    
    for (QMUIAsset* arrayAsset in array) {
        result = [arrayAsset.identifier isEqualToString:asset.identifier];
        if(result) break;
    }
    
    return result;
}


- (NSUInteger)indexOfAsset:(QMUIAsset*)asset InArray:(NSMutableArray<QMUIAsset*>*)array {
    NSUInteger index = 0;
    
    for (NSUInteger i = 0; i<array.count; i++) {
        QMUIAsset* enumrateAsset = array[i];
        if([asset.identifier isEqualToString:enumrateAsset.identifier]){
            index = i;
            break;
        }
    }
    
    return index;
}


- (void)doneButtonClick{
    //单选，直接调用完成选择
    if(self.selectedImageAssetArray.count < self.maxCount){
        return;
    }
    
    
    if(_mutiChoiceMode){
        if(self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectImageWithImagesAssets:)]){
            [self.delegate imagePickerController:self didSelectImageWithImagesAssets:self.selectedImageAssetArray];
        }
    }
}


- (void)requestFromAuthorization{
    [QMUIAssetsManager  requestAuthorization:^(QMUIAssetAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == QMUIAssetAuthorizationStatusAuthorized) {
                
            } else {
                
            }
        });
    }];
}

- (void)getAlbumData{
    __weak typeof(self)weakSelf = self;
    [self.albumsArray removeAllObjects];
    [[QMUIAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:self.contentType usingBlock:^(QMUIAssetsGroup *resultAssetsGroup) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 这里需要对 UI 进行操作，因此放回主线程处理
            if (resultAssetsGroup) {
                [weakSelf.albumsArray addObject:resultAssetsGroup];
            } else {//遍历完毕 传入空
                
                [weakSelf refreshCurrentAlbum];
            }
        });
    }];
}

- (void)refreshCurrentAlbum{
    [self.imagesAssetArray removeAllObjects];
    if(self.albumsArray.count > 0){
        QMUIAssetsGroup* assetGroup = self.albumsArray[_currentAlbumIndex];
        [assetGroup enumerateAssetsWithOptions:QMUIAlbumSortTypeReverse usingBlock:^(QMUIAsset *resultAsset) {
            if(resultAsset){
                [self.imagesAssetArray addObject:resultAsset];
            }else{
                [self.imageListView reloadData];
                [self hiddenAlbumTableView];
            }
        }];
    }
}


@end
