#import "WCTimelineRetweet.h"
static  WCTimeLineViewController *WCTimelineVC = nil;
%hook WCContentItemViewTemplateNewSight
%new
- (id)SLSightDataItem
{
    id responder = self;
    MMTableViewCell *SightCell = nil;
    MMTableView *SightTableView = nil;
    while (![responder isKindOfClass:NSClassFromString(@"WCTimeLineViewController")])
    {
        if ([responder isKindOfClass:NSClassFromString(@"MMTableViewCell")]){
            SightCell = responder;
        }
        else if ([responder isKindOfClass:NSClassFromString(@"MMTableView")]){
            SightTableView = responder;
        }
        responder = [responder nextResponder];
    }
    WCTimelineVC = responder;
    if (!(SightCell&&SightTableView&&WCTimelineVC))
    {
        NSLog(@"iOSRE: Failed to get video object.");
        return nil;
    }
    NSIndexPath *indexPath = [SightTableView indexPathForCell:SightCell];
    int itemIndex = [WCTimelineVC calcDataItemIndex:[indexPath section]];
    WCFacade *facade = [(MMServiceCenter *)[%c(MMServiceCenter) defaultCenter] getService: [%c(WCFacade) class]];
    WCDataItem *dataItem = [facade getTimelineDataItemOfIndex:itemIndex];
    WCContentItem *contentItem = dataItem.contentObj;
    WCMediaItem *mediaItem = [contentItem.mediaList count] != 0 ? (contentItem.mediaList)[0] : nil;
    return mediaItem;
}

%new
- (void)SLSightSaveToDisk
{
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    UISaveVideoAtPathToSavedPhotosAlbum(localPath, nil, nil, nil);
}

%new
- (void)SLSightCopyUrl
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self SLSightDataItem].dataUrl.url;
}

%new
- (void)SLRetweetSight
{
    SightMomentEditViewController *editSightVC = [[%c(SightMomentEditViewController) alloc] init];
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    UIImage *image = [[self valueForKey:@"_sightView"] getImage];
    [editSightVC setRealMoviePath:localPath];
    [editSightVC setMoviePath:localPath];
    [editSightVC setRealThumbImage:image];
    [editSightVC setThumbImage:image];
    [WCTimelineVC presentViewController:editSightVC animated:YES completion:^{

    }];
}

%new
- (void)SLSightSendToFriends
{
    [self sendSightToFriend];
}


- (void)onLongTouch
{
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
}
%end

%hook SightMomentEditViewController

- (void)popSelf
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

%end
