//
//  HKHealthStore+RACErrors_Tests.m
//  ReactiveHealthKit
//
//  Created by Kerry Knight on 10/2/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

SPEC_BEGIN(HKHealthStore_RACError_Tests)

describe(@"HKHealthStore+RACErrors", ^{
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    
    describe(@"rac_healthKitErrorForError:", ^{
        it(@"should return same error if error exists", ^{
            NSError *err = [NSError errorWithDomain:@"ReactiveHealthKitErrorDomain" code:500 userInfo:nil];
            
            // method we want to test
            NSError *error = [healthStore rac_healthKitErrorForError:err];
            
            [[error.domain should] equal:err.domain];
            [[theValue(error.code) should] equal:@(err.code)];
        });
        
        it(@"should create a custom error if passed in error is nil", ^{
            NSError *error = [healthStore rac_healthKitErrorForError:nil];
            
            [[error.domain should] equal:HKReactiveHealthKitErrorDomain];
            [[theValue(error.code) should] equal:@(HKReactiveHealthKitDataNotFoundError)];
        });
    }); // rac_healthKitErrorForError:
});

SPEC_END
