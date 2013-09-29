//
//  GuideViewController.m
//  MapDots
//
//  Created by siteview_mac on 13-9-25.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import "GuideViewController.h"
#import "AppDelegate.h"

@interface GuideViewController ()

@end

@implementation GuideViewController
{
    UIScrollView *helpScrView;
    UIPageControl *pageCtrl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    CGRect frame = self.view.frame;
    
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    // 加载蒙板图片
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    UIImage *image = [UIImage imageNamed:@"Default.png"];
    [imageView1 setImage:image];
//    imageView1.alpha = 0.5f;    // 将透明度设为50%
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height)];
//    [imageView2 setImage:[UIImage imageNamed:@"Default.png"]];
    [imageView2 setImage:image];
//    imageView2.alpha = 0.5f;

    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width * 2, frame.origin.y, frame.size.width, frame.size.height)];
//    [imageView3 setImage:[UIImage imageNamed:@"Default.png"]];
    [imageView3 setImage:image];
//    imageView3.alpha = 0.5f;
    
    helpScrView = [[UIScrollView alloc] initWithFrame:frame];
    
    // 设置全部内容的尺寸，这里帮助图片是3张，所以宽度设为界面宽度*3，高度和界面一致。
    [helpScrView setContentSize:CGSizeMake(frame.size.width * 3, frame.size.height)];
    
    //设为YES时，会按页滑动
    helpScrView.pagingEnabled = YES;
    
    helpScrView.bounces = NO;
    
    [helpScrView setDelegate:self];
    
    //因为我们使用UIPageControl表示页面进度，所以取消UIScrollView自己的进度条。
    helpScrView.showsHorizontalScrollIndicator = NO;
    
    [helpScrView addSubview:imageView1];
    [helpScrView addSubview:imageView2];
    [helpScrView addSubview:imageView3];

    [self.view addSubview:helpScrView];
    
    // 立即体验
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, frame.size.height - 90, frame.size.width, 30);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    
    [button addTarget:self
               action:@selector(buttonPress)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 位置在屏幕最下方。
    pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 60, frame.size.width, 30)];
    
    pageCtrl.numberOfPages = 3;
    pageCtrl.currentPage = 0;
    
    //用户点击UIPageControl的响应函数
    [pageCtrl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageCtrl];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    NSInteger index = offset.x / bounds.size.width;
    if (index > 3) {
        index = 3;
    } else if (index < 0) {
        index = 0;
    }
    [pageCtrl setCurrentPage:index];
}

#pragma mark - IBAction

- (void)pageTurn:(UIPageControl *)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = helpScrView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [helpScrView scrollRectToVisible:rect animated:YES];
}

- (void)buttonPress
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
