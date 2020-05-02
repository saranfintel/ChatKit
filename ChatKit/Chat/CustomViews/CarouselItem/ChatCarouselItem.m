//
//  ChatCarouselItem.m
//  Eva
//
//  Created by Poomalai on 3/26/17.
//  Copyright © 2017 Eva. All rights reserved.
//

#import "ChatCarouselItem.h"

@implementation ChatCarouselItem

@synthesize itemTitle = _strItemTitle;

+ (ChatCarouselItem*)itemWithTitle:(NSString *)title
                           image:(UIImage*)image
                          target:(id)target
                          action:(SEL)action
{
    ChatCarouselItem *item = [ChatCarouselItem buttonWithType:UIButtonTypeCustom];
    
    item.itemTitle =    title;
    item.frame =        CGRectMake((SIZE * 0), 0, SIZE, SIZE);
    item.center =       CGPointMake(((SIZE * 0) + (SIZE/2)), (SIZE/2));
    
//    item.layer.borderColor =    [[UIColor colorWithRed:188.0/255.0 green:215.0/255.0 blue:238.0/255.0 alpha:1.0] CGColor];
//    item.layer.borderWidth =    1.0;
    item.layer.cornerRadius = 10.0;
   /* item.layer.shadowColor =    [[UIColor blackColor] CGColor];
    item.layer.shadowOffset =   CGSizeMake(1.0, 1.0);
    item.layer.shadowOpacity =  0.8;*/
    
//    [item setBackgroundColor:[UIColor colorWithRed:188.0/255.0 green:215.0/255.0 blue:238.0/255.0 alpha:1.0]];
    //[item setBackgroundImage:image forState:UIControlStateNormal];
    
    [item setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [item addTarget:target
             action:action
   forControlEvents:UIControlEventTouchUpInside];
    
    return item;
}

@end
