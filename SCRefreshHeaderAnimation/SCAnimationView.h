//
//  SCAnimationView.h
//  SCAnimation
//
//  Created by maoqiang on 2017/6/16.
//  Copyright © 2017年 maoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCAnimationView : UIView
-(void)stopAnimation;
-(void)startAnimation;
-(void)pauseAnimation;
-(void)resumeAnimation;
-(void)barColorWithProgressAnimation:(CGFloat) progress;
@end
