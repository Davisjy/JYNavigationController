//
//  JYNavigationController.m
//  09-手势移除控制器
//
//  Created by qingyun on 15/12/9.
//  Copyright © 2015年 qingyun. All rights reserved.
//

#import "JYNavigationController.h"

@interface JYNavigationController ()
/** 存放每一个控制器的全屏截图*/
@property (nonatomic, strong) NSMutableArray  *images;
@property (nonatomic, strong) UIImageView *lastVCView;
@property (nonatomic, strong) UIView *cover;
@end

@implementation JYNavigationController

- (UIImageView *)lastVCView
{
    if (_lastVCView == nil) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIImageView *lastVCView = [[UIImageView alloc] init];
        
        lastVCView.frame = window.bounds;
        self.lastVCView = lastVCView;
    }
    return _lastVCView;
}

- (UIView *)cover
{
    if (_cover == nil) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        UIView *cover = [[UIView alloc] init];
        cover.frame = window.bounds;
        cover.backgroundColor = [UIColor grayColor];
        cover.alpha = 0.5;
        self.cover = cover;
    }
    return _cover;
}

- (NSMutableArray *)images
{
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 拖拽手势
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [self.view addGestureRecognizer:gesture];
}

- (void)dragging:(UIPanGestureRecognizer *)gesture
{
    // 如果只有一个子控制器，停止拖拽
    if (self.viewControllers.count <= 1) {
        return;
    }
    
    // 在x方向上移动多少距离
    CGFloat tx = [gesture translationInView:self.view].x;
    if (tx < 0) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        // 决定pop还是还原
        CGFloat x = self.view.frame.origin.x;
        if (x >= self.view.frame.size.width * 0.5) {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
            }completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                [self.lastVCView removeFromSuperview];
                [self.cover removeFromSuperview];
                // 这一步一定要执行，不然导航栏就被移到屏幕外了
                self.view.transform = CGAffineTransformIdentity;
                [self.images removeLastObject];
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformIdentity;
            }];
        }
        
    } else {
        // 移动view
        self.view.transform = CGAffineTransformMakeTranslation(tx, 0);
        
        // 添加截图到最后面
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        self.lastVCView.image = self.images[self.images.count - 2];
        [window insertSubview:self.lastVCView atIndex:0];
        
        // 添加self.cover在lastVCView之上
        [window insertSubview:self.cover aboveSubview:self.lastVCView];
    }
    
}

/**
 *  产生截图
 */
- (void)createScreenShot
{
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self.images addObject:image];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.images.count > 0) {
        return;
    }
    [self createScreenShot];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self createScreenShot];
}

@end
