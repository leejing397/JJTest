//
//  MediaURLShowViewController.m
//  TZImagePickerDemo
//
//  Created by 李静 on 2019/7/30.
//  Copyright © 2019 gxsn. All rights reserved.
//

#import "MediaURLShowViewController.h"

#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController.h>
#import <UIView+Layout.h>
#import "TestCollectionViewCell.h"
#import <SDWebImageManager.h>
#import <SDWebImageDownloader.h>
#import <UIImage+GIF.h>
#import <UIImageView+WebCache.h>
#import "ImagePreviewController.h"

@interface MediaURLShowViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TZImagePickerControllerDelegate>{
    CGFloat _itemWH;
    CGFloat _margin;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSArray *videoSuffixs;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic,assign) NSInteger maxMediaNum;
@end

@implementation MediaURLShowViewController

- (NSInteger)maxMediaNum {
    if (!_maxMediaNum) {
        _maxMediaNum = 9;
    }
    return _maxMediaNum;
}

- (NSArray *)videoSuffixs {
    if (_videoSuffixs == nil) {
        _videoSuffixs = @[@"mov",@"mp4",@"rmvb",@"rm",@"flv",@"avi",@"3gp",@"wmv",@"mpeg1",@"mpeg2",@"mpeg4(mp4)",                                 @"asf",@"swf",@"vob",@"dat",@"m4v",@"f4v",@"mkv",@"mts",@"ts"];
    }
    return _videoSuffixs;
}

- (void)configCollectionView {
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    CGFloat rgb = 244 / 255.0;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:@"TZTestCell"];
}

- (NSMutableArray *)selectedPhotos {
    if (_selectedPhotos == nil) {
        _selectedPhotos = [NSMutableArray array];
        
        [_selectedPhotos addObject:[NSURL URLWithString:@"http://wx1.sinaimg.cn/bmiddle/784fda03gy1fuoxgoy1f4g209u04snpe.gif"]];
        [_selectedPhotos addObject:[UIImage imageNamed:@"photo_delete"]];
        [_selectedPhotos addObject:[NSURL URLWithString:@"https://vdse.bdstatic.com//f11546e6b21bb6f60f025df3d5cb5735?authorization=bce-auth-v1/fb297a5cc0fb434c971b8fa103e8dd7b/2017-05-11T09:02:31Z/-1//560f50696b0d906271532cf3868d7a3baf6e4f7ffbe74e8dff982ed57f72c088.mp4"]];
        [_selectedPhotos addObject:[NSURL URLWithString:@"https://github.com/banchichen/TZImagePickerController/raw/master/TZImagePickerController/ScreenShots/photoPickerVc.PNG"]];
        [_selectedPhotos addObject:[NSURL URLWithString:@"http://ww1.sinaimg.cn/bmiddle/b2664ecdly1fuphxvilsdg204306v1kx.gif"]];
        //    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"test_video" ofType:@"mov"];
        //    [self.selectedPhotos addObject:[NSURL fileURLWithPath:videoPath isDirectory:NO]];
    }
    return _selectedPhotos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configCollectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _margin = 4;
    _itemWH = (self.view.tz_width - 2 * _margin - 4) / 3 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    [self.collectionView setCollectionViewLayout:_layout];
    self.collectionView.frame = CGRectMake(0, 64, self.view.tz_width, self.view.tz_height - 64);
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.selectedPhotos.count == self.maxMediaNum) {
        return self.selectedPhotos.count;
    }
    return self.selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZTestCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    cell.videoURL = nil;
    cell.imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    if (indexPath.item == self.selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        id photo = self.selectedPhotos[indexPath.item];
        if ([photo isKindOfClass:[UIImage class]]) {
            cell.imageView.image = photo;
        } else if ([photo isKindOfClass:[NSURL class]]) {
            NSURL *URL = (NSURL *)photo;
            NSString *suffix = [[URL.absoluteString.lowercaseString componentsSeparatedByString:@"."] lastObject];
            if (suffix && [self.videoSuffixs containsObject:suffix]) {
                cell.videoURL = URL;
            } else {
                [self configImageView:cell.imageView URL:(NSURL *)photo completion:nil];
            }
        } else if ([photo isKindOfClass:[PHAsset class]]) {
            [[TZImageManager manager] getPhotoWithAsset:photo photoWidth:100 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                cell.imageView.image = photo;
            }];
        }
        cell.asset = self.selectedPhotos[indexPath.item];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.item;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)configImageView:(UIImageView *)imageView
                    URL:(NSURL *)URL
             completion:(void (^)(void))completion {
    if ([URL.absoluteString.lowercaseString hasSuffix:@"gif"]) {
        [[SDWebImageManager sharedManager]loadImageWithURL:URL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!imageView.image) {
                imageView.image = image;
            }
        }];
        
        // 动图加载完再覆盖掉
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:URL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            imageView.image = [UIImage sd_imageWithGIFData:data];
            if (completion) {
                completion();
            }
        }];
    }else {
        [imageView sd_setImageWithURL:URL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (completion) {
                completion();
            }
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.selectedPhotos.count) { // 选择
        TZImagePickerController *imagePickerVc = [self createTZImagePickerController];
        imagePickerVc.isSelectOriginalPhoto = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [self.selectedPhotos addObjectsFromArray:assets];
            [self.collectionView reloadData];
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    } else { // 预览
        ImagePreviewController *previewVc = [[ImagePreviewController alloc] initWithPhotos:self.selectedPhotos currentIndex:indexPath.row tzImagePickerVc:[self createTZImagePickerController]];
        [previewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
            self.isSelectOriginalPhoto = isSelectOriginalPhoto;
            NSLog(@"预览页 返回 isSelectOriginalPhoto:%d", isSelectOriginalPhoto);
        }];
        [previewVc setSetImageWithURLBlock:^(NSURL *URL, UIImageView *imageView, void (^completion)(void)) {
            [self configImageView:imageView URL:URL completion:completion];
        }];
        [previewVc setDoneButtonClickBlock:^(NSArray *photos, BOOL isSelectOriginalPhoto) {
            self.isSelectOriginalPhoto = isSelectOriginalPhoto;
            self.selectedPhotos = [NSMutableArray arrayWithArray:photos];
            NSLog(@"预览页 完成 isSelectOriginalPhoto:%d photos.count:%zd", isSelectOriginalPhoto, photos.count);
            [self.collectionView reloadData];
        }];
        [self presentViewController:previewVc animated:YES completion:nil];
    }
}

- (TZImagePickerController *)createTZImagePickerController {
    
    [TZImageManager manager].isPreviewNetworkImage = YES;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxMediaNum - self.selectedPhotos.count columnNumber:4 delegate:self pushPhotoPickerVc:NO];
    
#pragma mark - 个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.allowPickingMultipleVideo = YES;
    
    // imagePickerVc.minImagesCount = 3;
    imagePickerVc.alwaysEnableDoneBtn = YES;
    
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowPreview = NO;
    imagePickerVc.preferredLanguage = @"zh-Hans";
    
#pragma mark - 到这里为止
    
    return imagePickerVc;
}

- (void)deleteBtnClick:(UIButton *)button {
    if ([self collectionView:self.collectionView numberOfItemsInSection:0] <= self.selectedPhotos.count) {
        [self.selectedPhotos removeObjectAtIndex:button.tag];
        [self.collectionView reloadData];
        return;
    }
    
    [self.selectedPhotos removeObjectAtIndex:button.tag];
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
}

@end
