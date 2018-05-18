//
//  NSObject+UIButton.m
//  esee
//
//  Created by Kowaii on 2018/4/18.
//  Copyright © 2018年 梁家伟. All rights reserved.
//

#import "UIButton+EnlargeTouchArea.h"
#import <objc/runtime.h>
@implementation UIButton (EnlargeTouchArea)


//static char topNameKey;
//static char rightNameKey;
//static char bottomNameKey;
//static char leftNameKey;

//- (void) setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left
//{
//    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
//    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
//    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
//    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (CGRect) enlargedRect
//{
//    NSNumber* topEdge = objc_getAssociatedObject(self, &topNameKey);
//    NSNumber* rightEdge = objc_getAssociatedObject(self, &rightNameKey);
//    NSNumber* bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
//    NSNumber* leftEdge = objc_getAssociatedObject(self, &leftNameKey);
//    if (topEdge && rightEdge && bottomEdge && leftEdge)
//    {
//        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
//                          self.bounds.origin.y - topEdge.floatValue,
//                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
//                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
//    }
//    else
//    {
//        return self.bounds;
//    }
//}
//
//- (UIView*) hitTest:(CGPoint) point withEvent:(UIEvent*) event
//{
//    CGRect rect = [self enlargedRect];
//    if (CGRectEqualToRect(rect, self.bounds))
//    {
//        return [super hitTest:point withEvent:event];
//    }
//    return CGRectContainsPoint(rect, point) ? self : nil;
//}
/*
Apple的iOS人机交互设计指南中指出，按钮点击热区应不小于44x44pt，否则这个按钮就会让用户觉得“很难用”，因为明明点击上去了，却没有任何响应。
但我们有时做自定义Button的时候，设计图上的给出按钮尺寸明显要小于这个数。例如我之前做过的自定义Slider上的Thumb只有12x12pt，做出来后我发现自己根本点不到按钮……
这个问题在WWDC 2012 Session 216视频中提到了一种解决方式。它重写了按钮中的pointInside方法，使得按钮热区不够44×44大小的先自动缩放到44×44，再判断触摸点是否在新的热区内。
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
