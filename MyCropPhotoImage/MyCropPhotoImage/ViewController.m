//
//  ViewController.m
//  MyCropPhotoImage
//
//  Created by 唐兴明 on 2020/4/23.
//  Copyright © 2020 SmartDoll. All rights reserved.
//

#import "ViewController.h"
#import "ViewController.h"
#import "ImagePickerCropViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController
- (IBAction)choosePhoto:(id)sender {
      UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
         imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //     imagePickerController.allowsEditing = true; 如果为true，就不会展现我们自己的裁剪视图了，就无法自定义了
         imagePickerController.delegate = self;
         
         [self presentViewController:imagePickerController animated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
//选取图片后的代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originImage = info[@"UIImagePickerControllerOriginalImage"];
    NSLog(@"info=%@",info);
    ImagePickerCropViewController *vc = [[ImagePickerCropViewController alloc] init];
    vc.originImage = originImage;
    [picker pushViewController:vc animated:true];
    [vc maskCircleImage:^(UIImage *image) {
        NSLog(@"获取到编辑后的图片");
    }];
    
//    NSURL *imageAssetUrl = [info     objectForKey:UIImagePickerControllerReferenceURL];
//    PHFetchResult*result = [PHAsset   fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
//    PHAsset *asset = [result firstObject];
//    PHImageRequestOptions *phImageRequestOptions =   [[PHImageRequestOptions alloc] init];
//    [[PHImageManager defaultManager] requestImageDataForAsset:asset   options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        //imageData
//    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}



@end
