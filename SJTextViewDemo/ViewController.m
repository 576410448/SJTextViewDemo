//
//  ViewController.m
//  SJTextViewDemo
//
//  Created by shenj on 16/11/22.
//  Copyright © 2016年 shenj. All rights reserved.
//
//  SJTextview superView

#import "ViewController.h"
#import "PreViewController.h"

#import "SJTextView.h"
#import "SJTextBar.h"

#import "SJTextHeader.h"
#import "SJTextManager.h"
#import "SJCacheManager.h"
#import "SJAllArrayManager.h"


#define CoreDataManager [SJCacheManager coreDataManager]
#define textManager [SJTextManager managerWithSelectedRange:[_textView selectedRange]]
#define allArrayManeger [SJAllArrayManager allArrayManager]

@interface ViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic ,strong) SJTextView *textView;

@property (nonatomic ,strong) SJTextBar *textBar;

// 导航栏下划线
@property (nonatomic ,strong) UIImageView *navBarHairlineImageView;

// 临时变量 存储调取的图片
@property (nonatomic ,strong) UIImage *image;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navBarHairlineImageView.hidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    _navBarHairlineImageView.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.automaticallyAdjustsScrollViewInsets = NO; 
    
    if (!_coredataModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self prepareData];
        });
    }
    
    [self uiConfig];
}

- (void)prepareData{
    
    // 取缓存数据
    NSArray *modelArr = [CoreDataManager showAllObjInCoreData];
    
    if (modelArr.count != 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"草稿" preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (SJCacheModel *model in modelArr) {
            
            NSString *title;
            
            if (model.title) {
                title = model.title;
                
            }else{
                
                NSDate *date = model.time;
                //用于格式化NSDate对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设置格式：zzz表示时区
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                //设置时区
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                //NSDate转NSString
                title = [dateFormatter stringFromDate:date];
            }
            
            UIAlertAction *takeAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _coredataModel = model;
                [self reloadData];
            }];
            
            [alert addAction:takeAction];
            
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}

- (void)reloadData {
    if (_coredataModel) {
        
        // 显示
        NSAttributedString *attStr = [CoreDataManager changeToAttributeStringByData:_coredataModel.attributeText];
        [_textView showAttbuteText:attStr withLocation:attStr.length];
        
        // 更新当前数据源（images links）
        textManager.linkDicArr = [NSMutableArray arrayWithArray:[CoreDataManager changeToArrayByData:_coredataModel.links]];
        textManager.imageDicArr = [NSMutableArray arrayWithArray:[CoreDataManager changeToArrayByData:_coredataModel.images]];
        
        // 更新大数据源 (实时数据源 数组)
        NSDictionary *allArrDic = @{kAllArrayTextKey:attStr,
                                    kAllArrayLinksKey:textManager.linkDicArr,
                                    kAllArrayImagesKey:textManager.imageDicArr};
        
        allArrayManeger.allArray = [[NSMutableArray alloc] initWithObjects:allArrDic, nil].mutableCopy;
    }
}

- (void)uiConfig{
        
    [self naviBarConfig];

    [self textViewConfig];
    
    [self textBarConfig];
    
    [self reloadData];
    
}

- (void) naviBarConfig {
    
    _navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(giveUp)];
    
    //右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(showText)];
    
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)giveUp {
    
    @SJWeakObj(self);
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (_coredataModel) {
            
            if (sjWeakself.textView.attributedText.length == 0) {
                // 删除草稿
                [CoreDataManager deleteFromeCoreData:_coredataModel];
            }else{
                // 修改草稿
                [CoreDataManager saveCoreData:_textView.attributedText links:textManager.linkDicArr images:textManager.imageDicArr time:_coredataModel.time];
            }
            
        }else{
            
            if (sjWeakself.textView.attributedText.length != 0) {
                
                // 存草稿
                [CoreDataManager saveCoreData:_textView.attributedText links:textManager.linkDicArr images:textManager.imageDicArr time:nil];
            }
            
        }
        
    }];
    
}

- (void)showText {
    
    // 预览
    PreViewController *preVC = [[PreViewController alloc] init];
    preVC.attriButeText = _textView.attributedText;
    preVC.images = textManager.imageDicArr;
    preVC.links = textManager.linkDicArr;
    [self.navigationController pushViewController:preVC animated:YES];
    
}

- (void) textViewConfig {
    
    _textView = [[SJTextView alloc] initWithFrame:CGRectMake(10, 0, MAIN_WIDTH - 20, MAIN_HEIGHT - 64) delegate:self];
    [self.view addSubview:_textView];
    [_textView becomeFirstResponder];
    
    _textView.delegate = self;
    _textView.dataDetectorTypes = UIDataDetectorTypeLink;
    
    _textView.placeholder = @"测试12345";
    _textView.endPlaceholder = @"我是小尾巴~";
    
}

