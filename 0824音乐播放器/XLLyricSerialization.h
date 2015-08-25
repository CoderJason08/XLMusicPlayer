//
//  XLLyricManager.h
//  0824音乐播放器
//
//  Created by Jason on 15/8/24.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLLyric.h"

@interface XLLyricSerialization: NSObject

+ (instancetype)sharedLyricSerialization;

/**
 *  返回解析后的歌词数组
 */
- (NSArray *)lyricArrayWithFileName:(NSString *)fileName;

@end
