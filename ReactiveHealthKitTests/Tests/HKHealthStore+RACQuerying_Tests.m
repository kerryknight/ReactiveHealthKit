//
//  HKHealthStore+RACQuerying_Tests.m
//  ReactiveHealthKit
//
//  Created by Kerry Knight on 10/2/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <objc/runtime.h>

@interface HKHealthStore (RACQuerying_Testing)
- (void)rac_createSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                     predicate:(NSPredicate *)predicate
                                         limit:(NSUInteger)limit
                               sortDescriptors:(NSArray *)sortDescriptors
                                    completion:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))completion;

- (void)rac_createStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                           quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                           options:(HKStatisticsOptions)options
                                        completion:(void (^)(HKStatisticsQuery *query, HKStatistics *result, NSError *error))completion;
@end

@interface ReactiveHealthKitQueryTestHelpers : NSObject
+ (void)swizzleSuccessMethods;
+ (void)unswizzleSuccessMethods;
+ (void)swizzleErrorMethods;
+ (void)unswizzleErrorMethods;
@end

@implementation ReactiveHealthKitQueryTestHelpers
+ (void)swizzleSuccessMethods {
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)),
                                   class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_success_rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)));
    
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)),
                                   class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_success_rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)));
}

+ (void)unswizzleSuccessMethods {
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_success_rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)));
    
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_success_rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)));
}

+ (void)swizzleErrorMethods {
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)),
                                   class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_error_rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)));
    
    method_exchangeImplementations(class_getInstanceMethod([HKHealthStore class], @selector(rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)),
                                   class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_error_rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)));
}

+ (void)unswizzleErrorMethods {
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_error_rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(rac_createSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:completion:)));
    
    method_exchangeImplementations(class_getInstanceMethod([ReactiveHealthKitQueryTestHelpers class], @selector(stub_error_rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)),
                                   class_getInstanceMethod([HKHealthStore class], @selector(rac_createStatisticsQueryWithQuantityType:quantitySamplePredicate:options:completion:)));
}

#pragma mark - stubbed methods to swizzle in
- (HKSampleQuery *)stub_success_rac_createSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                          predicate:(NSPredicate *)predicate
                                              limit:(NSUInteger)limit
                                    sortDescriptors:(NSArray *)sortDescriptors
                                         completion:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))completion
{
    HKCorrelationType *foodType = [HKObjectType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood];
    
    __block HKSampleQuery *fakeQuery = [[HKSampleQuery alloc] initWithSampleType:foodType predicate:nil limit:1 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        NSArray *resultArray = @[];
        completion(fakeQuery, resultArray, nil);
    }];
    
    return fakeQuery;
}

- (HKSampleQuery *)stub_error_rac_createSampleQueryWithSampleOfType:(HKSampleType *)sampleType
                                                  predicate:(NSPredicate *)predicate
                                                      limit:(NSUInteger)limit
                                            sortDescriptors:(NSArray *)sortDescriptors
                                                 completion:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))completion
{
    HKCorrelationType *foodType = [HKObjectType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood];
    
    __block HKSampleQuery *fakeQuery = [[HKSampleQuery alloc] initWithSampleType:foodType predicate:nil limit:1 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        NSError *err = [NSError errorWithDomain:@"" code:999 userInfo:nil];
        completion(fakeQuery, nil, err);
    }];
    
    return fakeQuery;
}

- (HKStatisticsQuery *)stub_success_rac_createStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                                        quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                                        options:(HKStatisticsOptions)options
                                                     completion:(void (^)(HKStatisticsQuery *query, HKStatistics *result, NSError *error))completion
{
    HKQuantityType *fakeType = [[HKQuantityType alloc] initWithCoder:nil];
    HKStatisticsQuery *fakeQuery = [[HKStatisticsQuery alloc] initWithQuantityType:fakeType quantitySamplePredicate:nil options:0 completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        
        id fakeStatisticObject = [NSObject new];
        completion(fakeQuery, fakeStatisticObject, nil);
    }];
    
    return fakeQuery;
}

- (HKStatisticsQuery *)stub_error_rac_createStatisticsQueryWithQuantityType:(HKQuantityType *)quantityType
                                        quantitySamplePredicate:(NSPredicate *)quantitySamplePredicate
                                                        options:(HKStatisticsOptions)options
                                                     completion:(void (^)(HKStatisticsQuery *query, HKStatistics *result, NSError *error))completion
{
    HKQuantityType *fakeType = [[HKQuantityType alloc] initWithCoder:nil];
    HKStatisticsQuery *fakeQuery = [[HKStatisticsQuery alloc] initWithQuantityType:fakeType quantitySamplePredicate:nil options:0 completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
       
        NSError *err = [NSError errorWithDomain:@"" code:999 userInfo:nil];
        completion(fakeQuery, nil, err);
    }];
    
    return fakeQuery;
}

