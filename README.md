>	小视频的转发支持4个功能，转发至朋友圈、转发至好友、保存到本地相册、拷贝小视频链接到粘贴板。如果小视频没有下载长按只会有小视频的url链接。

###	越狱机tweak安装
1.	新建tweak工程
2. 编写tweak文件

这里要hook两个类，分别是WCContentItemViewTemplateNewSight和SightMomentEditViewController，在WCContentItemViewTemplateNewSight中hook住onLongTouch方法然后添加menu弹出菜单，依次添加响应的方法，具体的代码如下：  

-	拷贝小视频的url链接

```OC
  NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    UISaveVideoAtPathToSavedPhotosAlbum(localPath, nil, nil, nil);
}
```

-	保存小视频到本地相册

```OC
NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    UISaveVideoAtPathToSavedPhotosAlbum(localPath, nil, nil, nil);
```

-	转发到朋友圈

```OC
 SightMomentEditViewController *editSightVC = [[%c(SightMomentEditViewController) alloc] init];
    NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    UIImage *image = [[self valueForKey:@"_sightView"] getImage];
    [editSightVC setRealMoviePath:localPath];
    [editSightVC setMoviePath:localPath];
    [editSightVC setRealThumbImage:image];
    [editSightVC setThumbImage:image];
    [WCTimelineVC presentViewController:editSightVC animated:YES completion:^{

    }];
```

-	转发给好友

```OC
[self sendSightToFriend];
```

-	长按手势

```OC
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) return;//防止出现menu闪屏的情况
    [self becomeFirstResponder];
    NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    BOOL isExist =[[NSFileManager defaultManager] fileExistsAtPath:localPath];
    UIMenuItem *retweetMenuItem = [[UIMenuItem alloc] initWithTitle:@"朋友圈" action:@selector(SLRetweetSight)];
    UIMenuItem *saveToDiskMenuItem = [[UIMenuItem alloc] initWithTitle:@"保存到相册" action:@selector(SLSightSaveToDisk)];
    UIMenuItem *sendToFriendsMenuItem = [[UIMenuItem alloc] initWithTitle:@"好友" action:@selector(SLSightSendToFriends)];
    UIMenuItem *copyURLMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制链接" action:@selector(SLSightCopyUrl)];
    if(isExist){
        [menuController setMenuItems:@[retweetMenuItem,sendToFriendsMenuItem,saveToDiskMenuItem,copyURLMenuItem]];
    }else{
        [menuController setMenuItems:@[copyURLMenuItem]];
    }
    [menuController setTargetRect:CGRectZero inView:self];
    [menuController setMenuVisible:YES animated:YES];
```

具体的tweak文件我放在了github上[WCSightRetweet](https://github.com/gaoshilei/WCSightRetweet)

3.	编写WCTimelineRetweet.h头文件
编写这个头文件的目的是防止tweak在编译期间报错，我们可以在编写好tweak试着编译一下，然后根据报错信息来添加这个头文件的内容，在这个文件中要声明在tweak我们用到的微信的类和方法，具体请看代码：  

```OC
@interface WCUrl : NSObject
@property(retain, nonatomic) NSString *url;
@end
@interface WCContentItem : NSObject
@property(retain, nonatomic) NSMutableArray *mediaList;
@end
@interface WCDataItem : NSObject
@property(retain, nonatomic) WCContentItem *contentObj;
@end
@interface WCMediaItem : NSObject
@property(retain, nonatomic) WCUrl *dataUrl;
- (id)pathForSightData;
@end
@interface MMServiceCenter : NSObject
+ (id)defaultCenter;
- (id)getService:(Class)arg1;
@end
@interface WCFacade : NSObject
- (id)getTimelineDataItemOfIndex:(long long)arg1;
@end
@interface WCSightView : UIView
- (id)getImage;
@end
@interface WCContentItemViewTemplateNewSight : UIView{
    WCSightView *_sightView;
}
- (WCMediaItem *)iOSREMediaItemFromSight;
- (void)iOSREOnSaveToDisk;
- (void)iOSREOnCopyURL;
- (void)sendSightToFriend;
@end
@interface SightMomentEditViewController : UIViewController
@property(retain, nonatomic) NSString *moviePath;
@property(retain, nonatomic) NSString *realMoviePath;
@property(retain, nonatomic) UIImage *thumbImage;
@property(retain, nonatomic) UIImage *realThumbImage;
- (void)makeInputController;
@end
@interface MMWindowController : NSObject
- (id)initWithViewController:(id)arg1 windowLevel:(int)arg2;
- (void)showWindowAnimated:(_Bool)arg1;
@end
@interface WCTimeLineViewController : UIViewController
- (long long)calcDataItemIndex:(long long)arg1;
@end
@interface MMTableViewCell : UIView
@end
@interface MMTableView : UIView
- (id)indexPathForCell:(id)cell;
@end
```  
4.	Makefile文件修改

```OC
THEOS_DEVICE_IP = 192.168.0.115//手机所在的IP
include $(THEOS)/makefiles/common.mk
ARCHS = arm64//支持的CPU架构
TWEAK_NAME = WCTimelineSightRetweet
WCTimelineSightRetweet_FILES = Tweak.xm
WCTimelineSightRetweet_FRAMEWORKS = UIKit CoreGraphics//导入系统的framework
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"//安装完成杀掉的进程
```
control文件不需要做修改，然后执行命令`make package install`安装到手机，微信会被杀掉，然后再次打开微信转发小视频的功能已经加上了。 
