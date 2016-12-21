//
//  SJTextBar.m
//  SJTextTools
//
//  Created by shenj on 16/11/17.
//  Copyright © 2016年 shenj. All rights reserved.
//

# define kBarBtnW  MAIN_WIDTH/6.0

#import "SJTextBar.h"

static NSInteger const kTextBarBtnTag = 100;
static NSInteger const kAttributesBtnTag = 110;
static NSInteger const kAddSomethingBtnTag = 120;
static NSInteger const kBarBtnH = 50;

typedef NS_ENUM(NSInteger, textFontType) {
    textFontTypeMax      = 22,
    textFontTypeMid      = 20,
    textFontTypeDefault  = 17,
};

@interface SJTextBar ()

@property (nonatomic ,strong) UIView *attributesView;

@property (nonatomic ,strong) UIView *addSomethingView;

@end
/**   œ∑®†¥øπ¬˚∆˙©ƒ∂ßå≈ç√∫µ≤≤≥÷…æπ“‘«	`¡™£¢∞§¶•ªº–≠   */
@implementation SJTextBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(0, MAIN_HEIGHT, MAIN_WIDTH, kBarBtnH)];
    if (self) {
        
        [self createBarBtn];
        
        [self attributesUIconfig];
        
        [self addSomeStingUIconfig];
        
        /**
         * 注册通知，监听键盘的弹出和收回
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textBarWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textBarWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - textBarUI
- (void) createBarBtn {
    
    NSArray *images = @[@"keyboard", @"undo", @"restore", @"attributes", @"add", @"more"];
    
    for (NSInteger i = 0; i < images.count; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        
        btn.tag   = kTextBarBtnTag + i;
        btn.frame = CGRectMake(kBarBtnW * i, 0, kBarBtnW, kBarBtnH);
        btn.backgroundColor = [UIColor colorWithRed:0.93f green:0.93f blue:0.93f alpha:1.00f];
        btn.selected = NO;
        
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(barButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}

#pragma mark - textBarEvent
- (void)barButtonAction:(UIButton *)sender {
    
    NSInteger index = sender.tag - kTextBarBtnTag;
    
    switch (index) {
        case 0:
        {
            // 隐藏键盘
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
            UIButton *btn = (UIButton *)[self viewWithTag:kTextBarBtnTag+3];
            btn.selected = NO;
        }
            break;
        case 1:
        {
            // 撤销
            [self undo];
        }
            break;
        case 2:
        {
            // 恢复
            [self restore];
        }
            break;
        case 3:
        {
            // attribures
            sender.selected = !sender.selected;
            _attributesView.hidden = !sender.selected;
            
            UIButton *btn = [self viewWithTag:kTextBarBtnTag+4];
            btn.selected = NO;
            _addSomethingView.hidden = YES;
            
        }
            break;
        case 4:
        {
            // 添加
            sender.selected = !sender.selected;
            _addSomethingView.hidden = !sender.selected;
            
            UIButton *btn = [self viewWithTag:kTextBarBtnTag+3];
            btn.selected = NO;
            _attributesView.hidden = YES;
        }
            break;
        case 5:
        {
            // 更多
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - AddUI
- (void)addSomeStingUIconfig {
    
    CGFloat btnW = 70;
    CGFloat btnH = 40;
    
    NSArray *items = @[@"photos", @"link", @"sepLine"];
    NSArray *titles = @[@"照片", @"链接", @"分割线"];
    
    _addSomethingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnW*items.count, btnH)];
    [self addSubview:_addSomethingView];
    
    _addSomethingView.backgroundColor = [UIColor blackColor];
    _addSomethingView.layer.cornerRadius = 8;
    _addSomethingView.hidden = YES;
    _addSomethingView.center = CGPointMake(kBarBtnW*9/2.0, -20);
    
    CGFloat sub = (kBarBtnW*9/2.0 + btnW*items.count/2.0)-(MAIN_WIDTH-10);
    
    if (sub > 0) {
        _addSomethingView.center = CGPointMake(kBarBtnW*9/2.0-sub, -20);
        [self createAngelwithSuperView:_addSomethingView
                            angelPoint:CGPointMake(_addSomethingView.frame.size.width/2.0+sub, 50)];
        
    }else{
        [self createAngelwithSuperView:_addSomethingView
                            angelPoint:CGPointMake(_addSomethingView.frame.size.width/2.0, 50)];
    }
    
    
    
    for (NSInteger i = 0; i < items.count; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addSomethingView addSubview:btn];
        
        btn.backgroundColor = [UIColor blackColor];
        btn.tag = kAddSomethingBtnTag + i;
        btn.frame = CGRectMake(btnW * i, 0, btnW, btnH);
        btn.selected = NO;
        btn.layer.cornerRadius = 8;
        btn.clipsToBounds = YES;
        
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImage *image = [self changeImage:[UIImage imageNamed:items[i]] withColor:[UIColor whiteColor]];
        [btn setImage:image forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(addSomethingChoose:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
}

#pragma mark - AddEnent
- (void)addSomethingChoose:(UIButton *)sender {
    
    NSInteger index = sender.tag - kAddSomethingBtnTag;
    
    switch (index) {
        case 0:
        {
            [self addImageAction];// 添加图片
        }
            break;
        case 1:
        {
            [self linkAction];// 添加链接
        }
            break;
        case 2:
        {
            [self addSepLineAction];// 添加分割线
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - AttributesUI
- (void)attributesUIconfig {
    
    CGFloat btnWH = 40;
    
    NSArray *items = @[@"bold", @"oblique", @"centerLine", @"underLine", @"H1", @"H2", @"H3"];
    
    _attributesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btnWH * items.count, btnWH)];
    [self addSubview:_attributesView];
    
    _attributesView.backgroundColor = [UIColor blackColor];
    _attributesView.layer.cornerRadius = 8;
    _attributesView.hidden = YES;
    _attributesView.center = CGPointMake(kBarBtnW*7/2.0, -20);
    
    CGFloat sub = (kBarBtnW*7/2.0 + btnWH*items.count/2.0)-(MAIN_WIDTH-10);
    
    if (sub > 0) {
        _attributesView.center = CGPointMake(kBarBtnW*7/2.0-sub, -20);
        [self createAngelwithSuperView:_attributesView
                            angelPoint:CGPointMake(_attributesView.frame.size.width/2.0+sub, 50)];
        
    }else{
        [self createAngelwithSuperView:_attributesView
                            angelPoint:CGPointMake(_attributesView.frame.size.width/2.0, 50)];
    }
    
    for (NSInteger i = 0; i < items.count; i ++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_attributesView addSubview:btn];
        
        btn.backgroundColor = [UIColor blackColor];
        btn.tag = kAttributesBtnTag + i;
        btn.frame = CGRectMake(btnWH * i, 0, btnWH, btnWH);
        btn.selected = NO;
        btn.layer.cornerRadius = 8;
        btn.clipsToBounds = YES;
        
        if (i > 3) {
            [btn setTitle:items[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:20-2*(i-2)];
        }else{
            UIImage *image = [self changeImage:[UIImage imageNamed:items[i]] withColor:[UIColor whiteColor]];
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        [btn addTarget:self action:@selector(attributesChoose:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 6) {
            btn.selected = YES;
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }
        
    }
}

#pragma mark - AttributesEvent
- (void)attributesChoose:(UIButton *)sender {
    
    NSInteger index = sender.tag - kAttributesBtnTag;
    
    switch (index) {
        case 0:
        {
            [self changToBoldAction:sender];// 加粗
        }
            break;
        case 1:
        {
            [self changToObliqueAction:sender];// 斜体
        }
            break;
        case 2:
        {
            [self changToCenterLineAction:sender];// 中划线
        }
            break;
        case 3:
        {
            [self changToUnderLineAction:sender];// 下划线
        }
            break;
        case 4:
        {
            [self chooseFontAction:sender];// 大
        }
            break;
        case 5:
        {
            [self chooseFontAction:sender];// 中
        }
            break;
        case 6:
        {
            [self chooseFontAction:sender];// 小
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark -AngelLayer
- (void)createAngelwithSuperView:(UIView *)superView angelPoint:(CGPoint)point {
    
    CGPoint pointA = point;
    CGPoint pointB = CGPointMake(point.x-10, point.y - 10);
    CGPoint pointC = CGPointMake(point.x+10, point.y - 10);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor blackColor].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    
    // BC
    [path addLineToPoint:pointC];
    
    // CA
    [path addLineToPoint:pointA];
    
    layer.path = path.CGPath;
    
    [superView.layer addSublayer:layer];
    
}

#pragma mark Block
- (void)chooseFontAction:(UIButton *)sender{
    
    for (NSInteger i = 4; i <= 6; i ++) {
        UIButton *btn = (UIButton *)[self viewWithTag:kAttributesBtnTag + i];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.selected = NO;
    }
    
    sender.selected = YES;
    [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    NSInteger index = sender.tag - kAttributesBtnTag;
    CGFloat font = textFontTypeDefault;
    
    switch (index) {
        case 4:
        {
            font = textFontTypeMax;
        }
            break;
        case 5:
        {
            font = textFontTypeMid;
        }
            break;
        case 6:
        {
            font = textFontTypeDefault;
        }
            break;
            
        default:
            break;
    }
    
    if (_textFontBlock) {
        _textFontBlock(font);
    }
    
}

- (void)changToBoldAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor orangeColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }else{
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor whiteColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }
    
    if (_changeToBoldBlock) {
        _changeToBoldBlock(sender.selected);
    }
}

- (void)changToCenterLineAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor orangeColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }else{
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor whiteColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }
    
    if (_changeToCenterLineBlock) {
        _changeToCenterLineBlock(sender.selected);
    }
}

- (void)changToUnderLineAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor orangeColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }else{
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor whiteColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }
    
    if (_changeToUnderLineBlock) {
        _changeToUnderLineBlock(sender.selected);
    }
    
}

- (void)changToObliqueAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor orangeColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }else{
        UIImage *image = [self changeImage:sender.imageView.image withColor:[UIColor whiteColor]];
        [sender setImage:image forState:UIControlStateNormal];
    }
    
    if (_changeToObliqueBlock) {
        _changeToObliqueBlock(sender.selected);
    }
}

- (void)addImageAction{
    
    if (_addImageBlock) {
        _addImageBlock();
    }
}

- (void)addSepLineAction {
    
    if (_sepLineBlock) {
        _sepLineBlock();
    }
    
}

- (void)linkAction{
    
    if (_linkBlock) {
        _linkBlock();
    }
}

- (void)undo{
    if (_undoBlock) {
        _undoBlock();
    }
}

- (void)restore{
    if (_restoreBlock) {
        _restoreBlock();
    }
}

#pragma mark textBar 跟随键盘

- (void) textBarWillShow:(NSNotification *)note {
        
    // 获取键盘的位置和大小
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.superview convertRect:keyboardBounds toView:nil];
    
    // 获取输入框的位置和大小
    CGRect containerFrame = self.frame;
    // 计算出输入框的y坐标
    containerFrame.origin.y = self.superview.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    // 动画改变位置
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        // 更改输入框的位置
        self.frame = containerFrame;
        
    }];
    
}

- (void) textBarWillHide:(NSNotification *)note {
    
    UIButton *attBtn = (UIButton *)[self viewWithTag:kTextBarBtnTag+3];
    attBtn.selected = NO;
    _attributesView.hidden = YES;
    
    UIButton *addBtn = [self viewWithTag:kTextBarBtnTag + 4];
    addBtn.selected = NO;
    _addSomethingView.hidden = YES;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // 获取输入框的位置和大小
    CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.bounds.size.height - containerFrame.size.height + self.frame.size.height;
    
    // 动画改变位置
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        // 更改输入框的位置
        self.frame = containerFrame;
        
    }];
    
}

#pragma mark changeImageColor
- (UIImage *)changeImage:(UIImage *)image withColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [color setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
    
}

#pragma mark 响应超出self范围的event事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            
            @autoreleasepool {
                
                CGPoint p = [subView convertPoint:point fromView:self];
                
                if (CGRectContainsPoint(subView.bounds, p) && subView.hidden == NO) {
                    
                    for (UIView *sub in subView.subviews) {
                        
                        @autoreleasepool {
                            
                            CGPoint q = [sub convertPoint:p fromView:subView];
                            
                            if (CGRectContainsPoint(sub.bounds, q)) {
                                
                                view = sub;
                                break;
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    return view;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    
}

@end
