//
//  AdView.h
//  Test
//
//  Created by Nick on 14-2-5.
//  Copyright (c) 2014年 com.onebyte. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AdViewTouchAction)(NSInteger index);
@interface AdView : UIScrollView

@property (nonatomic, copy) AdViewTouchAction adViewTouchAction;

-(void)setAdImageNames:(NSMutableArray *)imageNames;
-(void)addAdImageName:(NSString *)imageName;

-(void)removeAllImageNames;

@end
