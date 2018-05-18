//
//  PRAlbumListCell.m
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import "KLAlbumListCell.h"
@interface KLAlbumListCell()
@property(nonatomic , strong) UIView * separatorView;
@end
@implementation KLAlbumListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}



- (void)setupUI{
    self.backgroundColor = [UIColor blackColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.albumImgView = [[UIImageView alloc]init];
    self.albumImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.albumImgView.clipsToBounds = YES;
    [self.contentView addSubview:self.albumImgView];
    
    [self.albumImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
    }];
    
    self.albumNameLal = [[UILabel alloc]init];
    [self.contentView addSubview:self.albumNameLal];
    self.albumNameLal.textAlignment = NSTextAlignmentCenter;
//    self.albumNameLal.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    [self.albumNameLal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.albumImgView.mas_right).mas_offset(30);
    }];
    
    [self addSubview:self.separatorView];
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_offset(KScale(0.5));
    }];
}

-(UIView*)separatorView{
    if (_separatorView == nil) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = RGBHEXA(0x3a3a3a, 1);
    }
    return _separatorView;
}
@end
