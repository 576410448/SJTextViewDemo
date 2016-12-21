//
//  SJTextHeader.h
//  SJTextViewDemo
//
//  Created by shenj on 16/12/16.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SJTextTools.h"
#import "SJTextManager.h"
#import "SJCacheManager.h"

#import "SJTextView.h"
#import "SJTextBar.h"


/**------SJTextManager 数据源images links 数据源key-------**/

static NSString *const kLinkTitleKey        = @"kLinkTitleKey";
static NSString *const kLinkUrlKey          = @"kLinkUrlKey";
static NSString *const kLinkRangLocationKey = @"kLinkRangLocationKey";
static NSString *const KLinkRangLengthKey   = @"KLinkRangLengthKey";

static NSString *const kImageNameKey          = @"kImageNameKey";
static NSString *const kImageRangeLocationKey = @"kImageRangeLocationKey";
static NSString *const kImageRangeLengthKey   = @"kImageRangeLengthKey";

/**------SJAllArrayManager 大数据源 images links 对应key-------**/

static NSString * const kAllArrayTextKey   = @"kAllArrayTextKey";
static NSString * const kAllArrayLinksKey  = @"kAllArrayLinksKey";
static NSString * const kAllArrayImagesKey = @"kAllArrayImagesKey";

/**------SJNoteStatusBar 数据源发生改变 通知-------**/

static NSString *const kCacheDataHasChangeNote   = @"kCacheDataHasChangeNote";
