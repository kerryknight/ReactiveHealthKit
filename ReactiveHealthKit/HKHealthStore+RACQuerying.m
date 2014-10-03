//
//  HKHealthStore+RACQuerying.m
//
//  Created by Kerry Knight on 9/27/14.
//

#import "HKHealthStore+RACQuerying.h"
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
                                          completion:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                              
                                              if (!error) {
                                                  // REMEMBER: just because we don't have an error here, doesn't
                                                  // mean we have data; always check the returned object prior
                                                  // to use as HealthKit won't create an error if a user has not
                                                  // granted us access to the data point we want to retrieve
                                                  [subscriber sendNext:RACTuplePack(query, results)];
                                                  [subscriber sendCompleted];
                                              }
                                              else {
                                                  [subscriber sendError:error];
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
                                              completion:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                                  
                                                  if (!error) {
                                                      // REMEMBER: just because we don't have an error here, doesn't
                                                      // mean we have data; always check the returned object prior
                                                      // to use as HealthKit won't create an error if a user has not
                                                      // granted us access to the data point we want to retrieve
                                                      [subscriber sendNext:RACTuplePack(query, result)];
                                                      [subscriber sendCompleted];
                                                  }
                                                  else {
                                                      [subscriber sendError:error];
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
                                    completion:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))completion
{
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType
                                                           predicate:predicate
                                                               limit:limit
                                                     sortDescriptors:sortDescriptors
                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                          
                                                          completion(query, results, error);
                                                      }];
    
    [self executeQuery:query];
}

- (void)rac_executeStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                           quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                           options:(HKStatisticsOptions)options
                                        completion:(void (^)(HKStatisticsQuery *query, HKStatistics *result, NSError *error))completion
{
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType
                                                       quantitySamplePredicate:quantitySamplePredicate
                                                                       options:options
                                                             completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                                                 
                                                                 completion(query, result, error);
                                                             }];
    
    [self executeQuery:query];
}

@end
