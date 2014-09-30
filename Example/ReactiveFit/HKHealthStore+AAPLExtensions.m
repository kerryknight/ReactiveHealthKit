/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Contains shared helper methods on HKHealthStore that are specific to Fit's use cases.
            
*/

#import "HKHealthStore+AAPLExtensions.h"

@implementation HKHealthStore (AAPLExtensions)

#pragma mark - ReactiveHealthKit Additions
- (RACSignal *)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    @weakify(self)
    return [RACSignal createSignal: ^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        [[self rac_executeSampleQueryWithSampleOfType:quantityType predicate:predicate limit:1 sortDescriptors:@[timeSortDescriptor]]
         subscribeNext:^(NSArray *results) {
             if (results) {
                 // If quantity isn't in the database, return nil in the completion block.
                 HKQuantitySample *quantitySample = results.firstObject;
                 HKQuantity *quantity = quantitySample.quantity;
                 [subscriber sendNext:quantity];
             } else {
                 [subscriber sendNext:nil];
             }
             
             [subscriber sendCompleted];
             
         } error:^(NSError *error) {
             [subscriber sendError:error];
         }];
        
        return (RACDisposable *)nil;
    }];
}

@end
