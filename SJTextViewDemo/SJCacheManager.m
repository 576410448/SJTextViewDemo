//
//  SJCacheManager.m
//  SJTextViewDemo
//
//  Created by shenj on 16/12/9.
//  Copyright © 2016年 shenj. All rights reserved.
//

#import "SJCacheManager.h"
#import "SJTextManager.h"
#import "SJNoteStatusBar.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface SJCacheManager ()

@property (nonatomic ,strong) NSManagedObjectContext *managerObjectContext;

@property (nonatomic ,strong) UIWindow *alert;

@end

@implementation SJCacheManager

static SJCacheManager *sjcacheManager;
+ (instancetype)coreDataManager {
    
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        sjcacheManager = [[self alloc] init];
    });
    return sjcacheManager;
    
}

- (NSManagedObjectContext *)configManagerObjectContext {
    
    // 创建context
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    // 管理模型
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:mainManagerObjectModelFileName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    // 存储调度器
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 关联数据库
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingFormat:@"/%@.sqlite",ManagerObjectModelFileName];
    NSLog(@"%@",dataPath);
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:nil];
    
    // 上下文设置存储调度器
    context.persistentStoreCoordinator = coordinator;
    
    return context;
    
}

- (NSManagedObjectContext *)managerObjectContext {
    
    if (!_managerObjectContext) {
        _managerObjectContext = [self configManagerObjectContext];
    }
    return _managerObjectContext;
    
}

// 读取数据库中所有数据
- (NSArray *)showAllObjInCoreData {
    
    // 创建数据库数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置要检索的类型实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:self.managerObjectContext];
    // 设置请求实体
    [request setEntity:entity];
    
    // 指定返回结果排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    
    NSArray *sortDescriptions = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [request setSortDescriptors:sortDescriptions];
    
    // 添加过滤条件
//    request.predicate = [NSPredicate predicateWithFormat:@"time"];
    
    NSError *error = nil;
    // 执行请求，返回数组
    NSArray *fetchArr = [self.managerObjectContext executeFetchRequest:request error:&error];
    
    if (!fetchArr) {
        return @[];
    }
    return fetchArr;
}

// 数据库中是否存在
- (BOOL)isExistInCoredataFor:(NSDate *)time {
    
    NSArray *fetchedObjects = [self showAllObjInCoreData];
    
    for (SJCacheModel *cacheModel in fetchedObjects) {
        
        if ([cacheModel.time isEqual:time]) {
            return YES;
        }
    }
    return NO;
    
}

// 存入数据库
- (void)saveCoreData:(NSAttributedString *)attStr
               links:(NSArray *)links
              images:(NSArray *)images
                time:(NSDate *)time {
    
    // 取当前时间
    if (!time) {
        time = [self getNowDateFromatAnDate];
    }
    
    NSData *linksData = [self changeToDataByArray:links];
    NSData *imagesData = [self changeToDataByArray:images];
    NSData* attStrData = [self changeToDataByAttributeString:attStr];
        
    BOOL isExist = [self isExistInCoredataFor:time];
    
    //          托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess;
    
    NSError *error = nil;
    
    if (isExist) {
        
        NSArray *fetchedObjects = [self showAllObjInCoreData];
        
        for (SJCacheModel *cacheModel in fetchedObjects) {
            
            if ([cacheModel.time isEqual:time]) {
                
                [cacheModel setTime:[self getNowDateFromatAnDate]];
                [cacheModel setLinks:linksData];
                [cacheModel setImages:imagesData];
                [cacheModel setAttributeText:attStrData];
                break;
            }
        }
        
        isSaveSuccess = [self.managerObjectContext hasChanges];
        
    }else {
        
        SJCacheModel *cacheModel = [NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:self.managerObjectContext];
        [cacheModel setTime:time];
        [cacheModel setLinks:linksData];
        [cacheModel setImages:imagesData];
        [cacheModel setAttributeText:attStrData];
        
        isSaveSuccess = [self.managerObjectContext hasChanges];
        
    }
    
    
    if (!isSaveSuccess) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }else {
        NSLog(@"save successFull");
        [self.managerObjectContext save:&error];
        [SJNoteStatusBar alertWithText:@"save successFull"];
    }
    
    [self deleteFromeCoreData:nil];
    
}

