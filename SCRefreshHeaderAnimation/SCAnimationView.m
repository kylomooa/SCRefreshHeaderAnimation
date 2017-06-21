//
//  SCAnimationView.m
//  SCAnimation
//
//  Created by maoqiang on 2017/6/16.
//  Copyright © 2017年 maoqiang. All rights reserved.
//

#import "SCAnimationView.h"

typedef enum : NSUInteger {
    SCNormal = 0,
    SCAnimating = 1,
    SCPause = 2,
} SCAnimationStatus;

@interface CALayer(SCAction)
-(void)pauseAnimation;
@end

@implementation CALayer(SCAction)

-(void)pauseAnimation{
    CFTimeInterval pauseTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.timeOffset = pauseTime;
    self.speed = 0;
}

-(void)resumeAnimation{
    CFTimeInterval pauseTime = self.timeOffset;
    self.speed = 1;
    self.timeOffset = 0;
    self.beginTime = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
}

@end


@interface SCAnimationView ()
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineLength;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat interval;
@property (nonatomic, strong) NSArray *lineColors;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, assign) SCAnimationStatus status;

@end

@implementation SCAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

-(void)config{
    [self layoutIfNeeded];
    
    self.lineLength = fmax(self.frame.size.width, self.frame.size.height);
    self.lineWidth  = self.lineLength/6.0;
    self.margin     = self.lineLength/4.5 + self.lineWidth/2;
    self.duration = 2;
    self.interval = 1;
    [self lines];
    self.transform = CGAffineTransformRotate(self.transform, 0.25*M_PI);
}

-(UIBezierPath *)getLineWithIndex:(NSInteger) index{
       UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.lineLength*0.5, self.lineLength*0.5) radius:self.lineLength*0.5 startAngle:M_PI_2*(index-1) endAngle:index*M_PI_2 clockwise:YES];
    return path;
}

-(UIBezierPath *)getLineWithStartPath:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    return path;
}

-(void)angleAnimation{
    
    CABasicAnimation *angleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    angleAnimation.beginTime           = CACurrentMediaTime();
    angleAnimation.fromValue           = @(-0.25*M_PI);
    angleAnimation.toValue             = @(3.75*M_PI);
    angleAnimation.fillMode            = kCAFillModeForwards;
    angleAnimation.removedOnCompletion = false;
    angleAnimation.duration            = self.duration;
    angleAnimation.repeatCount = MAXFLOAT;
    
    [self.layer addAnimation:angleAnimation forKey:@"angleAnimation"];
}

-(void)lineAnimationOne{
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    lineAnimation.beginTime           = CACurrentMediaTime();
    lineAnimation.fromValue           = @(1);
    lineAnimation.toValue             = @(0);
    lineAnimation.fillMode            = kCAFillModeForwards;
    lineAnimation.removedOnCompletion = false;
    lineAnimation.duration            = self.duration/4;
    
    [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        [lineLayer addAnimation:lineAnimation forKey:@"lineAnimationOne"];
    }];
}

-(void)lineAnimationTwo{
    [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *keyPath = @"transform.translation.x";
        if (idx%2 == 1) {
            keyPath = @"transform.translation.y";
        }
        CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
        lineAnimation.beginTime           = CACurrentMediaTime() + self.duration/4;
        lineAnimation.fromValue           = @(0);
        lineAnimation.autoreverses        = YES;
        lineAnimation.fillMode            = kCAFillModeForwards;
        lineAnimation.removedOnCompletion = false;
        lineAnimation.duration            = self.duration/4;
        lineAnimation.repeatCount = MAXFLOAT;
        
        if (idx < 2) {
            lineAnimation.toValue = @(self.lineLength/4);
        }else{
            lineAnimation.toValue = @(-self.lineLength/4);
        }
        
        [lineLayer addAnimation:lineAnimation forKey:@"lineAnimationTwo"];
    }];
    
    CGFloat scale = (self.lineLength - 2*self.margin)/(self.lineLength - self.lineWidth);
    [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *keyPath = @"transform.translation.y";
        if (idx%2 == 1) {
            keyPath = @"transform.translation.x";
        }
        CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
        lineAnimation.beginTime           = CACurrentMediaTime() + self.duration/4;
        lineAnimation.fromValue           = @(0);
        lineAnimation.autoreverses        = YES;
        lineAnimation.fillMode            = kCAFillModeForwards;
        lineAnimation.removedOnCompletion = false;
        lineAnimation.duration            = self.duration/4;
        lineAnimation.repeatCount = MAXFLOAT;
        
        if (idx == 0 || idx == 3) {
            lineAnimation.toValue = @(self.lineLength/4*scale);
        }else{
            lineAnimation.toValue = @(-self.lineLength/4*scale);
        }
        [lineLayer addAnimation:lineAnimation forKey:@"lineAnimationThree"];
    }];
}

