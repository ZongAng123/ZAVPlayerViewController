//
//  ViewController.m
//  HuaHua
//
//  Created by 纵昂 on 2021/3/22.
//

#import "ViewController.h"
//iOS官方播放器头文件
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVPlayerViewControllerDelegate>
{
    //定义一个播放器
    AVPlayerViewController* _playerVC;
    //播放地址字符串
    NSString* _videoUrl;
}

//是否显示视频播放控制控件
@property (nonatomic) BOOL showsPlaybackControls;
//设置视频播放界面的尺寸缩放选项
/*
可以设置的值及意义如下：
AVLayerVideoGravityResizeAspect   不进行比例缩放 以宽高中长的一边充满为基准
AVLayerVideoGravityResizeAspectFill 不进行比例缩放 以宽高中短的一边充满为基准
AVLayerVideoGravityResize     进行缩放充满屏幕
*/
@property (nonatomic, copy) NSString *videoGravity;
//获取是否已经准备好开始播放
@property (nonatomic, readonly, getter = isReadyForDisplay) BOOL readyForDisplay;
//获取视频播放界面的尺寸
@property (nonatomic, readonly) CGRect videoBounds;
//视频播放器的视图 自定义的控件可以添加在其上
@property (nonatomic, readonly, nullable) UIView *contentOverlayView;
//画中画代理 iOS9后可用
@property (nonatomic, weak, nullable) id <AVPlayerViewControllerDelegate> delegate NS_AVAILABLE_IOS(9_0);
//是否支持画中画 iOS9后可用 默认支持
@property (nonatomic) BOOL allowsPictureInPicturePlayback NS_AVAILABLE_IOS(9_0);

@property (nonatomic, strong) UIView *videoView; // 视频view
@property (nonatomic, strong) UIButton *huahzonghua; //开启画中画按钮
@property(nonatomic,strong) AVPictureInPictureController * picController; //

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#pragma mark -  初始化音频 AVAudioSession是一个单例类
//    AVAudioSessionCategorySoloAmbient是系统默认的category
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
//   激活AVAudioSession
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

/* 下面来直观的看下每种category具体的能力集
  AVAudioSessionCategoryPlayback - 只支持播放-默认YES，可以重写为NO
  AVAudioSessionCategoryAmbient  - 只支持播放
  AVAudioSessionCategoryPlayAndRecord - 支持播放，支持录制
  AVAudioSessionCategoryMultiRoute - 支持播放，支持录制
 **/
    
/*
 iOS新的视频开发框架AVPlayerViewContoller与画中画技术
 前面有一篇博客探讨了iOS中视频播放的开发相关类和方法，那篇博客中主要讲解的是MeidaPlayer框架中的MPMoviePlayerController类和MPMoviePlayerViewController类。在iOS8中，iOS开发框架中引入了一个新的视频框架AVKit，其中提供了视频开发类AVPlayerViewController用于在应用中嵌入播放视频的控件。在iOS8中，这两个框架中的视频播放功能并无太大差异，基本都可以满足开发者的需求。iOS9系统后，iPad Air正式开始支持多任务与画中画的分屏功能，所谓画中画，即是用户可以将当前播放的视频缩小放在屏幕上同时进行其他应用程序的使用。这个革命性的功能将极大的方便用户的使用。于此同时，在iOS9中，MPMoviePlayerController与MPMoviePlayerViewController类也被完全易用，开发者使用AVPlayerViewController可以十分方便的实现视频播放的功能并在一些型号的iPad上集成画中画的功能。

 **/

    
    _videoView = [[UIView alloc]initWithFrame:CGRectMake(5, 100, 400, 200)];
    [self.view addSubview:_videoView];
    
#pragma mark -
#pragma mark - 使用如下代码进行视频的播放：
       NSURL *url = [NSURL URLWithString:@"http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"];
//      初始化视频播放器控制器
      _playerVC = [[AVPlayerViewController alloc]init];
      _playerVC.delegate = self;
//    设置视频图像位置和大小
      _playerVC.view.frame = _videoView.bounds;
//    显示播放控制按钮
      _playerVC.showsPlaybackControls = YES;
      _playerVC.allowsPictureInPicturePlayback = YES; //画中画，iPad可用
      _playerVC.entersFullScreenWhenPlaybackBegins = YES;//开启这个播放的时候支持（全屏）横竖屏哦
      _playerVC.exitsFullScreenWhenPlaybackEnds = YES;//开启这个所有 item 播放完毕可以退出全屏
      _playerVC.player = [[AVPlayer alloc]initWithURL:url];
      [_videoView addSubview:_playerVC.view];
//       [self presentViewController:_playerVC animated:YES completion:nil];
    //加载好之后，播放
        if (_playerVC.readyForDisplay) {
            [_playerVC.player play];
        }
/*
 AVPlayerViewController是默认支持画中画操作的，如上图所示，视频的播放界面右下角出现一个画中画的按钮，点击这个按钮当前播放的视频界面会缩小显示在屏幕角落，这时点击Home键回到主界面，或者切换到其他应用程序，视频播放不会中断。如下图所示
 AVKit从iOS8开始被引入iOS平台。针对iOS平台的AVKit是一个简单的标准框架-只包含一个AVPlayerViewController类。它是UIViewController的子类，用于展示并控制AVPlayer实例的播放。
 AVPlayerViewController具有一个很小的界面，提供以下几个属性：
 player：用来播放媒体内容的AVPlayer实例
 showsPlaybackControls：用来表示播放控件是否显示或隐藏。
 videoGravity：视频的显示区域设置
 readForDisplay：通过观察这个布尔值类型的值来确定视频内容是否已经准备好进行展示

 
 **/
    
#pragma mark - 画中画编程技术应用
    _huahzonghua = [[UIButton alloc]initWithFrame:CGRectMake(10, 360, 100, 30)];
    [_huahzonghua setTitle:@"开启画中画" forState:UIControlStateNormal];
    [_huahzonghua addTarget:self action:@selector(huahzonhuaClick) forControlEvents:UIControlEventTouchUpInside];
    [_huahzonghua setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_huahzonghua];
    
    
}
#pragma mark -  AVPlayerViewControllerDelegate中的方法可以对用户画中画的操作进行监听：
//将要开始画中画时调用的方法
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController{
}
//已经开始画中画时调用的方法
- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController{
}
//开始画中画失败调用的方法
- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error{
}
//将要停止画中画时调用的方法
- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController{
}
//已经停止画中画时调用的方法
- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController{
}
//是否在开始画中画时自动将当前的播放界面dismiss掉 返回YES则自动dismiss 返回NO则不会自动dismiss
- (BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController{
    return YES;
}
//用户点击还原按钮 从画中画模式还原回app内嵌模式时调用的方法
- (void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler{
}


-(void)huahzonhuaClick{
    NSLog(@"开启画中画");
    _playerVC.allowsPictureInPicturePlayback = YES; ////画中画，iPad可用
}

@end
