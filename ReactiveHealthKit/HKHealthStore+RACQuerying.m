//
//  HKHealthStore+RACQuerying.m
//
//  Created by Kerry Knight on 9/27/14.
//

#import "HKHealthStore+RACQuerying.h"
#import "HKHealthStore+RACErrors.h"
#import "ReactiveCocoa.h"
#import "RACExtScope.h"

@implementation HKHealthStore (RACQuerying)

#pragma mark - Public Methods
- (RACSignal *)rac_executeSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                            predicate:(NSPredicate *)predicate
                                                limit:(NSUInteger)limit
                                      sortDescriptors:(NSArray *)sortDescriptors
{
    
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        
        [self rac_executeSampleQueryWithSampleOfType:sampleType
                                           predicate:predicate
                                               limit:limit
                                     sortDescriptors:sortDescriptors
                                          completion:^(NSArray *results, NSError *error) {
                                              // always check the returned object as HealthKit won't create an
                                              // error if a user has not granted us access to the data point
                                              if (results) {
                                                  [subscriber sendNext:results];
                                                  [subscriber sendCompleted];
                                              }
                                              else {
                                                  [subscriber sendError:[self rac_healthKitErrorForError:error]];
                                              }
                                          }];
        
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_executeStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                                  quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                                  options:(HKStatisticsOptions)options
{
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        
        [self rac_executeStatisticsQueryWithQuantityType:quantityType
                                 quantitySamplePredicate:quantitySamplePredicate
                                                 options:options
                                              completion:^(HKStatistics *result, NSError *error) {
                                                  // always check the returned object as HealthKit won't create an
                                                  // error if a user has not granted us access to the data point
                                                  if (result) {
                                                      [subscriber sendNext:result];
                                                      [subscriber sendCompleted];
                                                  }
                                                  else {
                                                      [subscriber sendError:[self rac_healthKitErrorForError:error]];
                                                  }
                                              }];
        
        return (RACDisposable *)nil;
    }];
}

#pragma mark - Private Methods
- (void)rac_executeSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                     predicate:(NSPredicate *)predicate
                                         limit:(NSUInteger)limit
                               sortDescriptors:(NSArray *)sortDescriptors
                                    completion:(void (^)(NSArray *results, NSError *error))completion
{
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                           predicate:predicate
                                                               limit:limit
                                                     sortDescriptors:sortDescriptors
                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                          
                                                          if (error) {
                                                              completion(nil, error);
                                                          } else {
                                                              completion(results, nil);
                                                          }
                                                      }];
    
    [self executeQuery:query];
}

- (void)rac_executeStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                           quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                           options:(HKStatisticsOptions)options
                                        completion:(void (^)(HKStatistics *result, NSError *error))completion
{
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType
                                                       quantitySamplePredicate:quantitySamplePredicate
                                                                       options:options
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                                                 
                                                                 if (error) {
                                                                     completion(nil, error);
                                                                 } else {
                                                                     completion(result, nil);
                                                                 }
                                                             }];
    
    [self executeQuery:query];
}

@end
