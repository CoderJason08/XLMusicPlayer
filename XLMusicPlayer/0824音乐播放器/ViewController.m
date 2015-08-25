//
//  ViewController.m
//  0824音乐播放器
//
//  Created by Jason on 15/8/24.
//  Copyright (c) 2015年 Jason. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XLMusic.h"
#import "MJExtension.h"
#import "XLMusicManager.h"
#import "XLLyricSerialization.h"
#import "XLLyricLabel.h"

#define kLrcLabelHeight 40
#define kLrcLabelTag(index) 1000 + (index)

@interface ViewController () <UIScrollViewDelegate,XLMusicManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *musicImage;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet XLLyricLabel *lyricLabel;
@property (weak, nonatomic) IBOutlet UIView *groupView;
@property (weak, nonatomic) IBOutlet UIScrollView *HScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *VScrollView;

/**
 *  音乐列表
 */
@property (nonatomic, strong) NSArray *musicList;
/**
 *  当前索引
 */
@property (nonatomic, assign) NSInteger currentIndex;
/**
 *  当前歌词行数索引
 */
@property (nonatomic, assign) NSInteger currentLrcIndex;
/**
 *  定时器
 */
@property (nonatomic, strong) NSTimer *mainTimer;
/**
 *  当前播放歌曲的全部歌词
 */
@property (nonatomic, strong) NSArray *lyricList;

@property (nonatomic, assign , getter=isPause) BOOL pause;
@end

@implementation ViewController {
    NSInteger _lastLrcTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIToolbar *toolBar = [[UIToolbar alloc]init];
    //样式
    //Translucent  半透明
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.bgImage addSubview:toolBar];
    toolBar.frame = self.view.bounds;
    self.HScrollView.delegate = self;
    self.VScrollView.delegate = self;
    // 从用户偏好读取信息
    _currentIndex = [[XLMusicManager sharedMusicManager] loadMusicInfo];
    [self updateMusicInfo];
    // 设置代理
    [XLMusicManager sharedMusicManager].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)viewWillAppear:(BOOL)animated {
    self.VScrollView.contentInset = UIEdgeInsetsMake(self.VScrollView.frame.size.height / 2, 0, self.VScrollView.frame.size.height / 2, 0);
}

// 更新界面布局
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.HScrollView.contentSize = CGSizeMake(2 * CGRectGetWidth(self.view.frame), 0);
    self.VScrollView.contentSize = CGSizeMake(0, self.lyricList.count * kLrcLabelHeight);
    // 滚动歌词
    [self.VScrollView setContentOffset:CGPointMake(0, -self.VScrollView.contentInset.top + kLrcLabelHeight * self.currentLrcIndex) animated:YES];
}

#pragma mark - UIScorllViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.VScrollView) {
//        NSLog(@"%@",NSStringFromCGPoint(self.VScrollView.contentOffset));
//        NSLog(@"%f",self.VScrollView.contentInset.top);
//    }
    if (scrollView == self.HScrollView) {
        self.groupView.alpha = 1 - (scrollView.contentOffset.x / CGRectGetWidth(self.view.frame));
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.VScrollView) {
        [self pauseBtnDidClick:self.pauseBtn];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.VScrollView) {
        NSInteger index = (self.VScrollView.contentOffset.y + self.VScrollView.contentInset.top) / kLrcLabelHeight;
        if (index < 0) {
            index = 0;
        }
        if (index >= self.lyricList.count) {
            index = self.lyricList.count - 1;
        }
        NSLog(@"%zd",index);
        XLLyric *lyric = self.lyricList[index];
        [XLMusicManager sharedMusicManager].player.currentTime = lyric.time;
        [self playBtnDidClick:self.playBtn];
    }
}



#pragma mark - XLMusicManagerDelegate

- (void)musicManager:(XLMusicManager *)musicManager didFinishPlay:(AVAudioPlayer *)player {
    [self nextBtnDidClick:nil];
}

#pragma mark - Action
/**
 *  播放歌曲
 */
