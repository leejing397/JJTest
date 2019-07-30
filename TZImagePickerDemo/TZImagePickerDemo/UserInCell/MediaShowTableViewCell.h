//
//  MediaShowTableViewCell.h
//  TZImagePickerDemo
//
//  Created by 李静 on 2019/7/30.
//  Copyright © 2019 gxsn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZImagePickerController;
@class TZGifPhotoPreviewController;
@class TZVideoPlayerController;

typedef void(^GXPushImgPickerBlock)(TZImagePickerController * _Nullable imagePickerController);
typedef void(^GXPushGifPreviewBlock)(TZGifPhotoPreviewController * _Nullable gifPreviewVC);
typedef void(^GXPushVideoPlayerBlock)(TZVideoPlayerController *videoPlayerVC);

typedef void(^GXReloadCellBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface MediaShowTableViewCell : UITableViewCell

- (CGFloat)cellHeight;
@property (nonatomic, copy) GXPushImgPickerBlock pushImgPicker;
@property (nonatomic, copy) GXPushGifPreviewBlock pushGifPreviewVC;
@property (nonatomic, copy) GXPushVideoPlayerBlock pushVideoPlayer;
@property (nonatomic, copy) GXReloadCellBlock reloadCell;
@end

NS_ASSUME_NONNULL_END
