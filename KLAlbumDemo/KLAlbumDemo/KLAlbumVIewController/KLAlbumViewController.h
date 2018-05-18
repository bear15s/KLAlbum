//
//  PRAlbumViewController.h
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMUIKit.h>
#import "QMUIAsset+select.h"

/// 相册展示内容的类型
typedef NS_ENUM(NSUInteger, KLAlbumContentType) {
    KLAlbumContentTypeAll,                                  // 展示所有资源
    KLAlbumContentTypeOnlyPhoto,                            // 只展示照片
    KLAlbumContentTypeOnlyVideo,                            // 只展示视频
    KLAlbumContentTypeOnlyAudio                             // 只展示音频
};

typedef enum : NSUInteger {
    AssetSourcePhotos = 1, //资源来自于相册
    AssetSourceCameraImage = 2, //资源来自于相机拍照
    AssetSourceCameraVideo = 3, //资源来自于相机录像
} AssetSource;


@class KLAlbumViewController;
@protocol KLAlbumViewControllerDelegate<NSObject>
@optional
- (void)imagePickerController:(KLAlbumViewController *)imagePickerController didSelectImageWithImagesAsset:(QMUIAsset *)imageAsset FromSource:(AssetSource)assetFrom;
- (void)imagePickerController:(KLAlbumViewController *)imagePickerController didSelectImageWithImagesAssets:(NSMutableArray<QMUIAsset *> *)imagesAssetArray;
- (void)imagePickerControllerDidCancelSelectImageFromSource:(AssetSource)assetFrom;
- (void)imagePickerController:(KLAlbumViewController *)imagePickerController SelectCameraCellFromSource:(AssetSource)assetFrom;
@end



@interface KLAlbumViewController : UIViewController

/// 由于组件需要通过本地图片的 QMUIAsset 对象读取图片的详细信息，因此这里的需要传入的是包含一个或多个 QMUIAsset 对象的数组
@property(nonatomic, strong) NSMutableArray<QMUIAsset *> *imagesAssetArray;
@property(nonatomic, strong) NSMutableArray<QMUIAsset *> *selectedImageAssetArray;
@property(nonatomic, strong) NSMutableArray<QMUIAssetsGroup *> *albumsArray;
@property(nonatomic,weak)id<KLAlbumViewControllerDelegate>delegate;
@property(nonatomic,assign)BOOL mutiChoiceMode;
@property(nonatomic,assign)BOOL showTakePhotoBtn;
@property(nonatomic,assign)CGFloat scaleHeightWidth;
@property(nonatomic,strong)QMUIAssetsGroup* currentGroup;
/**
 初始化相册方法

 @param contentType 多媒体类型
 @param maxCount 最多可选数量
 @return 实例
 */
- (instancetype)initWithContentType:(KLAlbumContentType)contentType SelectMaxCount:(NSUInteger)maxCount MinVideoDuration:(CGFloat)minVideoDuration IsMutiChoice:(BOOL)isMutiChoice;

- (void)refreshAlbumView;

@end
