//
//  HKHealthStore+RACExtensions.m
//
//  Created by Kerry Knight on 9/27/14.
//

#import "HKHealthStore+RACErrors.h"
#import "ReactiveCocoa.h"
#import "RACExtScope.h"

NSString * const HKReactiveHealthKitErrorDomain = @"HKReactiveHealthKitErrorDomain";
const NSUInteger HKReactiveHealthKitDataNotFoundError = 999;

@implementation HKHealthStore (RACErrors)

- (NSError *)rac_healthKitErrorForError:(NSError *)error
{
    if (error) {
        return error;
    }
    
    // if no error passed in, it means we didn't find the HealthKit
    // data we were looking for or the user has not granted us access
    // to it, so we'll simply create a generic error
    NSMutableDictionary *details = [NSMutableDictionary new];
    details[NSLocalizedDescriptionKey] = @"HealthKit data point not found.";
    return [NSError errorWithDomain:HKReactiveHealthKitErrorDomain code:HKReactiveHealthKitDataNotFoundError userInfo:details];
}

@end
