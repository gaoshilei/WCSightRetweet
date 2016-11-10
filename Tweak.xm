#import "WCTimelineRetweet.h"
static  WCTimeLineViewController *WCTimelineVC = nil;
%hook WCContentItemViewTemplateNewSight
%new
- (id)iOSREMediaItemFromSight
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
- (void)iOSREOnSaveToDisk
{
    NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    UISaveVideoAtPathToSavedPhotosAlbum(localPath, nil, nil, nil);
}

%new
- (void)iOSREOnCopyURL
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self iOSREMediaItemFromSight].dataUrl.url;
}

%new
- (void)RetweetSight
{
    SightMomentEditViewController *editSightVC = [[%c(SightMomentEditViewController) alloc] init];
    NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    UIImage *image = [[self valueForKey:@"_sightView"] getImage];
    [editSightVC setRealMoviePath:localPath];
    [editSightVC setMoviePath:localPath];
    [editSightVC setRealThumbImage:image];
    [editSightVC setThumbImage:image];
    [WCTimelineVC presentViewController:editSightVC animated:YES completion:^{

    }];
}

%new
- (void)SendToFriends
{
    [self sendSightToFriend];
}

static int iOSRECounter;
- (void)onLongTouch
{
    iOSRECounter++;
    if (iOSRECounter % 2 == 0) return;
    [self becomeFirstResponder];
    NSString *localPath = [[self iOSREMediaItemFromSight] pathForSightData];
    BOOL isExist =[[NSFileManager defaultManager] fileExistsAtPath:localPath];
    UIMenuItem *retweetMenuItem = [[UIMenuItem alloc] initWithTitle:@"朋友圈" action:@selector(RetweetSight)];
    UIMenuItem *saveToDiskMenuItem = [[UIMenuItem alloc] initWithTitle:@"保存到相册" action:@selector(iOSREOnSaveToDisk)];
    UIMenuItem *sendToFriendsMenuItem = [[UIMenuItem alloc] initWithTitle:@"好友" action:@selector(SendToFriends)];
    UIMenuItem *copyURLMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制链接" action:@selector(iOSREOnCopyURL)];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
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