@end


SPEC_BEGIN(HKHealthStore_RACQuerying_Tests)

describe(@"HKHealthStore+RACQuerying", ^{
    __block id mock;
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    NSError *err = [NSError errorWithDomain:@"" code:999 userInfo:nil];
    
    beforeEach(^{
        mock = [OCMockObject partialMockForObject:healthStore];
        [ReactiveHealthKitQueryTestHelpers swizzleSuccessMethods];
    });
    
    afterEach(^{
        [ReactiveHealthKitQueryTestHelpers unswizzleSuccessMethods];
        [mock stopMocking];
        mock = nil;
    });
    
    describe(@"rac_executeSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:", ^{
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_executeSampleQueryWithSampleOfType:OCMOCK_ANY predicate:OCMOCK_ANY limit:0 sortDescriptors:OCMOCK_ANY];
            [[signal shouldNot] beNil];
            
            [[theBlock(^{
                [signal performSelector:@selector(sendNext:) withObject:[NSNull null]];
            }) should] raiseWithName:NSInvalidArgumentException];
            
            [[theBlock(^{
                [signal performSelector:@selector(sendError:) withObject:[NSNull null]];
            }) should] raiseWithName:NSInvalidArgumentException];
            
            [[theBlock(^{
                [signal performSelector:@selector(sendCompleted)];
            }) should] raiseWithName:NSInvalidArgumentException];
        });
        
        context(@"query success", ^{
            it(@"should return query and results data and call stopQuery:", ^{
                [[mock rac_executeSampleQueryWithSampleOfType:OCMOCK_ANY predicate:OCMOCK_ANY limit:0 sortDescriptors:OCMOCK_ANY] subscribeNext:^(RACTuple *data) {
                    HKStatisticsQuery *query = data.first;
                    NSArray *results = data.second;
                    
                    [[query shouldNot] beNil];
                    [[results shouldNot] beNil];
                    [[mock should] receive:@selector(stopQuery:)];
                }];
            });
        });

        context(@"query failure", ^{
            it(@"should return an error and call stopQuery:", ^{
                [[mock rac_executeSampleQueryWithSampleOfType:OCMOCK_ANY predicate:OCMOCK_ANY limit:0 sortDescriptors:OCMOCK_ANY] subscribeError:^(NSError *error) {
                    [[theValue(error.code) should] equal:@(err.code)];
                    [[mock should] receive:@selector(stopQuery:)];
                }];
            });
        });
    }); // rac_executeSampleQueryWithSampleOfType:predicate:limit:sortDescriptors:

    describe(@"rac_executeStatisticsQueryWithQuantityType:quantitySamplePredicate:options:", ^{
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_executeStatisticsQueryWithQuantityType:OCMOCK_ANY quantitySamplePredicate:OCMOCK_ANY options:0];
            [[signal shouldNot] beNil];
            
            [[theBlock(^{
                [signal performSelector:@selector(sendNext:) withObject:[NSNull null]];
            }) should] raiseWithName:NSInvalidArgumentException];
            
            [[theBlock(^{
                [signal performSelector:@selector(sendError:) withObject:[NSNull null]];
            }) should] raiseWithName:NSInvalidArgumentException];
            
            [[theBlock(^{
                [signal performSelector:@selector(sendCompleted)];
            }) should] raiseWithName:NSInvalidArgumentException];
        });
        
        context(@"query success", ^{
            it(@"should return query and result data and call stopQuery:", ^{
                [[mock rac_executeStatisticsQueryWithQuantityType:OCMOCK_ANY quantitySamplePredicate:OCMOCK_ANY options:0] subscribeNext:^(RACTuple *data) {
                    HKStatisticsQuery *query = data.first;
                    HKStatistics *result = data.second;
                    
                    [[query shouldNot] beNil];
                    [[result shouldNot] beNil];
                    [[mock should] receive:@selector(stopQuery:)];
                }];
            });
        });
        
        context(@"query failure", ^{
            it(@"should return an error and callStopQuery:", ^{
                [[mock rac_executeStatisticsQueryWithQuantityType:OCMOCK_ANY quantitySamplePredicate:OCMOCK_ANY options:0] subscribeError:^(NSError *error) {
                    [[theValue(error.code) should] equal:@(err.code)];
                    [[mock should] receive:@selector(stopQuery:)];
                }];
            });
        });
    }); // rac_executeStatisticsQueryWithQuantityType:quantitySamplePredicate:options:
});

SPEC_END
