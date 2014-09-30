//
//  HKHealthStore+RACExtensions.m
//
//  Created by Kerry Knight on 9/27/14.
//

#import "HKHealthStore+RAC.h"
#import "HKHealthStore+RACErrors.h"
#import "ReactiveCocoa.h"
#import "RACExtScope.h"

@implementation HKHealthStore (RAC)

#pragma mark - HKHealthStore
- (RACSignal *)rac_requestAuthorizationToShareTypes:(NSSet *)typesToShare readTypes:(NSSet *)typesToRead
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
                @strongify(self)
        
                [self requestAuthorizationToShareTypes:typesToShare readTypes:typesToRead completion:^(BOOL success, NSError *error) {
                    if (error == nil) {
                        [subscriber sendNext:@(success)];
                        [subscriber sendCompleted];
                    }
                    else {
                        [subscriber sendError:error];
                    }
                }];
        
                return (RACDisposable *)nil;
            }];
}

- (RACSignal *)rac_saveObject:(HKObject *)object
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
                @strongify(self)
        
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
            }];
}

- (RACSignal *)rac_saveObjects:(NSArray *)objects
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        [self saveObjects:objects withCompletion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_deleteObject:(HKObject *)object
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        [self deleteObject:object withCompletion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_dateOfBirth
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        NSError *error = nil;
        NSDate *dateOfBirth = [self dateOfBirthWithError:&error];
        
        // always check the returned object as HealthKit won't create an
        // error if a user has not granted us access to the data point
        if (dateOfBirth) {
            [subscriber sendNext:dateOfBirth];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[self rac_healthKitErrorForError:error]];
        }
        
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_biologicalSex
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        NSError *error = nil;
        HKBiologicalSexObject *biologicalSexObject = [self biologicalSexWithError:&error];
        
        // always check the returned object as HealthKit won't create an
        // error if a user has not granted us access to the data point
        if (biologicalSexObject) {
            [subscriber sendNext:biologicalSexObject];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[self rac_healthKitErrorForError:error]];
        }
        
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_bloodType
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        NSError *error = nil;
        HKBloodTypeObject *bloodTypeObject = [self bloodTypeWithError:&error];
        
        // always check the returned object as HealthKit won't create an
        // error if a user has not granted us access to the data point
        if (bloodTypeObject) {
            [subscriber sendNext:bloodTypeObject];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[self rac_healthKitErrorForError:error]];
        }
        
        return (RACDisposable *)nil;
    }];
}

#pragma mark - HKHealthStore (HKWorkout)
- (RACSignal *)rac_addSamples:(NSArray *)samples toWorkout:(HKWorkout *)workout
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        [self addSamples:samples toWorkout:workout completion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        
        return (RACDisposable *)nil;
    }];
}

#pragma mark - HKHealthStore (HKBackgroundDelivery)
- (RACSignal *)rac_enableBackgroundDeliveryForType:(HKObjectType *)type frequency:(HKUpdateFrequency)frequency
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self enableBackgroundDeliveryForType:type frequency:frequency withCompletion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_disableBackgroundDeliveryForType:(HKObjectType *)type
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self disableBackgroundDeliveryForType:type withCompletion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }];
}

- (RACSignal *)rac_disableAllBackgroundDelivery
{
    @weakify(self)
    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self disableAllBackgroundDeliveryWithCompletion:^(BOOL success, NSError *error) {
            if (error == nil) {
                [subscriber sendNext:@(success)];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
        }];
        return (RACDisposable *)nil;
    }];
}

@end