-(void)lineAnimationThree{
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    lineAnimation.beginTime           = CACurrentMediaTime();//+self.duration
    lineAnimation.fromValue           = @(0);
    lineAnimation.toValue             = @(1);
    lineAnimation.fillMode            = kCAFillModeForwards;
    lineAnimation.removedOnCompletion = false;
    lineAnimation.duration            = self.duration/4;
    [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 3) {
        }
        [lineLayer addAnimation:lineAnimation forKey:@"lineAnimationFour"];
    }];
}

-(void)barColorWithProgressAnimation:(CGFloat) progress;{

    if (self.status != SCAnimating) {
        if (progress <= 0.01) {
            [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *shapeLayer, NSUInteger idx, BOOL * _Nonnull stop) {
                shapeLayer.strokeEnd = 0;
            }];
        }
        if (progress <= 1) {
            if (progress>=0 && progress <= 0.25) {
                CAShapeLayer *layer0 = self.lines[0];
                layer0.strokeEnd = progress * 4;
                CAShapeLayer *layer1 = self.lines[1];
                layer1.strokeEnd = 0;
                CAShapeLayer *layer2 = self.lines[2];
                layer2.strokeEnd = 0;
                CAShapeLayer *layer3 = self.lines[3];
                layer3.strokeEnd = 0;
                
            }else if (progress >= 0.25 && progress <= 0.5){
                CAShapeLayer *layer0 = self.lines[0];
                layer0.strokeEnd = 1;
                CAShapeLayer *layer1 = self.lines[1];
                layer1.strokeEnd = (progress-0.25) * 4;
                CAShapeLayer *layer2 = self.lines[2];
                layer2.strokeEnd = 0;
                CAShapeLayer *layer3 = self.lines[3];
                layer3.strokeEnd = 0;
                
            }else if (progress >= 0.5 && progress <= 0.75){
                CAShapeLayer *layer0 = self.lines[0];
                layer0.strokeEnd = 1;
                CAShapeLayer *layer1 = self.lines[1];
                layer1.strokeEnd = 1;
                CAShapeLayer *layer2 = self.lines[2];
                layer2.strokeEnd = (progress-0.5) * 4;
                CAShapeLayer *layer3 = self.lines[3];
                layer3.strokeEnd = 0;
                
            }else if (progress >= 0.75 && progress <= 1){
                CAShapeLayer *layer0 = self.lines[0];
                layer0.strokeEnd = 1;
                CAShapeLayer *layer1 = self.lines[1];
                layer1.strokeEnd = 1;
                CAShapeLayer *layer2 = self.lines[2];
                layer2.strokeEnd = 1;
                CAShapeLayer *layer3 = self.lines[3];
                layer3.strokeEnd = (progress-0.75) * 4;
            }
        }else{
            [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *shapeLayer, NSUInteger idx, BOOL * _Nonnull stop) {
                shapeLayer.strokeStart = 0;
                shapeLayer.strokeEnd = 1;
            }];
            [self startAnimation];
        }
    }
}

-(void)startAnimation{
   
    self.status = SCAnimating;
    [self angleAnimation];
    [self lineAnimationOne];
    [self lineAnimationTwo];
}

-(void)pauseAnimation{
    [self.layer pauseAnimation];
    [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        [lineLayer pauseAnimation];
    }];
    self.status = SCPause;
}

-(void)resumeAnimation{
    [self.layer resumeAnimation];
    [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        [lineLayer resumeAnimation];
    }];
    self.status = SCAnimating;
}
-(void)stopAnimation{
    
    if (self.status == SCAnimating) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
                [lineLayer removeAnimationForKey:@"lineAnimationOne"];
                [lineLayer removeAnimationForKey:@"lineAnimationTwo"];
                [lineLayer removeAnimationForKey:@"lineAnimationThree"];
            }];
            [self.layer removeAnimationForKey:@"angleAnimation"];
            [self lineAnimationThree];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.lines enumerateObjectsUsingBlock:^(CAShapeLayer *lineLayer, NSUInteger idx, BOOL * _Nonnull stop) {
                    [lineLayer removeAnimationForKey:@"lineAnimationFour"];
                }];
            });
            self.status = SCNormal;
        });
    }
}

