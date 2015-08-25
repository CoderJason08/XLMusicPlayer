//
//  XLMusicTool.h
//  0824音乐播放器
//
//  Created by Jason on 15/8/24.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class XLMusicManager;

@protocol XLMusicManagerDelegate <NSObject>
@optional
- (void)musicManager:(XLMusicManager *)musicManager didFinishPlay:(AVAudioPlayer *)player;
@end

@interface XLMusicManager : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, weak) id<XLMusicManagerDelegate> delegate;

/**
 *  单例对象
 */
+ (instancetype)sharedMusicManager;
/**
 *  播放音乐
 *
 *  @param musicName 音乐名
 */
- (void)playMusicWithName:(NSString *)musicName;
/**
 *  暂停音乐
 */
- (void)pauseMusic;
/**
 *  音乐长度
 */
- (NSTimeInterval)musicDuration;
/**
 *  当前播放长度
 */
- (NSTimeInterval)musicCurrentTime;
/**
 *  保存当前播放音乐索引
 */
- (void)saveMusicInfoWithIndex:(NSInteger)musicIndex;
/**
 *  读取保存的音乐索引
 */
- (NSInteger)loadMusicInfo;

@end
