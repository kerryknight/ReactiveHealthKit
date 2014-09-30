//
//  HKHealthStore+RACQuerying.h
//
//  Created by Kerry Knight on 9/27/14.
//

@import HealthKit;

@class RACSignal;

@interface HKHealthStore (RACQuerying)

/// Creates and executes a HealthKit HKSampleQuery
///
///
/// @see private -rac_executeStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:
///
/// @return A signal that sends the NSArray of queried results
- (RACSignal *)rac_executeSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                            predicate:(NSPredicate *)predicate
                                                limit:(NSUInteger)limit
                                      sortDescriptors:(NSArray *)sortDescriptors;

/// Creates and executes a HealthKit HKStatisticsQuery
///
///
/// @see private -rac_executeStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:
///
/// @return A signal that sends the NSArray of queried results
- (RACSignal *)rac_executeStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                                  quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                                  options:(HKStatisticsOptions)options;

@end
