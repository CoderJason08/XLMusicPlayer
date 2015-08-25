//
//  XLMusicTool.m
//  0824音乐播放器
//
//  Created by Jason on 15/8/24.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "XLMusicManager.h"

@implementation XLMusicManager{
    NSString *_currentMusicName;
}

+ (instancetype)sharedMusicManager {
    static XLMusicManager *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[XLMusicManager alloc] init];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:NULL];
        [session setCategory:AVAudioSessionCategoryPlayback error:NULL];
    });
    return tool;
}


- (void)playMusicWithName:(NSString *)musicName {
    if (![_currentMusicName isEqualToString:musicName]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:musicName ofType:nil];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        self.player.delegate = self;
        _currentMusicName = musicName;
    }
    [self.player play];
}

- (void)pauseMusic {
    [self.player pause];
}

- (NSTimeInterval)musicDuration {
    return self.player.duration;
}

- (NSTimeInterval)musicCurrentTime {
    return self.player.currentTime;
}

- (void)saveMusicInfoWithIndex:(NSInteger)musicIndex {
    [[NSUserDefaults standardUserDefaults] setInteger:musicIndex forKey:@"musicIndex"];
}

- (NSInteger)loadMusicInfo {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"musicIndex"];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(musicManager:didFinishPlay:)]) {
        [self.delegate musicManager:self didFinishPlay:player];
    }
}


#pragma mark - Getter & Setter

//- (AVAudioPlayer *)player {
//    if (!_player) {
//        // 如果读取信息是player为空，就从用户设置里加载上一次听的歌曲信息；
//        NSString *musicName = [[NSUserDefaults standardUserDefaults] objectForKey:@"musicName"];
//         NSString *path = [[NSBundle mainBundle] pathForResource:musicName ofType:nil];
//        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:NULL];
//    }
//    return _player;
//}


@end
