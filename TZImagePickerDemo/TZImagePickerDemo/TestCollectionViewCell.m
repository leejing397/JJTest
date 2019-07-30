//
//  TestCollectionViewCell.m
//  TZImagePickerDemo
//
//  Created by 李静 on 2019/7/30.
//  Copyright © 2019 gxsn. All rights reserved.
//

#import "TestCollectionViewCell.h"

#import <AVFoundation/AVFoundation.h>
#import <UIView+Layout.h>
#import <Photos/Photos.h>
#import <TZImagePickerController.h>

@implementation TestCollectionViewCell
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIImageView *)videoImageView {
    if (_videoImageView == nil) {
        _videoImageView = [[UIImageView alloc]init];
        _videoImageView.image = [UIImage tz_imageNamedFromMyBundle:@"MMVideoPreviewPlay"];
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoImageView.hidden = YES;
    }
    return _videoImageView;
}

- (UIButton *)deleteBtn {
    if (_deleteBtn == nil) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
        _deleteBtn.alpha = 0.6;
    }
    return _deleteBtn;
}

- (UILabel *)gifLable {
    if (_gifLable == nil) {
        _gifLable = [[UILabel alloc]init];
        _gifLable.text = @"GIF";
        _gifLable.textColor = [UIColor whiteColor];
        _gifLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _gifLable.textAlignment = NSTextAlignmentCenter;
        _gifLable.font = [UIFont systemFontOfSize:10];
    }
    return _gifLable;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        [self addSubview:self.imageView];
        
        [self addSubview:self.videoImageView];
        
        [self addSubview:self.deleteBtn];
        
        [self addSubview:self.gifLable];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    
    _gifLable.frame = CGRectMake(self.tz_width - 25, self.tz_height - 14, 25, 14);
    
    _deleteBtn.frame = CGRectMake(self.tz_width - 36, 0, 36, 36);
    
    CGFloat width = self.tz_width / 3.0;
    _videoImageView.frame = CGRectMake(width, width, width, width);
    [self bringSubviewToFront:_videoImageView];
    
    _playerLayer.frame = self.bounds;
}
- (void)setAsset:(id)asset {
    _asset = asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *asset1 = (PHAsset *)asset;
        _videoImageView.hidden = asset1.mediaType != PHAssetMediaTypeVideo;
        _gifLable.hidden = ![[asset1 valueForKey:@"filename"] containsString:@"GIF"];
    } else {
        if ([asset isKindOfClass:[NSURL class]]) {
            NSURL *URL = (NSURL *)asset;
            _gifLable.hidden = ![URL.absoluteString.lowercaseString hasSuffix:@"gif"];
        } else {
            _gifLable.hidden = YES;
        }
    }
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    if (_player) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [_player pause];
        _player = nil;
    }
    
    self.videoImageView.hidden = !self.videoURL;
    if (self.videoURL) {
        // 这个处理比较耗内存，最好是只用UIImageView显示视频的封面(服务端返回)，不创建AVPlayer
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        self.playerLayer.frame = self.bounds;
        [self.layer addSublayer:self.playerLayer];
        // 如cell内也需要播放视频，打开下面的注释即可，需注意会导致内存升高。同时需监听播放结束、应用回到后台的通知，将播放重置到起点或暂停，参考TZVideoPreviewCell内的处理
        // [self.player play];
        // self.videoImageView.hidden = YES;
    }
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    [self configMoviePlayer];
}
@end