//CAAnimationDelegate
//-(void)animationDidStart:(CAAnimation *)anim{
//    CABasicAnimation *animation = (CABasicAnimation *)anim;
//    if ([animation.keyPath isEqualToString:@"transform.rotation.z"]) {
//        self.status = SCAnimating;
//    }
//}
//
//-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    CABasicAnimation *animation = (CABasicAnimation *)anim;
//    if ([animation.keyPath isEqualToString:@"strokeEnd"]) {
//        if (flag) {
//            self.status = SCNormal;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval*0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (self.status != SCAnimating) {
////                    [self startAnimation];
//                }
//            });
//        }
//    }
//}

//懒加载
-(NSArray *)lineColors{
    if (nil == _lineColors) {
        _lineColors = @[WEBRBGCOLOR(0x9DD4E9), WEBRBGCOLOR(0xF5BD58), WEBRBGCOLOR(0xFF317E), WEBRBGCOLOR(0x6FC9B5)];
    }
    return _lineColors;
}

-(NSMutableArray *)lines{
    if (nil == _lines) {
        
        _lines = [NSMutableArray array];
//        CGPoint pointOneStart = CGPointMake(self.lineWidth/2, self.margin);
//        CGPoint pointOneEnd = CGPointMake(self.lineLength - self.lineWidth/2, self.margin);
//        
//        CGPoint pointTwoStart = CGPointMake(self.lineLength - self.margin, self.lineWidth/2);
//        CGPoint pointTwoEnd = CGPointMake(self.lineLength - self.margin, self.lineLength - self.lineWidth/2);
//        
//        CGPoint pointThreeStart = CGPointMake(self.lineLength - self.lineWidth/2, self.lineLength - self.margin);
//        CGPoint pointThreeEnd = CGPointMake(self.lineWidth/2, self.lineLength - self.margin);
//        
//        CGPoint pointFourStart = CGPointMake(self.margin, self.lineLength - self.lineWidth/2);
//        CGPoint pointFourEnd = CGPointMake(self.margin, self.lineWidth/2);
        
        CGPoint pointOneStart = CGPointMake(0, 0);
        CGPoint pointOneEnd = CGPointMake(self.lineLength, 0);
        
        CGPoint pointTwoStart = CGPointMake(self.lineLength, 0);
        CGPoint pointTwoEnd = CGPointMake(self.lineLength,self.lineLength);
        
        CGPoint pointThreeStart = CGPointMake(self.lineLength, self.lineLength);
        CGPoint pointThreeEnd = CGPointMake(0, self.lineLength);
        
        CGPoint pointFourStart = CGPointMake(0, self.lineLength);
        CGPoint pointFourEnd = CGPointMake(0, 0);
        
        NSArray *pointStart = @[
                                [NSValue valueWithCGPoint:pointOneStart],
                                [NSValue valueWithCGPoint:pointTwoStart],
                                [NSValue valueWithCGPoint:pointThreeStart],
                                [NSValue valueWithCGPoint:pointFourStart],
                                ];
        
        NSArray *pointEnd = @[
                                [NSValue valueWithCGPoint:pointOneEnd],
                                [NSValue valueWithCGPoint:pointTwoEnd],
                                [NSValue valueWithCGPoint:pointThreeEnd],
                                [NSValue valueWithCGPoint:pointFourEnd],
                                ];
        
        for (int i = 0; i < 4; i++) {
            CAShapeLayer *line = [[CAShapeLayer alloc]init];
            line.lineWidth = self.lineWidth;
            line.lineCap = kCALineCapRound;
            line.strokeStart = 0;
            line.strokeEnd = 0;
            line.opacity = 0.8;
            line.fillColor = BACKGROUND_COLOR.CGColor;
            UIColor *color = self.lineColors[i];
            line.strokeColor = color.CGColor;
//            UIBezierPath *path = [self getLineWithStartPath:[pointStart[i] CGPointValue] endPoint:[pointEnd[i] CGPointValue]];
            UIBezierPath *path = [self getLineWithIndex:i];
            line.path = path.CGPath;
            [self.layer addSublayer:line];
            [_lines addObject:line];
        }
    }
    return _lines;
}

@end
