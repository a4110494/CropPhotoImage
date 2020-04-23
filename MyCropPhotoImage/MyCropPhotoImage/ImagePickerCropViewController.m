//
//  ImagePickerCropViewController.m
//  CustomCropPhoto
//
//  Created by 张继明 on 2016/11/17.
//  Copyright © 2016年 Rain. All rights reserved.
//

#import "ImagePickerCropViewController.h"
#define CircleRadius 150.0f

@interface ImagePickerCropViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *cropImageView;

@end

@implementation ImagePickerCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = item;
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    self.cropImageView = [[UIImageView alloc] initWithFrame:frame];

    //缩放比例,把宽和高的最小值缩放到圆的直径大小,让图片看起来在圆内
    CGFloat scale = 1.0f;
    CGFloat minFloat = self.originImage.size.width<self.originImage.size.height?self.originImage.size.width:self.originImage.size.height;
    scale = minFloat/(CircleRadius*2);
    self.cropImageView.frame = CGRectMake(0, 0, self.originImage.size.width/scale, self.originImage.size.height/scale);
    
    
    [_cropImageView setImage:self.originImage];
    
    //创建scroll用于缩放和滑动查看图片
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:frame];
    scroll.bounces = YES;
    
    //滑动范围就是scrollview的大小加上图片比圆多出来的部分
    CGFloat contentSizeWidth = scroll.frame.size.width+(_cropImageView.frame.size.width-CircleRadius*2);
    CGFloat contentSizeHeight = scroll.frame.size.height+(_cropImageView.frame.size.height-CircleRadius*2);
    
    //设置scrollview的滑动范围
    scroll.contentSize = CGSizeMake(contentSizeWidth,contentSizeHeight);

    //设置图片在scrollview的滑动范围中心显示
    self.cropImageView.center = CGPointMake(scroll.contentSize.width/2.0, scroll.contentSize.height/2.0);
    //设置scrollview的偏移让图片刚好在view的中间
    scroll.contentOffset = CGPointMake((_cropImageView.frame.size.width-CircleRadius*2)/2.0, (_cropImageView.frame.size.height-CircleRadius*2)/2.0);
    scroll.delegate=self;
    
    //设置最大伸缩比例
       scroll.maximumZoomScale=2.0;
      //设置最小伸缩比例
    scroll.minimumZoomScale=1;
    [self.view addSubview:scroll];
    [scroll addSubview:self.cropImageView];
        
    
    //只添加layer,否则直接添加到view层上的话会导致scroll无法滑动
    [self.view.layer addSublayer:[self maskStyle2:frame]];
    [self drwaCircle];
}


//截取屏幕上的图片大小
- (UIImage *)captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    img = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage, CGRectMake((self.view.center.x-CircleRadius)*2+4, (self.view.center.y-CircleRadius)*2+4, CircleRadius*4-8, CircleRadius*4-8))];
    UIGraphicsEndImageContext();
    img=[self cirCleImage:img];
    return img;
}

- (void)save {
    //保存到相片册
    UIImageWriteToSavedPhotosAlbum([self captureScreen], nil, nil, nil);
    if (_returnBlock) {
        _returnBlock([self captureScreen]);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//向上一个页面传递编辑后的图片
-(void)maskCircleImage:(maskImageBlock)block{
    _returnBlock = [block copy];
}

//剪裁圆形
-(UIImage*)cirCleImage:(UIImage*)image{
    // 1.开启图形上下文
    UIGraphicsBeginImageContext(image.size);

    // 2.描述圆形裁剪区域
     UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];

    // 3.设置裁剪区域
    [clipPath addClip];

    // 4.绘图
     [image drawAtPoint:CGPointZero];

    // 5.取出图片
    image = UIGraphicsGetImageFromCurrentImageContext();

    //  6.关闭上下文
    UIGraphicsEndImageContext();
    return image;
}


//填充圆外部
- (CAShapeLayer *)maskStyle2:(CGRect)rect {
    //
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    CGFloat x = rect.size.width/2.0;
    CGFloat y = rect.size.height/2.0;
    CGFloat radius = CircleRadius;
    //用贝塞尔曲线画圆
    UIBezierPath *cycle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y)
                                                         radius:radius
                                                     startAngle:0.0
                                                       endAngle:2*M_PI
                                                      clockwise:1];
    //添加圆的路径
    [path appendPath:cycle];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [path CGPath];
    
    /*1、填充规则kCAFillRuleEvenOdd,要判断一个点是否在图形内，从该点作任意方向的一条射线，然后检测射线与图形路径的交点的数量。如果结果是奇数则认为点在内部，是偶数则认为点在外部,记得包含rect边框[UIBezierPath bezierPathWithRect:rect]
     2、填充规则 kCAFillRuleNonZero,从0开始计数，路径顺时针穿过射线则计数加1，逆时针穿过射线则计数减1,
     结果为0则是外部,看你绘制路径的时候选择顺时针还是逆时针记得包含rect的边框[UIBezierPath bezierPathWithRect:rect]*/
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.opacity = .5;
    return maskLayer;
}

//添加白色的圆框
-(void)drwaCircle{
    CAShapeLayer *backCircle = [CAShapeLayer layer];
    // 画底
    UIBezierPath *backPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.view.frame.size.width/2.0, (self.view.frame.size.height-64)/2.0) radius:CircleRadius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    backCircle.lineWidth = 4;
    backCircle.strokeColor = [[UIColor whiteColor] CGColor]; // 边缘线的颜色
    backCircle.fillColor = [UIColor clearColor].CGColor;//填充色,不给会默认黑色
    backCircle.opacity = .5;
    backCircle.lineCap = @"round";  // 边缘线的类型
    backCircle.path = backPath.CGPath;
    [self.view.layer addSublayer:backCircle];
}


//返回需要缩放的view
#pragma UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
 {
     return _cropImageView;
 }


//根据图片大小确定Scroll拖动的范围
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    CGFloat contentSizeWidth = _cropImageView.frame.size.height<CircleRadius*2?self.view.frame.size.width:scrollView.frame.size.width+(_cropImageView.frame.size.width-CircleRadius*2);
    CGFloat contentSizeHeight = _cropImageView.frame.size.height<CircleRadius*2?self.view.frame.size.height-64:scrollView.frame.size.height+(_cropImageView.frame.size.height-CircleRadius*2);
     scrollView.contentSize = CGSizeMake(contentSizeWidth,contentSizeHeight);
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidZoom");

}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    NSLog(@"scrollViewWillBeginZooming");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
