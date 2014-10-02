/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
 Displays energy-related information retrieved from HealthKit.
 
 */

#import "AAPLEnergyViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

@interface AAPLEnergyViewController()

@property (nonatomic, weak) IBOutlet UILabel *activeEnergyBurnedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *restingEnergyBurnedValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *consumedEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *netEnergyValueLabel;

@property (nonatomic) double activeEnergyBurned;
@property (nonatomic) double restingEnergyBurned;
@property (nonatomic) double energyConsumed;
@property (nonatomic) double netEnergy;

@end

@implementation AAPLEnergyViewController

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.refreshControl addTarget:self action:@selector(refreshStatistics) forControlEvents:UIControlEventValueChanged];
    
    [self refreshStatistics];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatistics) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Reading HealthKit Data

- (void)refreshStatistics {
    [self.refreshControl beginRefreshing];
    
    HKQuantityType *energyConsumedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    RACSignal *energyConsumedSignal = [self fetchSumOfSamplesTodayForType:energyConsumedType unit:[HKUnit jouleUnit]];
    RACSignal *energyBurnedSignal = [self fetchSumOfSamplesTodayForType:activeEnergyBurnType unit:[HKUnit jouleUnit]];
    RACSignal *basalBurnSignal = [self fetchTotalBasalBurn];
    
    @weakify(self)
    [[[RACSignal zip:@[energyConsumedSignal, energyBurnedSignal, basalBurnSignal]
              reduce:^id(NSNumber *totalJoulesConsumed, NSNumber *activeEnergyBurned, HKQuantity *basalEnergyBurn) {
                  NSMutableDictionary *data = [@{@"energyConsumed"      : totalJoulesConsumed ?: @0,
                                                 @"activeEnergyBurned"  : activeEnergyBurned ?: @0} mutableCopy];
                  
                  if (basalEnergyBurn)
                      data[@"basalEnergyBurn"] = basalEnergyBurn;
                  
                  return data;
              }]
      // ensure we deliver on main thread as HealthKit queries always use a background thread
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSMutableDictionary *data) {
         @strongify(self)
         
         self.energyConsumed = [data[@"energyConsumed"] doubleValue];
         self.activeEnergyBurned = [data[@"activeEnergyBurned"] doubleValue];
         self.restingEnergyBurned = data[@"basalEnergyBurn"] ? [data[@"basalEnergyBurn"] doubleValueForUnit:[HKUnit jouleUnit]] : 0;
         self.netEnergy = self.energyConsumed - self.activeEnergyBurned - self.restingEnergyBurned;
         
         [self.refreshControl endRefreshing];
     } error:^(NSError *error) {
         NSLog(@"ERROR: %@", error);
         [self.refreshControl endRefreshing];
     }];
}

- (RACSignal *)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit {
    NSPredicate *predicate = [self predicateForSamplesToday];
    
    @weakify(self)
    return [RACSignal createSignal: ^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        [[self.healthStore rac_executeStatisticsQueryWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum]
         subscribeNext:^(NSDictionary *data) {
             
             HKStatistics *result = (HKStatistics *)data[@"result"];
             HKQuantity *sum = [result sumQuantity];
             
             if (sum) {
                 double value = [sum doubleValueForUnit:unit];
                 [subscriber sendNext:[NSNumber numberWithDouble:value]];
             } else {
                 [subscriber sendNext:nil];
             }
             
             [subscriber sendCompleted];
         } error:^(NSError *error) {
             // don't care about the actual error in this case
             // as it could be due to not having access to HK data point
             // or having no data points to report so send a nil
             [subscriber sendNext:nil];
             [subscriber sendCompleted];
         }];
        
        return (RACDisposable *)nil;
    }];
}

// Calculates the user's total basal (resting) energy burn based off of their height, weight, age,
// and biological sex. If there is not enough information, return an error.
- (RACSignal *)fetchTotalBasalBurn {
    NSPredicate *todayPredicate = [self predicateForSamplesToday];
    
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    @weakify(self)
    return [RACSignal createSignal: ^(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        // create individual signals for each of our desired data points; this will allow
        // us to retrieve their values all in parallel, instead of sequentially like the
        // example Apple app does, which in turn requires longer to complete
        RACSignal *weightSignal = [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType predicate:nil];
        RACSignal *heightSignal = [self.healthStore aapl_mostRecentQuantitySampleOfType:heightType predicate:todayPredicate];
        RACSignal *dateOfBirthSignal = [self.healthStore rac_dateOfBirth];
        RACSignal *biologicalSexSignal = [self.healthStore rac_biologicalSex];
        
        @weakify(self)
        // zip: allows us to wait until all signals have sent a value
        [[RACSignal zip:@[weightSignal, heightSignal, dateOfBirthSignal, biologicalSexSignal]
                 reduce:^id(id weight, id height, id dob, id sex) {
                     @strongify(self)
                     // Once we have pulled all of the information without errors, calculate the user's total basal energy burn
                     return [self calculateBasalBurnTodayFromWeight:weight height:height dateOfBirth:dob biologicalSex:sex];
                 }]
         subscribeNext:^(HKQuantity *basalEnergyBurn) {
             if (basalEnergyBurn) {
                 [subscriber sendNext:basalEnergyBurn];
             } else {
                 [subscriber sendNext:nil];
             }
             [subscriber sendCompleted];
         } error:^(NSError *error) {
             // don't care about the actual error in this case
             // as it could be due to not having access to HK data point
             // or having no data points to report so send a nil
             [subscriber sendNext:nil];
             [subscriber sendCompleted];
         }];
        
        return (RACDisposable *)nil;
    }];
}

