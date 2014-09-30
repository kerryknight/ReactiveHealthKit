//
//  HKHealthStore+RACExtensions.h
//
//  Created by Kerry Knight on 9/27/14.
//  

#import <HealthKit/HKHealthStore.h>

@class RACSignal;

@interface HKHealthStore (RAC)
/// Prompts the user to authorize the application for reading and saving objects of the given types.
///
///
/// @see -requestAuthorizationToShareTypes:readTypes:completion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_requestAuthorizationToShareTypes:(NSSet *)typesToShare readTypes:(NSSet *)typesToRead;

/// Saves a single HKObject.
///
///
/// @see -saveObject:withCompletion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_saveObject:(HKObject *)object;

/// Saves an array of HKObjects.
///
///
/// @see -saveObjects:withCompletion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_saveObjects:(NSArray *)objects;

/// Removes an object from the HealthKit database.
///
///
/// @see -deleteObject:withCompletion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_deleteObject:(HKObject *)object;

/// Returns the user's date of birth.
///
///
/// @see -dateOfBirthWithError:
///
/// @return A signal that sends DOB as NSDate
- (RACSignal *)rac_dateOfBirth;

/// Returns an object encapsulating the user's biological sex.
///
///
/// @see -biologicalSexWithError:
///
/// @return A signal that sends user's biological sex as HKBiologicalSexObject
- (RACSignal *)rac_biologicalSex;

/// Returns an object encapsulating the user's blood type.
///
///
/// @see -bloodTypeWithError:
///
/// @return A signal that sends user's blood type as HKBloodTypeObject
- (RACSignal *)rac_bloodType;

#pragma mark - HKHealthStore (HKWorkout)
/// This method associates samples with a given workout
///
///
/// @see -addSamples:toWorkout:completion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_addSamples:(NSArray *)samples toWorkout:(HKWorkout *)workout;

#pragma mark - HKHealthStore (HKBackgroundDelivery)

/// This method enables activation of your app when data of the type is recorded at the cadence specified.
///
///
/// @see -enableBackgroundDeliveryForType:frequency:withCompletion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_enableBackgroundDeliveryForType:(HKObjectType *)type frequency:(HKUpdateFrequency)frequency;

/// This method disables activation of your app for specific data type
///
///
/// @see -disableBackgroundDeliveryForType:withCompletion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_disableBackgroundDeliveryForType:(HKObjectType *)type;

/// This method disables activation of your app for all data types
///
///
/// @see -disableAllBackgroundDeliveryWithCompletion:
///
/// @return A signal that sends success/fail BOOL as an NSNumber
- (RACSignal *)rac_disableAllBackgroundDelivery;

@end
