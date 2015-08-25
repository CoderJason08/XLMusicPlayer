//
//  XLMusic.h
//  0824音乐播放器
//
//  Created by Jason on 15/8/24.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLMusic : NSObject
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *lrc;
@property (nonatomic, copy) NSString *mp3;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *zhuanji;
@property (nonatomic, assign) NSInteger type;
@end


