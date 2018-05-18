//
//  NSObject+QMUIAsset.m
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import "QMUIAsset+select.h"

static void * kUniqueID = (void *)@"QMUIAssetCategoryKey";

@implementation QMUIAsset (select)

- (BOOL)modelSelect{
    return [objc_getAssociatedObject(self, kUniqueID) boolValue];
}


- (void)setModelSelect:(BOOL)modelSelect{
    objc_setAssociatedObject(self, kUniqueID,  [NSNumber numberWithBool:modelSelect], OBJC_ASSOCIATION_ASSIGN);
}
@end
