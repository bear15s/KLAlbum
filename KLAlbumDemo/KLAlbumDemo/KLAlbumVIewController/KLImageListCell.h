//
//  PRImageListCell.h
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit.h>
#import "QMUIAsset+select.h"
@class KLImageListCell;
@protocol KLImageListCellDelegate<NSObject>
-(void)imageListCell:(KLImageListCell*)imageListCell didImageWithAsset:(QMUIAsset*)asset;
@end


@interface KLImageListCell : UICollectionViewCell
@property(nonatomic,strong)QMUIAsset* asset;
@property(nonatomic,strong)UIImageView* postImageView;
@property(weak,nonatomic)id<KLImageListCellDelegate>delegate;
@property (strong, nonatomic) UIButton *selNumBtn;
@property (strong, nonatomic) UIButton *maskBtn;
@property (strong, nonatomic) UILabel *durationLbl;
@property (assign, nonatomic) BOOL isSelected;
@end
