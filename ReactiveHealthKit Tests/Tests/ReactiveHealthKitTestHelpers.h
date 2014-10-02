//
//  ReactiveHealthKitTestHelpers.h
//  ReactiveHealthKit
//
//  Created by Kerry Knight on 10/2/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReactiveHealthKitTestHelpers : NSObject

+ (void)swizzleMethods;
+ (void)unswizzleMethods;

@end
