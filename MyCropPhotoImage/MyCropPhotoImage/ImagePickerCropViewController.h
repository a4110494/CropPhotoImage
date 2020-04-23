//
//  ImagePickerCropViewController.h
//  CustomCropPhoto
//
//  Created by 张继明 on 2016/11/17.
//  Copyright © 2016年 Rain. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^maskImageBlock)(UIImage *image);
@interface ImagePickerCropViewController : UIViewController

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, copy) maskImageBlock returnBlock;

-(void)maskCircleImage:(maskImageBlock)block;
@end
