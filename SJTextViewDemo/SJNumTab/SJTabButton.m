//
//  SJTabButton.m
//  SJNavigationBar
//
//  Created by shenj on 16/11/1.
//  Copyright © 2016年 shenj. All rights reserved.
//  下载地址：https://github.com/576410448/SJNumTabDmeo


#import "SJTabButton.h"

@interface SJTabButton ()

/** 断点值 */
@property (nonatomic, assign) CGFloat breakDistance;

/** 小圆 */
@property (nonatomic, strong) UIView *samllCircleView;

/** 按钮消失的动画图片组 */
@property (nonatomic, strong) NSMutableArray *images;

/** 绘制不规则图形 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGFloat kBtnWidth;

@property (nonatomic, assign) CGFloat kBtnHeigth;

@end

@implementation SJTabButton

- (void)layoutSubviews{
    
    // super layoutSubviews 必须调用
    [super layoutSubviews];
    
    [self loadConfig];
}

- (void)cancelTap:(BOOL)isCancel{
    self.userInteractionEnabled = isCancel;
}

#pragma mark - 懒加载
- (NSMutableArray *)images{
    
    if (_images == nil) {
        _images = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i]];
            [_images addObject:image];
        }
    }
    
    return _images;
}

- (CAShapeLayer *)shapeLayer{
    
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    
    return _shapeLayer;
}

- (UIView *)samllCircleView{
    
    if (!_samllCircleView) {
        _samllCircleView = [[UIView alloc] init];
        _samllCircleView.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:_samllCircleView belowSubview:self];
    }
    
    return _samllCircleView;
}

#pragma mark - 加载与配置
- (void)loadConfig{
    
    _kBtnWidth = self.frame.size.width;
    _kBtnHeigth = self.frame.size.height;
    
    // 取圆角度
    CGFloat cornerRadius = (_kBtnHeigth > _kBtnWidth ? _kBtnWidth / 2.0 : _kBtnHeigth / 2.0);
    // 取断点距
    _breakDistance = cornerRadius * 4;
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    
    CGRect samllCireleRect = CGRectMake(0, 0, cornerRadius * (2 - 0.5) , cornerRadius * (2 - 0.5));
    self.samllCircleView.bounds = samllCireleRect;
    _samllCircleView.center = self.center;
    _samllCircleView.layer.cornerRadius = _samllCircleView.bounds.size.width / 2.0;
    
    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGest:)];
    [self addGestureRecognizer:panGest];
    
    // UP调用
    [self addTarget:self action:@selector(btnRemoveClick) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(btnRemoveClick) forControlEvents:UIControlEventTouchUpOutside];
    
}

#pragma mark - 手势
- (void)panGest:(UIPanGestureRecognizer *)panGest
{
    [self.layer removeAnimationForKey:@"shake"];
    
    // 获取移动坐标
    CGPoint panPoint = [panGest translationInView:self];
    
    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    self.center = changeCenter;
    [panGest setTranslation:CGPointZero inView:self];
    
    //俩个圆的中心点之间的距离
    CGFloat dist = [self pointToPoitnDistanceWithPoint:self.center potintB:self.samllCircleView.center];
    
    if (dist < _breakDistance) {
        
        CGFloat cornerRadius = (_kBtnHeigth > _kBtnWidth ? _kBtnWidth / 2 : _kBtnHeigth / 2);
        CGFloat samllCrecleRadius = cornerRadius - dist / 10;
        _samllCircleView.bounds = CGRectMake(0, 0, samllCrecleRadius * (2 - 0.5), samllCrecleRadius * (2 - 0.5));
        _samllCircleView.layer.cornerRadius = _samllCircleView.bounds.size.width / 2;
        
        if (_samllCircleView.hidden == NO && dist > 0) {
            //画不规则矩形
            self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:_samllCircleView].CGPath;
        }
    } else {
        
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        
        self.samllCircleView.hidden = YES;
    }
    
    if (panGest.state == UIGestureRecognizerStateEnded) {
        
        if (dist > _breakDistance) {
            
            [self btnRemoveClick];
            
        } else {
            
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.samllCircleView.center;
            } completion:^(BOOL finished) {
                self.samllCircleView.hidden = NO;
            }];
        }
    }
}

#pragma mark - 俩个圆心之间的距离
- (CGFloat)pointToPoitnDistanceWithPoint:(CGPoint)pointA potintB:(CGPoint)pointB
{
    CGFloat offestX = pointA.x - pointB.x;
    CGFloat offestY = pointA.y - pointB.y;
    CGFloat dist = sqrtf(offestX * offestX + offestY * offestY);
    
    return dist;
}

- (void)killAll
{
    [self removeFromSuperview];
    [self.samllCircleView removeFromSuperview];
    self.samllCircleView = nil;
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
    
    if (_killBlock) {
        _killBlock();
    }
}

#pragma mark - 不规则路径
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView
{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    
    // 获取圆心距离
    CGFloat d = [self pointToPoitnDistanceWithPoint:self.samllCircleView.center potintB:self.center];
    CGFloat sinθ = (x2 - x1) / d;
    CGFloat cosθ = (y2 - y1) / d;
    
    // 根据小圆半径 动态改变大圆Layer所需半径 (因为tabBtn不是圆)
    CGFloat r1 = smallCirCleView.bounds.size.width / 2;
    CGFloat r22 = bigCirCleView.bounds.size.width / 2;
    CGFloat r2 = r1 + (r22 - r1)*fabs(cosθ);
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);

//    CGPoint pointC = CGPointMake(x2 + r2 , y2);
//    CGPoint pointD = CGPointMake(x2 - r2 , y2);
    
    CGPoint pointO = CGPointMake(x1 + (x2 - x1)/3.0, y1 + (y2 - y1)/3.0);
//    CGPoint pointQ = CGPointMake(pointB.x + (pointC.x - pointB.x)/2.0, pointB.y + (pointC.y - pointB.y)/2.0);
//    CGPoint pointP = CGPointMake(pointA.x + (pointD.x - pointA.x)/2.0, pointA.y + (pointD.y - pointA.y)/2.0);
//    
//    CGPoint pointQQ = CGPointMake(pointO.x + (pointQ.x - pointO.x)/((pow(100, d))), pointO.y - (pointO.y - pointQ.y)/((pow(100, d))));
//    CGPoint pointPP = CGPointMake(pointO.x - (pointO.x - pointP.x)/((pow(100, d))), pointO.y + (pointP.y - pointO.y)/((pow(100, d))));
    
    
    //    CGPoint pointQ = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    //    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    //    [path addLineToPoint:pointC];
    [path addQuadCurveToPoint:pointC controlPoint:pointO];
//    [path addCurveToPoint:pointC controlPoint1:pointB controlPoint2:pointQQ];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    //    [path addLineToPoint:pointA];
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
//    [path addCurveToPoint:pointA controlPoint1:pointD controlPoint2:pointPP];
    
    return path;
}

//float getQuadCurve(float d){
//
//
//
//}

#pragma mark - button消失动画
- (void)startDestroyAnimations
{
    UIImageView *ainmImageView = [[UIImageView alloc] initWithFrame:self.frame];
    ainmImageView.animationImages = self.images;
    ainmImageView.animationRepeatCount = 1;
    ainmImageView.animationDuration = 0.5;
    [ainmImageView startAnimating];
    
    [self.superview addSubview:ainmImageView];
}

- (void)btnRemoveClick
{
    [self startDestroyAnimations];
    [self killAll];
}

#pragma mark - 设置长按时候左右摇摆的动画
- (void)setHighlighted:(BOOL)highlighted
{
    [self.layer removeAnimationForKey:@"shake"];
    
    //长按左右晃动的幅度大小
    CGFloat shake = 5;
    
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
    keyAnim.keyPath = @"transform.translation.x";
    keyAnim.values = @[@(-shake), @(shake), @(-shake)];
    keyAnim.removedOnCompletion = NO;
    keyAnim.repeatCount = MAXFLOAT;
    //左右晃动一次的时间
    keyAnim.duration = 0.3;
    [self.layer addAnimation:keyAnim forKey:@"shake"];
    
    
}

@end