- (void) textBarConfig {
    
    /**-------工具栏------*/
    
    _textBar = [[SJTextBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_textBar];
    
    @SJWeakObj(self);
    
    // 添加图片
    [_textBar setAddImageBlock:^{
        [sjWeakself alert];
    }];
    
    // 分割线
    [_textBar setSepLineBlock:^{
        [sjWeakself.textView showModelWithSepline];
    }];
    
    // 斜体
    [_textBar setChangeToObliqueBlock:^(BOOL isOblique) {
        sjWeakself.textView.kSJTextIsOblique = isOblique;
    }];
    
    // font
    [_textBar setTextFontBlock:^(CGFloat font) {
        sjWeakself.textView.kSJTextNextFont = font;
    }];
    
    // 加粗
    [_textBar setChangeToBoldBlock:^(BOOL isBold) {
        sjWeakself.textView.kSJTextIsBold = isBold;
    }];
    
    // 中划线
    [_textBar setChangeToCenterLineBlock:^(BOOL isCenterLine) {
        sjWeakself.textView.kSJTextIsCenterLine = isCenterLine;
    }];
    
    // 下划线
    [_textBar setChangeToUnderLineBlock:^(BOOL isUnderLine) {
        sjWeakself.textView.kSJTextIsUnderLine = isUnderLine;
    }];
    
    // 添加超链接
    [_textBar setLinkBlock:^{
        [sjWeakself.textView alertLinkByBtnAction:YES];
    }];
    
    // 撤销
    [_textBar setUndoBlock:^{
        [sjWeakself.textView undoToLast];
    }];
    
    // 恢复
    [_textBar setRestoreBlock:^{
        [sjWeakself.textView restoreToNext];
    }];
    
}

#pragma mark textView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    // 删除
    if ([text isEqualToString:@""]) {
        NSLog(@"%ld-%ld",range.location,range.length);
        [_textView deleteByKeyboardWithRange:_textView.selectedRange];
        return NO;
    }
    
    // 键入
    [_textView showModelWithInputText:text];
    
    return NO;
}

-(void)textViewDidChangeSelection:(UITextView *)textView{
    NSLog(@"焦点改变");
        
    [_textView alertLinkByBtnAction:NO];
    
}


#pragma mark -  以下可另封装
#pragma mark 调用相机/相册

- (void)alert {
    
    @SJWeakObj(self); // 弱化self
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [sjWeakself cameraAction]; // 引用弱化self 调用相机
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [sjWeakself photoAction]; // 引用弱化self 调用相册
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:takeAction];
    [alert addAction:photoAction];
    [alert addAction:cancelAction];
    
    UIColor *textColor = [UIColor colorWithRed:0.87f green:0.27f blue:0.38f alpha:1.00f];
    
    [takeAction setValue:textColor forKey:@"titleTextColor"];
    [photoAction setValue:textColor forKey:@"titleTextColor"];
    [cancelAction setValue:textColor forKey:@"titleTextColor"];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)cameraAction{
    /**
     * 调用相机
     */
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self selectImage:UIImagePickerControllerSourceTypeCamera];
        
    }else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"不支持相机" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        NSLog(@"不支持相机");
    }
}

-(void)photoAction{
    /**
     * 调用本地相册
     */
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self selectImage:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"不支持相册" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:nil];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSLog(@"不支持相册");
    }
}

-(void)selectImage:(UIImagePickerControllerSourceType)type{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = type;
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSLog(@"mmmm");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    //UIImagePickerControllerEditedImage 裁剪之后的图片
    UIImage *newImage  = info[UIImagePickerControllerOriginalImage];
    
    CGSize  imgSize = newImage.size;
    CGFloat newImgW = imgSize.width;
    CGFloat newImgH = imgSize.height;
    CGFloat textW   = _textView.frame.size.width;
    
    UIGraphicsBeginImageContext(_image.size);
    
    if (newImgW > textW) {
        
        CGFloat ratio = textW / newImgW;
        newImgW  = textW;
        newImgH *= ratio;
        
        UIGraphicsBeginImageContext(CGSizeMake(newImgW, newImgH));
        
        [newImage drawInRect:CGRectMake(0, 0, newImgW, newImgH)];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        _image = image;
        
    }else{
        _image = newImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (_image) {
        
        // 图片显示
        [_textView showModelWithImage:_image];
        _image = nil;
    }
    
}

// 当实现取消的代理方法的时候，默认图片选取界面是不能放回的，必须在这个代理方法里面实现
// 如果这个方法不需要做其他操作，这个方法不用实现
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
