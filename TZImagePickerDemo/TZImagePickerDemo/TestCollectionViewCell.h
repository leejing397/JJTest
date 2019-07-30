//
//  TestCollectionViewCell.h
//  TZImagePickerDemo
//
//  Created by 李静 on 2019/7/30.
//  Copyright © 2019 gxsn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerLayer;

NS_ASSUME_NONNULL_BEGIN

@interface TestCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UILabel *gifLable;
@property (nonatomic, strong) id asset;

@property (nonatomic, strong,nullable) NSURL *videoURL;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@end

NS_ASSUME_NONNULL_END
