//
//  DimensionalTranslation+CGFloat.h
//  CargoGuruViper
//
//  Created by Виктория on 05.07.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DimensionalTranslation)

+ (NSString *)transferVolume:(NSString *)value From:(NSInteger)startDem to:(NSInteger)endDem;
+ (NSString *)transferWeight:(NSString *)value From:(NSInteger)startDem to:(NSInteger)endDem;

@end
