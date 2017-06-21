//
//  SCRefreshGifHeader.m
//  BantingAssistant
//
//  Created by 毛强 on 2016/12/22.
//  Copyright © 2016年 Sybercare. All rights reserved.
//

#import "SCRefreshGifHeader.h"

@implementation SCRefreshGifHeader

#pragma mark - 重写方法
#pragma mark 基本设置
- (void)prepare
{
    [super prepare];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=49; i++) {
        
        UIImage *image = [UIImage imageNamed:@"success"];
        [idleImages addObject:image];
        i =i+5;
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=49; i++) {
        
        UIImage *image = [UIImage imageNamed:@"success"];
        [refreshingImages addObject:image];
        i = i + 5;
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.hidden = YES;
}


@end