- (HKQuantity *)calculateBasalBurnTodayFromWeight:(id)weight height:(id)height dateOfBirth:(id)dateOfBirth biologicalSex:(id)biologicalSex {
    // Only calculate Basal Metabolic Rate (BMR) if we have enough information about the user
    if (!weight || !height || !dateOfBirth || !biologicalSex) {
        return nil;
    }
    
    // Note the difference between calling +unitFromString: vs creating a unit from a string with
    // a given prefix. Both of these are equally valid, however one may be more convenient for a given
    // use case.
    double heightInCentimeters = [(HKQuantity *)height doubleValueForUnit:[HKUnit unitFromString:@"cm"]];
    double weightInKilograms = [(HKQuantity *)weight doubleValueForUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo]];
    
    NSDate *now = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:(NSDate *)dateOfBirth toDate:now options:NSCalendarWrapComponents];
    NSUInteger ageInYears = ageComponents.year;
    
    // BMR is calculated in kilocalories per day.
    double BMR = [self calculateBMRFromWeight:weightInKilograms height:heightInCentimeters age:ageInYears biologicalSex:[(HKBiologicalSexObject *)biologicalSex biologicalSex]];
    
    // Figure out how much of today has completed so we know how many kilocalories the user has burned.
    NSDate *startOfToday = [[NSCalendar currentCalendar] startOfDayForDate:now];
    NSDate *endOfToday = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startOfToday options:0];
    
    NSTimeInterval secondsInDay = [endOfToday timeIntervalSinceDate:startOfToday];
    double percentOfDayComplete = [now timeIntervalSinceDate:startOfToday] / secondsInDay;
    
    double kilocaloriesBurned = BMR * percentOfDayComplete;
    
    return [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:kilocaloriesBurned];
}

#pragma mark - Convenience

- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    
    NSDate *startDate = [calendar startOfDayForDate:now];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

/// Returns BMR value in kilocalories per day. Note that there are different ways of calculating the
/// BMR. In this example we chose an arbitrary function to calculate BMR based on weight, height, age,
/// and biological sex.
- (double)calculateBMRFromWeight:(double)weightInKilograms height:(double)heightInCentimeters age:(NSUInteger)ageInYears biologicalSex:(HKBiologicalSex)biologicalSex {
    double BMR;
    // The BMR equation is different between males and females.
    if (biologicalSex == HKBiologicalSexMale) {
        BMR = 66.0 + (13.8 * weightInKilograms) + (5 * heightInCentimeters) - (6.8 * ageInYears);
    }
    else {
        BMR = 655 + (9.6 * weightInKilograms) + (1.8 * heightInCentimeters) - (4.7 * ageInYears);
    }
    
    return BMR;
}

#pragma mark - NSEnergyFormatter

- (NSEnergyFormatter *)energyFormatter {
    static NSEnergyFormatter *energyFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        energyFormatter = [[NSEnergyFormatter alloc] init];
        energyFormatter.unitStyle = NSFormattingUnitStyleLong;
        energyFormatter.forFoodEnergyUse = YES;
        energyFormatter.numberFormatter.maximumFractionDigits = 2;
    });
    
    return energyFormatter;
}

#pragma mark - Setter Overrides

- (void)setActiveEnergyBurned:(double)activeEnergyBurned {
    _activeEnergyBurned = activeEnergyBurned;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.activeEnergyBurnedValueLabel.text = [energyFormatter stringFromJoules:activeEnergyBurned];
}

- (void)setEnergyConsumed:(double)energyConsumed {
    _energyConsumed = energyConsumed;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.consumedEnergyValueLabel.text = [energyFormatter stringFromJoules:energyConsumed];
}

- (void)setRestingEnergyBurned:(double)restingEnergyBurned {
    _restingEnergyBurned = restingEnergyBurned;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.restingEnergyBurnedValueLabel.text = [energyFormatter stringFromJoules:restingEnergyBurned];
}

- (void)setNetEnergy:(double)netEnergy {
    _netEnergy = netEnergy;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.netEnergyValueLabel.text = [energyFormatter stringFromJoules:netEnergy];
}

@end