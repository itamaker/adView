//
//  AdView.m
//  Test
//
//  Created by Nick on 14-2-5.
//  Copyright (c) 2014年 com.onebyte. All rights reserved.
//  广告轮播界

#import "AdView.h"
#import "UIImageView+WebCache.h"

#define kAdTimerTimeInterval (2)

@interface AdView ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageNames;
@property (nonatomic, strong) NSMutableArray *adViews;

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation AdView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.currentPage = 0;

        [self startTimer];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    CGSize size = frame.size;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat adViewCount =  self.adViews.count;
    for (int i = 0; i < adViewCount; i++)
    {
        UIImageView *adView = self.adViews[i];
        adView.frame = CGRectMake(x + width * i, y, width, height);
    }
    
    UIView *view = self.superview;
    if (view)
    {
        CGFloat padding = 10;
        CGFloat unit = 16;
        CGFloat pageWidth = unit * adViewCount;
        CGFloat pageHeight = unit;
        CGFloat pageX = CGRectGetMaxX(frame) - padding - pageWidth;
        CGFloat pageY = CGRectGetMaxY(frame) - padding - pageHeight;
        self.pageControl.frame = CGRectMake(pageX, pageY, pageWidth, pageHeight);
        
        [view insertSubview:self.pageControl aboveSubview:self];
    }
    
    self.contentSize = CGSizeMake(width * adViewCount, height);
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX =  scrollView.contentOffset.x;
    CGFloat currentPage =  offsetX / scrollView.frame.size.width;
    self.pageControl.currentPage = currentPage;
    self.currentPage = currentPage;
    
    self.bounces = NO;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self endTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}
#pragma mark - timer

-(void)startTimer
{
    if (self.timer == nil)
    {
        self.timer = [NSTimer timerWithTimeInterval:kAdTimerTimeInterval  target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

-(void)endTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerAction
{
    self.currentPage ++;
    if (self.currentPage >= self.adViews.count) {
        self.currentPage = 0;
    }
    
    CGFloat width = self.frame.size.width;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.contentOffset = CGPointMake(width * weakSelf.currentPage, 0);
    }];
}

-(void)dealloc
{
    [self endTimer];
}

#pragma mark - add imageName

-(void)setAdImageNames:(NSMutableArray *)imageNames
{
  
    [self removeAllImageNames];
    for (NSString *imageName in imageNames)
    {
        [self addAdImageName:imageName];
    }
}

-(void)addAdImageName:(NSString *)imageName
{
    [self.imageNames addObject:imageName];
    
    UIImageView *adView = [[UIImageView alloc] init];
    adView.tag = self.adViews.count;
    [self addSubview:adView];
    [self.adViews addObject:adView];
    
    if ([imageName hasPrefix:@"http"]) {
        [adView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:nil];
    }else{
        adView.image = [UIImage imageNamed:imageName];
    }
    
    adView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(adViewTaped:)];
    [adView addGestureRecognizer:tap];
    
    self.pageControl.numberOfPages ++;
}

-(void)removeAllImageNames
{
    for (UIView *view in self.adViews) {
        [view removeFromSuperview];
    }
    
    self.pageControl.numberOfPages = 0;
    [self.imageNames removeAllObjects];
    [self.adViews removeAllObjects];
}


#pragma mark - 手势操作

-(void)adViewTaped :(UIGestureRecognizer *)ges
{
    UIView *view = ges.view;
    if (self.adViewTouchAction)
    {
        self.adViewTouchAction(view.tag);
    }
}

#pragma mark - lazy load

-(NSMutableArray *)imageNames
{
    if (_imageNames == nil)
    {
        _imageNames = [NSMutableArray array];
    }
    return _imageNames;
}

-(NSMutableArray *)adViews
{
    if (_adViews == nil)
    {
        _adViews = [NSMutableArray array];
    }
    return _adViews;
}

-(UIPageControl *)pageControl
{
    if (_pageControl == nil)
    {
        _pageControl = [[UIPageControl alloc] init];
    }
    return _pageControl;
}


@end