- (IBAction)playBtnDidClick:(UIButton *)sender {
    self.pause = NO;
    // 获得模型
    XLMusic *music = self.musicList[_currentIndex];
    self.lyricList = [[XLLyricSerialization sharedLyricSerialization] lyricArrayWithFileName:music.lrc];
    // 播放音乐
    [[XLMusicManager sharedMusicManager] playMusicWithName:music.mp3];
    // 更新界面信息
    [self updateMusicInfo];
    // 切换按钮状态
    sender.hidden = YES;
    self.pauseBtn.hidden = NO;
    // 开启定时器
    [[NSRunLoop currentRunLoop] addTimer:self.mainTimer forMode:NSRunLoopCommonModes];
    // 保存信息
    [[XLMusicManager sharedMusicManager] saveMusicInfoWithIndex:_currentIndex];
    
}
/**
 *  暂停歌曲
 */
- (IBAction)pauseBtnDidClick:(UIButton *)sender {
    self.pause = YES;
    [[XLMusicManager sharedMusicManager] pauseMusic];
    [self.mainTimer invalidate];
    self.mainTimer = nil;
    sender.hidden = YES;
    self.playBtn.hidden = NO;
}
/**
 *  播放下一首歌曲
 */
- (IBAction)nextBtnDidClick:(UIButton *)sender {
    self.currentIndex = (self.currentIndex + 1) % (self.musicList.count);
    [self playBtnDidClick:self.playBtn];
}
/**
 *  播放上一首歌曲
 */
- (IBAction)preBtnDidClick:(UIButton *)sender {
    self.currentIndex = self.currentIndex == 0 ? self.musicList.count - 1 : (self.currentIndex - 1) % (self.musicList.count - 1);
    [self playBtnDidClick:self.playBtn];
}
/**
 *  更新界面信息
 */
- (void)updateMusicInfo {
    // 暂停之后再次播放,不再更新界面信息
    if (self.isPause) {
        return;
    }
    XLMusic *music = self.musicList[_currentIndex];
    // 解析歌词
    self.lyricList = [[XLLyricSerialization sharedLyricSerialization] lyricArrayWithFileName:music.lrc];
    self.bgImage.image = [UIImage imageNamed:music.image];
    self.musicImage.image = [UIImage imageNamed:music.image];
    
    self.title = music.name;
    self.albumLabel.text = music.zhuanji;
    self.singerLabel.text = music.singer;
    NSTimeInterval totalTime =  [[XLMusicManager sharedMusicManager] musicDuration];
    NSInteger min = totalTime / 60;
    NSInteger second = (NSInteger)totalTime % 60;
    self.totalTime.text = [NSString stringWithFormat:@"%zd:%02zd",min,second];
    // 没有显示时间,初始化为0:00
    self.currentTime.text = @"0:00";

    XLLyric *lyric = self.lyricList[0];
    self.lyricLabel.text = lyric.text;
  
//     设置滚动歌词
    [self.VScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int index = 0; index < self.lyricList.count; index++) {
        XLLyric *lyric = self.lyricList[index];
        XLLyricLabel *lrcLabel = [[XLLyricLabel alloc] init];
        lrcLabel.text = lyric.text;
        lrcLabel.tag = kLrcLabelTag(index);
        [self.VScrollView addSubview:lrcLabel];
        lrcLabel.frame = CGRectMake(0, index * kLrcLabelHeight, self.view.frame.size.width, kLrcLabelHeight);
    }
}
/**
 *  更新动态信息
 */
- (void)updateDynamicInfo {
//    NSLog(@"updateDynamicInfo");
    // 时间相关
    CGFloat currentTime = [[XLMusicManager sharedMusicManager] musicCurrentTime];
    NSInteger min = currentTime / 60;
    NSInteger second = (NSInteger)currentTime % 60;
    CGFloat duration = [[XLMusicManager sharedMusicManager] musicDuration];
    CGFloat progress = currentTime / duration;
    self.currentTime.text = [NSString stringWithFormat:@"%zd:%02zd",min,second];
    self.progressView.progress = progress;
    
//    当前时间 > 当前行的时间 && 小于 下一行的歌词时间  显示当前行的文本
    for (int index = 0; index < self.lyricList.count; index ++) {
        XLLyric *currentLyric = self.lyricList[index];
        XLLyric *nextLyric = self.lyricList[index == self.lyricList.count - 1 ? index : index + 1];
        if (currentTime >= currentLyric.time && currentTime <  nextLyric.time) {
            self.currentLrcIndex = index;
            self.lyricLabel.text = currentLyric.text;
            // 当前句进度: (currentTime - currentLyric.time) / (nextLyric.time - currentLyric.time)
            // 主界面歌词
            CGFloat progress = (currentTime - currentLyric.time) / (nextLyric.time - currentLyric.time);
            self.lyricLabel.progress =  progress;
            
            // 当前滚动显示歌词
            XLLyricLabel *currentScrollLrcLabel = (XLLyricLabel *)[self.VScrollView viewWithTag:kLrcLabelTag(index)];
            currentScrollLrcLabel.font = [UIFont boldSystemFontOfSize:20];
            currentScrollLrcLabel.progress = progress;
            // 取消上一句显示滚动歌词颜色
            if (index > 0) {
                XLLyricLabel *preScrollLrcLabel = (XLLyricLabel *)[self.VScrollView viewWithTag:kLrcLabelTag(index) - 1];
                preScrollLrcLabel.progress = 0;
            }
        }
    }
    // 锁屏界面
    [self updateLockScreenInfo];
}

