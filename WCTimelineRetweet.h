//@interface UIMenuItem : NSObject
//- (instancetype)initWithTitle:(NSString *)title action:(SEL)action;
//@end
//
//@interface UIMenuController : NSObject
//@property(nullable, nonatomic,copy) NSArray *menuItems;
//+ (UIMenuController *)sharedMenuController;
//- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;
//- (void)setTargetRect:(CGRect)targetRect inView:(id)targetView;
//@end
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




