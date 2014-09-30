//
//  HKHealthStore+RACExtensions.h
//
//  Created by Kerry Knight on 9/27/14.
//  

#import <HealthKit/HKHealthStore.h>

extern NSString * const HKReactiveHealthKitErrorDomain;
extern const NSUInteger HKReactiveHealthKitDataNotFoundError;

@interface HKHealthStore (RACErrors)

/// Returns a custom error if we weren't able to retrieve a HealthKit data point
///
/// @param The error to check and create a custom 'data point not found' error for
///
/// @return If the error passed in as the parameter exists, it will return
///    the error itself; Otherwise, it'll create a HKReactiveHealthKitDataNotFoundError error
- (NSError *)rac_healthKitErrorForError:(NSError *)error;
@end
