/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
 Displays age, height, and weight information retrieved from HealthKit.
 
 */

#import "AAPLProfileViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

// A mapping of logical sections of the table view to actual indexes.
typedef NS_ENUM(NSInteger, AAPLProfileViewControllerTableViewIndex) {
    AAPLProfileViewControllerTableViewIndexAge = 0,
    AAPLProfileViewControllerTableViewIndexHeight,
    AAPLProfileViewControllerTableViewIndexWeight
};

@interface AAPLProfileViewController ()

// Note that the user's age is not editable.
@property (nonatomic, weak) IBOutlet UILabel *ageUnitLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageValueLabel;

@property (nonatomic, weak) IBOutlet UILabel *heightValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *heightUnitLabel;

@property (nonatomic, weak) IBOutlet UILabel *weightValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *weightUnitLabel;

@end


@implementation AAPLProfileViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        @weakify(self)
        [[[self.healthStore rac_requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes]
          deliverOn:[RACScheduler mainThreadScheduler]] // ensure we deliver on main thread as HK always uses a background thread
         subscribeNext:^(id success) {
             if ([success boolValue]) {
                 @strongify(self)
                 // Update the user interface based on the current user's health information.
                 [self updateUsersAgeLabel];
                 [self updateUsersHeightLabel];
                 [self updateUsersWeightLabel];
             }
         } error:^(NSError *error) {
             NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
         }];
    }
}

#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType, nil];
}

#pragma mark - Reading HealthKit Data

- (void)updateUsersAgeLabel {
    // Set the user's age unit (years).
    self.ageUnitLabel.text = NSLocalizedString(@"Age (yrs)", nil);
    
    @weakify(self)
    [[[self.healthStore rac_dateOfBirth]
      // ensure we deliver on main thread as HealthKit queries always use a background thread
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSDate *dob) {
         @strongify(self)
         if (dob) {
             // Compute the age of the user.
             NSDate *now = [NSDate date];
             NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dob toDate:now options:NSCalendarWrapComponents];
             NSUInteger usersAge = [ageComponents year];
             self.ageValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersAge) numberStyle:NSNumberFormatterNoStyle];
         } else {
             self.ageValueLabel.text = NSLocalizedString(@"Not available", nil);
             NSLog(@"No user age information has been stored. In your app, try to handle this gracefully.");
         }
         
     } error:^(NSError *error) {
         @strongify(self)
         self.ageValueLabel.text = NSLocalizedString(@"Not available", nil);
         NSLog(@"An error occured fetching the user's age information. In your app, try to handle this gracefully.");
     }];
}

- (void)updateUsersHeightLabel {
    // Fetch user's default height unit in inches.
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitInch;
    NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
    NSString *localizedHeightUnitDescriptionFormat = NSLocalizedString(@"Height (%@)", nil);
    
    self.heightUnitLabel.text = [NSString stringWithFormat:localizedHeightUnitDescriptionFormat, heightUnitString];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    @weakify(self)
    [[[self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:nil]
      // ensure we deliver on main thread as HealthKit queries always use a background thread
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(HKQuantity *mostRecentQuantity) {
         @strongify(self)
         if (mostRecentQuantity) {
             // Determine the height in the required unit.
             HKUnit *heightUnit = [HKUnit inchUnit];
             double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
             self.heightValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
         } else {
             self.heightValueLabel.text = NSLocalizedString(@"Not available", nil);
             NSLog(@"No user height information has been stored. In your app, try to handle this gracefully.");
         }
         
     } error:^(NSError *error) {
         @strongify(self)
         self.heightValueLabel.text = NSLocalizedString(@"Not available", nil);
         NSLog(@"An error occured fetching the user's height information. In your app, try to handle this gracefully.");
     }];
}

- (void)updateUsersWeightLabel {
    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitPound;
    NSString *weightUnitString = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
    NSString *localizedWeightUnitDescriptionFormat = NSLocalizedString(@"Weight (%@)", nil);
    
    self.weightUnitLabel.text = [NSString stringWithFormat:localizedWeightUnitDescriptionFormat, weightUnitString];
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    @weakify(self)
    [[[self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil]
      // ensure we deliver on main thread as HealthKit queries always use a background thread
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(HKQuantity *mostRecentQuantity) {
         @strongify(self)
         if (mostRecentQuantity) {
             // Determine the weight in the required unit.
             HKUnit *weightUnit = [HKUnit poundUnit];
             double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
             self.weightValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
         } else {
             self.weightValueLabel.text = NSLocalizedString(@"Not available", nil);
             NSLog(@"No user weight information has been stored. In your app, try to handle this gracefully.");
         }
     } error:^(NSError *error) {
         @strongify(self)
         self.weightValueLabel.text = NSLocalizedString(@"Not available", nil);
         NSLog(@"An error occured fetching the user's weight information. In your app, try to handle this gracefully.");
     }];
}

#pragma mark - Writing HealthKit Data

- (void)saveHeightIntoHealthStore:(double)height {
    // Save the user's height into HealthKit.
    HKUnit *inchUnit = [HKUnit inchUnit];
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:now endDate:now];
    
    @weakify(self)
    [[self.healthStore rac_saveObject:heightSample]
     subscribeNext:^(id success) {
         if ([success boolValue]) {
             @strongify(self)
             [self updateUsersHeightLabel];
         }
     } error:^(NSError *error) {
         NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
         abort();
     }];
}

- (void)saveWeightIntoHealthStore:(double)weight {
    // Save the user's weight into HealthKit.
    HKUnit *poundUnit = [HKUnit poundUnit];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    @weakify(self)
    [[self.healthStore rac_saveObject:weightSample]
     subscribeNext:^(id success) {
         if ([success boolValue]) {
             @strongify(self)
             [self updateUsersWeightLabel];
         }
     } error:^(NSError *error) {
         NSLog(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
         abort();
     }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AAPLProfileViewControllerTableViewIndex index = (AAPLProfileViewControllerTableViewIndex)indexPath.row;
    
    // We won't allow people to change their date of birth, so ignore selection of the age cell.
    if (index == AAPLProfileViewControllerTableViewIndexAge) {
        return;
    }
    
    // Set up variables based on what row the user has selected.
    NSString *title;
    void (^valueChangedHandler)(double value);
    
    if (index == AAPLProfileViewControllerTableViewIndexHeight) {
        title = NSLocalizedString(@"Your Height", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveHeightIntoHealthStore:value];
        };
    }
    else if (index == AAPLProfileViewControllerTableViewIndexWeight) {
        title = NSLocalizedString(@"Your Weight", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveWeightIntoHealthStore:value];
        };
    }
    
    // Create an alert controller to present.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field to let the user enter a numeric value.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Only allow the user to enter a valid number.
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    
    // Create the "OK" button.
    NSString *okTitle = NSLocalizedString(@"OK", nil);
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        
        double value = textField.text.doubleValue;
        
        valueChangedHandler(value);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [alertController addAction:okAction];
    
    // Create the "Cancel" button.
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [alertController addAction:cancelAction];
    
    // Present the alert controller.
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Convenience

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    
    return numberFormatter;
}

@end