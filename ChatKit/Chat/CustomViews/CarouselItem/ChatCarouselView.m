//
//  ChatCarouselView.m
//  Eva
//
//  Created by Poomalai on 3/26/17.
//  Copyright © 2017 Eva. All rights reserved.
//

#import "ChatCarouselView.h"

@implementation ChatCarouselView

@synthesize scrollView = scrollView;

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    BOOL pointInside = [self pointInside:point
                               withEvent:event];
    
    if (pointInside && scrollView)
    {// if point resides inside this view and UIScrollView object exists
        
        if (CGRectContainsPoint(scrollView.frame, point))
        {// if point resides inside UIScrollView
            
            return scrollView; //[super hitTest:point withEvent:event]; // change
        }
        
        else
        {// if point resides outside UIScrollView
            
            return scrollView; // override to return UIScrollView
        }
    }
    
    return [super hitTest:point withEvent:event]; // do not override
}

- (void)dealloc {
}

@end
