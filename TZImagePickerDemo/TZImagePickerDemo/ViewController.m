//
//  ViewController.m
//  TZImagePickerDemo
//
//  Created by 李静 on 2019/7/30.
//  Copyright © 2019 gxsn. All rights reserved.
//

#import "ViewController.h"

#import "MediaURLShow/MediaURLShowViewController.h"
#import "MediaShowTableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *tableArray;
@end

@implementation ViewController
-(UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
        [_tableView registerClass:[MediaShowTableViewCell class] forCellReuseIdentifier:@"MediaShowTableViewCellID"];
    }
    return _tableView;
}
- (NSArray *)tableArray {
    if (_tableArray == nil) {
        _tableArray = @[@"URL展示",@"cell中展示1",@"cell中展示2"];
    }
    return _tableArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 || indexPath.row == 2) {
        MediaShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaShowTableViewCellID"];
        cell.pushImgPicker = ^(TZImagePickerController *imagePickerController) {
             [self presentViewController:imagePickerController animated:YES completion:nil];
        };
        cell.reloadCell = ^{
            [self.tableView reloadData];
        };
        cell.pushGifPreviewVC = ^(TZGifPhotoPreviewController *gifPreviewVC) {
            [self presentViewController:gifPreviewVC animated:YES completion:nil];
        };
        cell.pushVideoPlayer = ^(TZVideoPlayerController *videoPlayerVC) {
            [self presentViewController:videoPlayerVC animated:YES completion:nil];
        };
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    cell.textLabel.text = self.tableArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[MediaURLShowViewController new] animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[MediaShowTableViewCell class]]) {
        MediaShowTableViewCell *mediaCell = [tableView cellForRowAtIndexPath:indexPath];
        return [mediaCell cellHeight];
    }
    return 44.0f;
}
@end