- (void)updateLockScreenInfo {
    XLMusic *music = self.musicList[_currentIndex];
    /*
     MPMediaItemPropertyAlbumTitle // 专辑名称
     MPMediaItemPropertyAlbumTrackCount
     MPMediaItemPropertyAlbumTrackNumber
     MPMediaItemPropertyArtist // 艺术家
     MPMediaItemPropertyArtwork // 专辑图片
     MPMediaItemPropertyComposer
     MPMediaItemPropertyDiscCount
     MPMediaItemPropertyDiscNumber
     MPMediaItemPropertyGenre
     MPMediaItemPropertyPersistentID
     MPMediaItemPropertyPlaybackDuration
     MPMediaItemPropertyTitle //歌曲名称
     */
    // 获取正在播放中心
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    // 创建信息字典
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    // 专辑
    [infoDict setObject:music.zhuanji forKey:MPMediaItemPropertyAlbumTitle];
    // 标题
    [infoDict setObject:music.name forKey:MPMediaItemPropertyTitle];
    // 当前时长
    [infoDict setObject:@([XLMusicManager sharedMusicManager].musicCurrentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    // 总时长
    [infoDict setObject:@([XLMusicManager sharedMusicManager].musicDuration) forKey:MPMediaItemPropertyPlaybackDuration];
    // 图片
    [infoDict setObject: [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:music.image]] forKey:MPMediaItemPropertyArtwork];
    // 设置当前播放的媒体信息
    center.nowPlayingInfo = infoDict;
    // 接收远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

/**
 *  将歌词信息绘制绘制在锁屏图片上
 */
- (UIImage *)getCurrentArtWorkImage{

    XLMusic *music = self.musicList[_currentIndex];
    UIImage *image = [UIImage imageNamed:music.image];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:rect];
#warning 继续
    UIImage *lrcBgImage = [UIImage imageNamed:@"lock_lyric_mask"];
    CGFloat lrcBgImgHeight = 2 * kLrcLabelHeight;
    [lrcBgImage drawInRect:CGRectMake(0, rect.size.height - lrcBgImgHeight, rect.size.width, lrcBgImgHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
 事件类型:
 UIEventTypeTouches, 触摸事件
 UIEventTypeMotion, 运动事件
 UIEventTypeRemoteControl, 远程事件
 */
/**
 *  接收到远程时间事调用
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    // 通过事件的subType判断事件类型
    /*
     // for UIEventTypeRemoteControl, available in iOS 4.0
     UIEventSubtypeRemoteControlPlay                 = 100,
     UIEventSubtypeRemoteControlPause                = 101,
     UIEventSubtypeRemoteControlStop                 = 102,
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,
     UIEventSubtypeRemoteControlNextTrack            = 104,
     UIEventSubtypeRemoteControlPreviousTrack        = 105,
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
     UIEventSubtypeRemoteControlEndSeekingForward    = 109,
     */
}

/**
 *  成为第一响应者,才能接收远程事件
 */
- (BOOL)becomeFirstResponder {
    return YES;
}

#pragma mark - Getter & Setter

- (NSArray *)musicList {
    if (!_musicList) {
        self.musicList = [XLMusic objectArrayWithFilename:@"mlist.plist"];
    }
    return _musicList;
}

- (NSTimer *)mainTimer {
    if (!_mainTimer) {
        CGFloat frequency = 1 / 30.0;
        self.mainTimer = [NSTimer timerWithTimeInterval:frequency target:self selector:@selector(updateDynamicInfo) userInfo:nil repeats:YES];
    }
    return _mainTimer;
}


@end
