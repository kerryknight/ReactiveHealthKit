//
//  ReactiveHealthKitTestHelpers.m
//  ReactiveHealthKit
//
//  Created by Kerry Knight on 10/2/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "ReactiveHealthKitTestHelpers.h"
#import <objc/runtime.h>

@implementation ReactiveHealthKitTestHelpers

// To test some methods of HealthKit, swizzling is needed as I
// was getting entitlement errors attempting to stub the methods
// and run the test on the simulator as HealthKit is only available
// on actual iPhone devices
#pragma mark - Public Methods
+ (void)swizzleMethods {
    // Swizzle HealthKit
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(dateOfBirthWithError:)),
                                   class_getInstanceMethod([ReactiveHealthKitTestHelpers class], @selector(stubDateOfBirthWithError:)));
    
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(biologicalSexWithError:)),
                                   class_getInstanceMethod([ReactiveHealthKitTestHelpers class], @selector(stubBiologicalSexWithError:)));
    
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(bloodTypeWithError:)),
                                   class_getInstanceMethod([ReactiveHealthKitTestHelpers class], @selector(stubBloodTypeWithError:)));
}

+ (void)unswizzleMethods {
    // Unswizzle HealthKit
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitTestHelpers class], @selector(stubDateOfBirthWithError:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(dateOfBirthWithError:)));
    
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitTestHelpers class], @selector(stubBiologicalSexWithError:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(biologicalSexWithError:)));
    
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitTestHelpers class], @selector(stubBloodTypeWithError:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(bloodTypeWithError:)));
}

#pragma mark - Private Methods
- (NSDate *)stubDateOfBirthWithError:(NSError **)error {
    return [NSDate date];
}

- (HKBiologicalSexObject *)stubBiologicalSexWithError:(NSError **)error {
    return [[HKBiologicalSexObject alloc] init];
}

- (HKBloodTypeObject *)stubBloodTypeWithError:(NSError **)error {
    return [[HKBloodTypeObject alloc] init];
}

@end
