//
//  HKHealthStore+RAC_Tests.m
//  HKHealthStore+RAC_Tests
//
//  Created by Kerry Knight on 10/01/2014.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <objc/runtime.h>

@interface ReactiveHealthKitTestHelpers : NSObject
+ (void)swizzleMethods;
+ (void)unswizzleMethods;
@end

@implementation ReactiveHealthKitTestHelpers
// To test some methods of HealthKit, swizzling is needed as I
// was getting entitlement errors attempting to stub the methods
// and run the test on the simulator as HealthKit is only available
// on actual iPhone devices
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


SPEC_BEGIN(HKHealthStore_RAC_Tests)

describe(@"HKHealthStore+RAC", ^{
    __block id mock;
    __block HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    __block NSInteger completionBlockParameterPosition;
    NSError *err = [NSError errorWithDomain:@"" code:999 userInfo:nil];

    void (^successBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^block)(BOOL success, NSError *error);
        // Using NSInvocation, we get access to the concrete block function
        // that has been passed in by the actual test
        // the arguments for the actual method start with 2 (see NSInvocation doc)
        [invocation getArgument:&block atIndex:completionBlockParameterPosition];
        block(YES, nil);
    };
    
    void (^errorBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^block)(BOOL success, NSError *error);
        // Using NSInvocation, we get access to the concrete block function
        // that has been passed in by the actual test
        // the arguments for the actual method start with 2 (see NSInvocation doc)
        [invocation getArgument:&block atIndex:completionBlockParameterPosition];
        block(nil, err);
    };
    
    beforeEach(^{
        mock = [OCMockObject partialMockForObject:healthStore];
        [ReactiveHealthKitTestHelpers swizzleMethods];
    });
    
    afterEach(^{
        [mock stopMocking];
        mock = nil;
        [ReactiveHealthKitTestHelpers unswizzleMethods];
    });
    
    describe(@"rac_requestAuthorizationToShareTypes:readTypes:", ^{
        beforeEach(^{
            // starting at 2, set the parameter count where our
            // completion block parameter is in our stubbed method
            completionBlockParameterPosition = 4;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_requestAuthorizationToShareTypes:nil readTypes:nil];
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
        
        it(@"should return a @YES if successful", ^{
            // stubbed method we want to control the response of
            [[[mock stub] andDo:successBlock] requestAuthorizationToShareTypes:OCMOCK_ANY readTypes:OCMOCK_ANY completion:OCMOCK_ANY];
            
            // method to test
            [[mock rac_requestAuthorizationToShareTypes:nil readTypes:nil] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            // stubbed method we want to control the response of
            [[[mock stub] andDo:errorBlock] requestAuthorizationToShareTypes:OCMOCK_ANY readTypes:OCMOCK_ANY completion:OCMOCK_ANY];
            
            // method to test
            [[mock rac_requestAuthorizationToShareTypes:nil readTypes:nil] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_requestAuthorizationToShareTypes:readTypes:
    
    describe(@"rac_saveObject:", ^{
        beforeEach(^{
            completionBlockParameterPosition = 3;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_saveObject:nil];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] saveObject:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_saveObject:nil] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] saveObject:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_saveObject:nil] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_saveObject:
    
    describe(@"rac_saveObjects:", ^{
        beforeEach(^{
            completionBlockParameterPosition = 3;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_saveObjects:nil];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] saveObjects:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_saveObjects:nil] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] saveObjects:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_saveObjects:nil] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_saveObjects:
    
    describe(@"rac_deleteObject:", ^{
        beforeEach(^{
            completionBlockParameterPosition = 3;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_deleteObject:nil];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] deleteObject:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_deleteObject:nil] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] deleteObject:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_deleteObject:nil] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_deleteObject:
    
    describe(@"rac_dateOfBirth", ^{
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_dateOfBirth];
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
        
        it(@"should return a date if successful", ^{
            [[[mock stub] andReturn:OCMOCK_ANY] dateOfBirthWithError:nil];
            
            [[mock rac_dateOfBirth] subscribeNext:^(NSDate *date) {
                [[date shouldNot] beNil];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andReturn:err] dateOfBirthWithError:nil];
            
            [[mock rac_dateOfBirth] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_dateOfBirth
    
    describe(@"rac_biologicalSex", ^{
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_biologicalSex];
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
        
        it(@"should return a biological sex object if successful", ^{
            [[[mock stub] andReturn:OCMOCK_ANY] biologicalSexWithError:nil];
            
            [[mock rac_biologicalSex] subscribeNext:^(HKBiologicalSexObject *sex) {
                [[sex shouldNot] beNil];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andReturn:err] biologicalSexWithError:nil];
            
            [[mock rac_biologicalSex] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_dateOfBirth
    
    describe(@"rac_bloodType", ^{
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_bloodType];
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
        
        it(@"should return a blood type object if successful", ^{
            [[[mock stub] andReturn:OCMOCK_ANY] bloodTypeWithError:nil];
            
            [[mock rac_bloodType] subscribeNext:^(HKBloodTypeObject *type) {
                [[type shouldNot] beNil];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andReturn:err] bloodTypeWithError:nil];
            
            [[mock rac_bloodType] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_bloodType
    
    describe(@"rac_addSamples:toWorkout:", ^{
        beforeEach(^{
            completionBlockParameterPosition = 4;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_addSamples:OCMOCK_ANY toWorkout:OCMOCK_ANY];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] addSamples:OCMOCK_ANY toWorkout:OCMOCK_ANY completion:OCMOCK_ANY];
            
            [[mock rac_addSamples:OCMOCK_ANY toWorkout:OCMOCK_ANY] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] addSamples:OCMOCK_ANY toWorkout:OCMOCK_ANY completion:OCMOCK_ANY];
            
            [[mock rac_addSamples:OCMOCK_ANY toWorkout:OCMOCK_ANY] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_addSamples:toWorkout:
    
    describe(@"rac_enableBackgroundDeliveryForType:frequency:", ^{
        beforeEach(^{
            completionBlockParameterPosition = 4;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_enableBackgroundDeliveryForType:OCMOCK_ANY frequency:0];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] enableBackgroundDeliveryForType:OCMOCK_ANY frequency:0 withCompletion:OCMOCK_ANY];
            
            [[mock rac_enableBackgroundDeliveryForType:OCMOCK_ANY frequency:0] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] enableBackgroundDeliveryForType:OCMOCK_ANY frequency:0 withCompletion:OCMOCK_ANY];
            
            [[mock rac_enableBackgroundDeliveryForType:OCMOCK_ANY frequency:0] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_enableBackgroundDeliveryForType:frequency:
    
    describe(@"rac_disableBackgroundDeliveryForType:", ^{
        beforeEach(^{
            completionBlockParameterPosition = 3;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_disableBackgroundDeliveryForType:OCMOCK_ANY];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] disableBackgroundDeliveryForType:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_disableBackgroundDeliveryForType:OCMOCK_ANY] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] disableBackgroundDeliveryForType:OCMOCK_ANY withCompletion:OCMOCK_ANY];
            
            [[mock rac_disableBackgroundDeliveryForType:OCMOCK_ANY] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_disableBackgroundDeliveryForType:
    
    describe(@"rac_disableAllBackgroundDelivery", ^{
        beforeEach(^{
            completionBlockParameterPosition = 2;
        });
        
        it(@"should create a new, immutable signal", ^{
            RACSignal *signal = [mock rac_disableAllBackgroundDelivery];
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
        
        it(@"should return a @YES if successful", ^{
            [[[mock stub] andDo:successBlock] disableAllBackgroundDeliveryWithCompletion:OCMOCK_ANY];
            
            [[mock rac_disableAllBackgroundDelivery] subscribeNext:^(id success) {
                [[theValue([success boolValue]) should] beYes];
            }];
        });
        
        it(@"should return an error if unsuccessful", ^{
            [[[mock stub] andDo:errorBlock] disableAllBackgroundDeliveryWithCompletion:OCMOCK_ANY];
            
            [[mock rac_disableAllBackgroundDelivery] subscribeError:^(NSError *error) {
                [[theValue(error.code) should] equal:@(err.code)];
            }];
        });
    }); // rac_disableAllBackgroundDelivery
});

SPEC_END
