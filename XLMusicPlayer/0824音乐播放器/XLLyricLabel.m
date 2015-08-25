//
//  XLLyricLabel.m
//  0824音乐播放器
//
//  Created by Jason on 15/8/25.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "XLLyricLabel.h"

@implementation XLLyricLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect colorRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
    [[UIColor redColor] setFill];
    UIRectFillUsingBlendMode(colorRect, kCGBlendModeSourceIn);
}

- (instancetype)init {
    if (self = [super init]) {
        self.font = [UIFont systemFontOfSize:18];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (progress == 0) {
        self.font = [UIFont systemFontOfSize:18];
    }
    [self setNeedsDisplay];
}


@end
