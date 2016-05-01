//
//  ViewController.m
//  iBeaconSample
//
//  Created by hirauchi.shinichi on 2016/04/30.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {

        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;

        //[self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];

        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"F65BE0B1-D712-4647-A665-8EC2B4337410"];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                               identifier:@"jp.ne.sapporoworks.testregion"];
    }
}

// ユーザの位置情報の許可状態を確認するメソッド
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        // Beaconのモニタリングを開始
        self.beaconRegion.notifyOnEntry               = YES;
        self.beaconRegion.notifyOnExit                = YES;
        self.beaconRegion.notifyEntryStateOnDisplay   = YES;
        [self.locationManager startMonitoringForRegion:self.beaconRegion]; // 領域監視を開始
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self appendLog:@"Start Monitoring Region"];
    [self.locationManager requestStateForRegion:self.beaconRegion];
}


// iBeacon領域内に既にいるか/いないかの判定
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            [self appendLog:@">Inside"];
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            break;
        case CLRegionStateOutside:
            [self appendLog:@">Outside"];
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
            }
            break;
        case CLRegionStateUnknown:
            [self appendLog:@">Unknown"];
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
            }
            break;
        default:
            break;
    }
}


// 指定した領域に入った場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self appendLog:@">Enter Region"];

    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        // iBeaconとの距離測定を開始
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self appendLog:@">Exit Region"];
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        // iBeaconとの距離測定を開始
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}





// Beacon信号を検出した場合
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;

        NSString *rangeMessage;

        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }

        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%d range:%@",
                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, nearestBeacon.rssi,rangeMessage];
        [self appendLog:message];
    }
}





- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self appendLog:@"Exit Region"];
}


- (void)appendLog:(NSString *)message
{
    _textView.text = [NSString stringWithFormat:@"%@%@\r\n",_textView.text,message];
    NSLog(message);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
