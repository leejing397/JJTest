//
//  MediaShowTableViewCell.m
//  TZImagePickerDemo
//
//  Created by 李静 on 2019/7/30.
//  Copyright © 2019 gxsn. All rights reserved.
//

#import "MediaShowTableViewCell.h"

#import "TestCollectionViewCell.h"
#import <UIView+Layout.h>
#import <TZImagePickerController.h>

static NSString *const GXShowInCellID  = @"GXShowInCellID";

@interface MediaShowTableViewCell()<UICollectionViewDataSource,UICollectionViewDelegate,TZImagePickerControllerDelegate>{
    CGFloat _itemWH;
    CGFloat _margin;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@end

@implementation MediaShowTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self configCollectionView];
    }
    return self;
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
    [self addSubview:_collectionView];
    [_collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:GXShowInCellID];
}

- (NSMutableArray *)selectedPhotos {
    if (_selectedPhotos == nil) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

- (NSMutableArray *)selectedAssets {
    if (_selectedAssets == nil) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _margin = 4;
    _itemWH = (self.tz_width - 2 * _margin - 4) / 3 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
    [self.collectionView setCollectionViewLayout:_layout];
    self.collectionView.frame = CGRectMake(_margin, _margin, self.tz_width - 2 * _margin, self.tz_height - 2 * _margin);
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GXShowInCellID forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.item == self.selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        cell.imageView.image = self.selectedPhotos[indexPath.item];
        cell.asset = self.selectedAssets[indexPath.item];
        cell.deleteBtn.hidden = NO;
    }
//    if (!self.allowPickingGifSwitch.isOn) {
//        cell.gifLable.hidden = YES;
//    }
    cell.deleteBtn.tag = indexPath.item;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.selectedPhotos.count) { // 选择
        TZImagePickerController *imagePickerVc = [self createTZImagePickerController];
        imagePickerVc.isSelectOriginalPhoto = NO;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [self.selectedAssets addObjectsFromArray:assets];
            [self.selectedPhotos addObjectsFromArray:photos];
            [self.collectionView reloadData];
            self.reloadCell();
        }];
        self.pushImgPicker(imagePickerVc); 
    }else { // preview photos or video / 预览照片或者视频
        PHAsset *asset = self.selectedAssets[indexPath.item];
        BOOL isVideo = NO;
        isVideo = asset.mediaType == PHAssetMediaTypeVideo;
        if ([[asset valueForKey:@"filename"] containsString:@"GIF"]) {
            TZGifPhotoPreviewController *vc = [[TZGifPhotoPreviewController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypePhotoGif timeLength:@""];
            vc.model = model;
            self.pushGifPreviewVC(vc);           
        } else if (isVideo) { // perview video / 预览视频
            TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            self.pushVideoPlayer(vc);
        } else { // preview photos / 预览照片
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:self.selectedAssets selectedPhotos:self.selectedPhotos index:indexPath.item];
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                self.selectedPhotos = [NSMutableArray arrayWithArray:photos];
                self.selectedAssets = [NSMutableArray arrayWithArray:assets];
                self.isSelectOriginalPhoto = isSelectOriginalPhoto;
                [self.collectionView reloadData];
                self.collectionView.contentSize = CGSizeMake(0, ((self.selectedPhotos.count + 2) / 3 ) * (self->_margin + self->_itemWH));
            }];
            self.pushImgPicker(imagePickerVc);

        }
    }
}

- (void)deleteBtnClick:(UIButton *)button {
    if ([self collectionView:self.collectionView numberOfItemsInSection:0] <= self.selectedPhotos.count) {
        [self.selectedPhotos removeObjectAtIndex:button.tag];
        [self.selectedAssets removeObjectAtIndex:button.tag];
        [self.collectionView reloadData];
        self.reloadCell();
        return;
    }
    
    [self.selectedPhotos removeObjectAtIndex:button.tag];
    [self.selectedAssets removeObjectAtIndex:button.tag];
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.tag inSection:0];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
    self.reloadCell();
}

- (TZImagePickerController *)createTZImagePickerController {
    
    [TZImageManager manager].isPreviewNetworkImage = YES;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:NO];
    
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
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    imagePickerVc.showSelectBtn = NO;
    //imagePickerVc.allowPreview = NO;
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
#pragma mark - 到这里为止
    
    return imagePickerVc;
}

- (CGFloat)cellHeight {
    return self.selectedAssets.count == 0 ? (_itemWH + 3 * _margin) : (self.selectedAssets.count / 3 + 1) * (_itemWH + 2 * _margin);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
