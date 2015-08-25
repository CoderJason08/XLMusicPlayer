//
//  XLLyricManager.m
//  0824音乐播放器
//
//  Created by Jason on 15/8/24.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "XLLyricSerialization.h"

@implementation XLLyricSerialization

+ (instancetype)sharedLyricSerialization {
    static XLLyricSerialization *Serialization = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Serialization = [[XLLyricSerialization alloc] init];
    });
    return Serialization;
}

/**
 *  解析.lrc歌词文件
 *
 *  @param fileName 解析好的歌词模型数组
 *
 */
- (NSArray *)lyricArrayWithFileName:(NSString *)fileName {
    // 最终返回的数组
    NSMutableArray *lyricArray = [NSMutableArray array];
    // 读取歌词文件
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *lrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    // 1. 通过换行拆分歌词文件为单句歌词数组
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    // 2. 遍历每一句歌词,创建歌词模型
    /*
     (
     ...
     
     [02:25.00][00:29.00]仍然听见小提琴如泣似诉再挑逗
     [00:23.00]仍然倚在失眠夜望天边星宿
     [00:29.00]仍然听见小提琴如泣似诉再挑逗
     [02:19.00]仍然倚在失眠夜望天边星宿
     [02:25.00]仍然听见小提琴如泣似诉再挑逗
     ...
     )
     */
    
//    [02:19.00][00:23.00][00:23.00]仍然倚在失眠夜望天边星宿
    
//    result = (
//        [02:19.00],
//        [00:23.00]
//    )
    for (NSString *lrcLine in lrcArray) {
        // 3. 通过正则表达式过滤
        NSString *pattern = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
        NSArray *results =  [regular matchesInString:lrcLine options:NSMatchingReportCompletion range:NSMakeRange(0, lrcLine.length)];
        
        NSTextCheckingResult *result = [results lastObject];
        // 4. 选出歌词文本
        NSInteger index = result.range.location + result.range.length;
        NSString *lrcText = [lrcLine substringFromIndex:index];
//        NSLog(@"%@",lrcText);
        // 5. 遍历查询结果,根据时间创建模型
        for (NSTextCheckingResult *result in results) {
            NSString *time = [lrcLine substringWithRange:result.range];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"[mm:ss.SS]";
            NSDate *currentDate = [formatter dateFromString:time];
            NSDate *zeroDate = [formatter dateFromString:@"[00:00.00]"];
            XLLyric *lyric = [[XLLyric alloc] init];
            lyric.text = lrcText;
            lyric.time = [currentDate timeIntervalSinceDate:zeroDate];
            [lyricArray addObject:lyric];
        }
    }
    // 6.根据时间顺序对数组进行排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    lyricArray = (NSMutableArray *)[lyricArray sortedArrayUsingDescriptors:@[descriptor]];
    
    // 返回数组
//    for (XLLyric *lyric in lyricArray) {
//        NSLog(@"%zd-%@",lyric.time,lyric.text);
//    }
    return lyricArray;
}

@end