// 从数据库中删除
- (void)deleteFromeCoreData:(SJCacheModel *)model {
    
    if (model) {
        [self.managerObjectContext deleteObject:model];
        
        NSError *error = nil;
        
        //    托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
        BOOL isSaveSuccess = [self.managerObjectContext hasChanges];
        if (!isSaveSuccess) {
            NSLog(@"Error: %@,%@",error,[error userInfo]);
            
        }else {
            NSLog(@"del successFull");
            [self.managerObjectContext save:&error];
            [SJNoteStatusBar alertWithText:@"del successFull"];
        }
    }
    
    NSArray *fetchedObjects = [self showAllObjInCoreData];
    
    for (SJCacheModel *cacheModel in fetchedObjects) {
        
        if ([cacheModel.attributeText isEqual:NULL] ||
            !cacheModel.attributeText) {
            
            [self.managerObjectContext deleteObject:model];
            
            NSError *error = nil;
            
            //    托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
            BOOL isSaveSuccess = [self.managerObjectContext hasChanges];
            if (!isSaveSuccess) {
                NSLog(@"Error: %@,%@",error,[error userInfo]);
                
            }else {
                NSLog(@"del successFull");
                [self.managerObjectContext save:&error];
            }
            
        }
        
    }
    
}

/**
 *  获取当天的年月日的字符串
 *  这里测试用
 *  @return 格式为年-月-日
 */
- (NSDate *)getNowDateFromatAnDate
{
    NSDate *nowDate = [NSDate date];
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:nowDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:nowDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:nowDate];
    return destinationDateNow;
}

// attribute转data
- (NSData *)changeToDataByAttributeString:(NSAttributedString *)attributeString {
    
    NSData* stringData = [NSKeyedArchiver archivedDataWithRootObject:attributeString];
    return stringData;
    
}

// data转换attribute
- (NSAttributedString *)changeToAttributeStringByData:(NSData *)data {
    NSAttributedString *attStr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return attStr;
}

// 数组转data
- (NSData *)changeToDataByArray:(NSArray *)array {
    NSError *error = nil;
    NSData *data;
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    if ([array.firstObject count] == 3) { // 图片
        
        for (NSMutableDictionary *dic in array) {
            
            @autoreleasepool {
                
                UIImage *image = dic[kImageNameKey];
                NSData *imageData = UIImagePNGRepresentation(image);
                NSString *imageStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                
                NSDictionary *newDic = @{kImageNameKey:imageStr,
                                         kImageRangeLengthKey:dic[kImageRangeLengthKey],
                                         kImageRangeLocationKey:dic[kImageRangeLocationKey]};
                [mutableArr addObject:newDic];
                
            }
            
        }
        
        data = [NSJSONSerialization dataWithJSONObject:mutableArr options:NSJSONWritingPrettyPrinted error:&error];
        
    }else{
        data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    
    return data;
}


// data转换Array
- (NSArray *)changeToArrayByData:(NSData *)data {
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
    if ([array.firstObject count] == 3) { // 图片数组
        
        for (NSMutableDictionary *dic in array) {
            
            @autoreleasepool {
                
                NSString *imageStr = dic[kImageNameKey];
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *image = [UIImage imageWithData:imageData];
                
                NSDictionary *newDic = @{kImageNameKey:image,
                                         kImageRangeLengthKey:dic[kImageRangeLengthKey],
                                         kImageRangeLocationKey:dic[kImageRangeLocationKey]};
                [mutableArr addObject:newDic];
                
            }
            
        }
        
        return mutableArr;
        
    } else {
        return array;
    }

    
}



@end
