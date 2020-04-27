//
//  VBPiePiece_private.h
//  VBPieChart
//
//  Created by Poomalai.
//

#ifndef VBPiePiece_private_h
#define VBPiePiece_private_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Private class
@interface VBPiePieceData : NSObject
@property (nonatomic) NSInteger index;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *value;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *labelColor;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) BOOL accent;
@property (nonatomic) BOOL showAmount;

+ (UIColor*) defaultColors:(NSInteger)index;
+ (VBPiePieceData*) pieceDataWith:(NSDictionary*)object;
@end



#endif /* VBPiePiece_private_h */
