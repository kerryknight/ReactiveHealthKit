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
    
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        __block HKSampleQuery *qry = [self
                                      rac_createSampleQueryWithSampleOfType:sampleType
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
                                          
                                          qry = nil;
                                      }];
        [self executeQuery:qry];
        
        return [RACDisposable disposableWithBlock: ^{
            [self stopQuery:qry];
        }];
    }]
    setNameWithFormat:@"rac_executeSampleQueryWithSampleOfType:%@ predicate:%@ limit:%lu sortDescriptors:%@", sampleType, predicate, (unsigned long)limit, sortDescriptors];
}

- (RACSignal *)rac_executeStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                                  quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                                  options:(HKStatisticsOptions)options
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        __block HKStatisticsQuery *qry = [self
                                          rac_createStatisticsQueryWithQuantityType:quantityType
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
                                              
                                              qry = nil;
                                          }];
        [self executeQuery:qry];
        
        return [RACDisposable disposableWithBlock: ^{
            [self stopQuery:qry];
        }];
    }]
    setNameWithFormat:@"rac_executeStatisticsQueryWithQuantityType:%@ quantitySamplePredicate:%@ options:%lu", quantityType, quantitySamplePredicate, options];
}

#pragma mark - Private Methods
// Developer's Note: adept readers will realize I could've (should've?)
// init'd the 2 query objects within the public methods above, as opposed
// to having 2 additional private methods down here; the only reason these
// methods are separated out here is for unit testing purposes as I was
// having trouble stubbing the query init methods alone in order to
// control the completion blocks while also returning a viable query
// object; PRs with this testing issue solved are welcome! :)
- (HKSampleQuery *)rac_createSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                                predicate:(NSPredicate *)predicate
                                                    limit:(NSUInteger)limit
                                          sortDescriptors:(NSArray *)sortDescriptors
                                               completion:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))completion
{
    
    return [[HKSampleQuery alloc] initWithSampleType:sampleType
                                           predicate:predicate
                                               limit:limit
                                     sortDescriptors:sortDescriptors
                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                          completion(query, results, error);
                                      }];
    
}

- (HKStatisticsQuery *)rac_createStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                                          quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                                          options:(HKStatisticsOptions)options
                                                       completion:(void (^)(HKStatisticsQuery *query, HKStatistics *result, NSError *error))completion
{
    return [[HKStatisticsQuery alloc] initWithQuantityType:quantityType
                                   quantitySamplePredicate:quantitySamplePredicate
                                                   options:options
                                         completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                             completion(query, result, error);
                                         }];
    
}

@end
