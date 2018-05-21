//
//  PRImageListCell.m
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import "KLImageListCell.h"
#import "UIButton+EnlargeTouchArea.h"

@interface KLImageListCell()

//@property(nonatomic,strong)UIButton* checkButton;
@property(nonatomic,strong)UIImageView* videoIcon;
@property(nonatomic,strong)UIView* bottomView;
@end

@implementation KLImageListCell



- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self setupUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setupUI{
    self.postImageView = [[UIImageView alloc]init];
    self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.postImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.postImageView];
    [self.contentView addSubview:self.bottomView];
    [self.contentView addSubview:self.selNumBtn];
    [self.bottomView addSubview:self.videoIcon];
    [self.bottomView addSubview:self.durationLbl];
    [self.contentView addSubview:self.maskBtn];
    
    if(self.asset.assetType == QMUIAssetTypeImage){
        [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
   
    if(self.asset.assetType == QMUIAssetTypeVideo){
        [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.edges.equalTo(self).mas_offset(UIEdgeInsetsMake(0, 0, 17, 0));
        }];
    }
    
    self.bottomView.hidden = YES;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(17);
    }];
    
    [self.videoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(8);
        make.centerY.equalTo(self.bottomView);
        make.width.height.mas_equalTo(17);
    }];
    
    [self.durationLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-8);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setAsset:(QMUIAsset *)asset{
    _asset = asset;
    self.maskBtn.hidden = YES;
    self.bottomView.hidden = !(_asset.assetType == QMUIAssetTypeVideo);
    if(_asset.assetType == QMUIAssetTypeVideo){
        self.maskBtn.hidden = NO;
        NSUInteger time = round(_asset.duration);
        NSUInteger mins = time / 60;
        NSUInteger sec = time % 60;
        self.durationLbl.text = [NSString stringWithFormat:@"%zd:%02zd",mins,sec];
        [self.postImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).mas_offset(UIEdgeInsetsMake(0, 0, 17, 0));
        }];
        self.bottomView.hidden = NO;
    }
    
    if(_asset.assetType == QMUIAssetTypeImage || asset == nil){
        
        [self.postImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        self.bottomView.hidden = YES;
    }
}


-(UIButton*)selNumBtn{
    if (_selNumBtn == nil) {
        _selNumBtn = [[UIButton alloc]init];
        [_selNumBtn setBackgroundImage:[UIImage imageNamed:@"imageCellNormal"] forState:UIControlStateNormal];
        [_selNumBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
        [_selNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selNumBtn.titleLabel setFont:[UIFont systemFontOfSize:12.5]];
//        _selNumBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_selNumBtn];
        [self.contentView bringSubviewToFront:_selNumBtn];
    }
    return _selNumBtn;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected) {
        [self.selNumBtn setBackgroundImage:[UIImage imageNamed:@"imageCellSel"]  forState:UIControlStateNormal];
    }else{
        [self.selNumBtn setBackgroundImage:[UIImage imageNamed:@"imageCellNormal"] forState:UIControlStateNormal];
    }
}

- (void)selectImage:(UIButton*)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(imageListCell:didImageWithAsset:)]){
        [self.delegate imageListCell:self didImageWithAsset:self.asset];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.selNumBtn.frame = CGRectMake(KScale(4), KScale(4), KScale(22), KScale(22));
}


- (UILabel *)durationLbl{
    if(!_durationLbl){
        _durationLbl = [[UILabel alloc]init];
        _durationLbl.font = [UIFont systemFontOfSize:12.5];
        _durationLbl.textColor = [UIColor whiteColor];
        _durationLbl.text = @"0:00";
        _durationLbl.font = [UIFont boldSystemFontOfSize:11];
        _durationLbl.textColor = [UIColor whiteColor];
        _durationLbl.textAlignment = NSTextAlignmentRight;
    }
    return _durationLbl;
}

- (UIImageView *)videoIcon{
    if(!_videoIcon){
        _videoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 17, 17)];
        [_videoIcon setImage:[UIImage imageNamed:@"VideoSendIcon"]];
    }
    return _videoIcon;
}


- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

-(UIButton*)maskBtn{
    if (_maskBtn == nil) {
        _maskBtn = [[UIButton alloc]init];
        _maskBtn.hidden = YES;
        _maskBtn.userInteractionEnabled = NO;
        _maskBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    }
    return _maskBtn;
}
//- (void)setAsset:(QMUIAsset *)asset{
//    self.postImageView.image = [asset requestThumbnailImageWithSize:<#(CGSize)#> completion:^(UIImage *result, NSDictionary<NSString *,id> *info) {
//        
//    }];
//}

@end
