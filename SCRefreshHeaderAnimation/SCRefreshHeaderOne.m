//
//  SCRefreshHeader.m
//  Pods
//
//  Created by maoqiang on 2017/6/19.
//
//

#import "SCRefreshHeaderOne.h"

@implementation SCRefreshHeaderOne

- (void)prepare{
    [super prepare];
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.hidden = YES;
//    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"healthBg.jpg"]];
//    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"healthBg.jpg"]];
//    imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self addSubview:imageView];
}

-(SCAnimationView *)animationView{
    if (nil == _animationView) {
        _animationView = [[SCAnimationView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 30)*0.5, 15, 30, 30)];
        [self addSubview:_animationView];
    }
    return _animationView;
}

#pragma mark - 实现父类的方法
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
//    NSLog(@"pullingPercent = %f", pullingPercent);
    [self.animationView barColorWithProgressAnimation:pullingPercent];
}

- (void)placeSubviews
{
    [super placeSubviews];
//    self.mj_h = self.animationView.frame.size.height;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStatePulling) {
//        
    }else if(state == MJRefreshStateIdle){
        [self.animationView stopAnimation];
    }
}

@end
