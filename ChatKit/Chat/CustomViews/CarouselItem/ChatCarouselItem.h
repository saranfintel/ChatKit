//
//  ChatCarouselItem.h
//  Eva
//
//  Created by Poomalai on 3/26/17.
//  Copyright © 2017 Eva. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define SIZE 200.0

#define CARDWIDTHSIZE 289.0
#define CARDHEIGHTSIZE 180.0

#define ACCOUNTWIDTHSIZE 280.0
#define ACCOUNTHEIGHTSIZE 180.0

#define DEFAULT_COLOR_SCHEME "1A1A2D"

@interface ChatCarouselItem : UIButton
{
    NSString *_strItemTitle;
}

@property (nonatomic, retain) NSString *itemTitle;

+ (ChatCarouselItem*)itemWithTitle:(NSString *)title
                           image:(UIImage*)image
                          target:(id)target
                          action:(SEL)action;

@end
