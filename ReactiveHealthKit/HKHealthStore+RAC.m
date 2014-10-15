//
//  HKHealthStore+RACExtensions.m
//
//  Created by Kerry Knight on 9/27/14.
//

#import "HKHealthStore+RAC.h"
#import "ReactiveCocoa.h"
#import "RACExtScope.h"

@implementation HKHealthStore (RAC)

#pragma mark - HKHealthStore
- (RACSignal *)rac_requestAuthorizationToShareTypes:(NSSet *)typesToShare readTypes:(NSSet *)typesToRead
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self requestAuthorizationToShareTypes:typesToShare readTypes:typesToRead completion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_requestAuthorizationToShareTypes:%@ readTypes:%@", typesToShare, typesToRead];
}

- (RACSignal *)rac_saveObject:(HKObject *)object
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self saveObject:object withCompletion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_saveObject:%@", object];
}

- (RACSignal *)rac_saveObjects:(NSArray *)objects
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self saveObjects:objects withCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_saveObjects:%@", objects];
}

- (RACSignal *)rac_deleteObject:(HKObject *)object
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self deleteObject:object withCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_deleteObject:%@", object];
}

- (RACSignal *)rac_dateOfBirth
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSDate *dateOfBirth = [self dateOfBirthWithError:&error];
        
        if (!error) {
            // REMEMBER: just because we don't have an error here, doesn't
            // mean we have data; always check the returned object prior
            // to use as HealthKit won't create an error if a user has not
            // granted us access to the data point we want to retrieve
            [subscriber sendNext:dateOfBirth];
            [subscriber sendCompleted];
        }
        else {
            [subscriber sendError:error];
        }
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_dateOfBirth"];
}

- (RACSignal *)rac_biologicalSex
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        HKBiologicalSexObject *biologicalSexObject = [self biologicalSexWithError:&error];
        
        if (!error) {
            // REMEMBER: just because we don't have an error here, doesn't
            // mean we have data; always check the returned object prior
            // to use as HealthKit won't create an error if a user has not
            // granted us access to the data point we want to retrieve
            [subscriber sendNext:biologicalSexObject];
            [subscriber sendCompleted];
        }
        else {
            [subscriber sendError:error];
        }
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_biologicalSex"];
}

- (RACSignal *)rac_bloodType
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        HKBloodTypeObject *bloodTypeObject = [self bloodTypeWithError:&error];
        
        if (!error) {
            // REMEMBER: just because we don't have an error here, doesn't
            // mean we have data; always check the returned object prior
            // to use as HealthKit won't create an error if a user has not
            // granted us access to the data point we want to retrieve
            [subscriber sendNext:bloodTypeObject];
            [subscriber sendCompleted];
        }
        else {
            [subscriber sendError:error];
        }
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_bloodType"];
}

#pragma mark - HKHealthStore (HKWorkout)
- (RACSignal *)rac_addSamples:(NSArray *)samples toWorkout:(HKWorkout *)workout
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self addSamples:samples toWorkout:workout completion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_addSamples:%@ toWorkout:%@", samples, workout];
}

#pragma mark - HKHealthStore (HKBackgroundDelivery)
- (RACSignal *)rac_enableBackgroundDeliveryForType:(HKObjectType *)type frequency:(HKUpdateFrequency)frequency
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self enableBackgroundDeliveryForType:type frequency:frequency withCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_enableBackgroundDeliveryForType:%@ frequency:%lu", type, (unsigned long)frequency];
}

- (RACSignal *)rac_disableBackgroundDeliveryForType:(HKObjectType *)type
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self disableBackgroundDeliveryForType:type withCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_disableBackgroundDeliveryForType:%@", type];
}

- (RACSignal *)rac_disableAllBackgroundDelivery
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [self disableAllBackgroundDeliveryWithCompletion:^(BOOL success, NSError *error) {
            if (!error) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }]
    setNameWithFormat:@"rac_disableAllBackgroundDelivery"];
}

@end
