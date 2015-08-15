//
//  ViewController.m
//  OpenURLDemo
//
//  Created by 杨笑怡 on 15/8/14.
//  Copyright (c) 2015年 YangXiaoYi. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ViewController ()<CLLocationManagerDelegate,UIAlertViewDelegate>

// 位置管理器
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D locationPoint;
@property (nonatomic, assign) NSInteger tag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求用户授权
    [self.locationManager requestAlwaysAuthorization];
    // 设置代理
    self.locationManager.delegate = self;
    // 开始更新用户位置
    [self.locationManager startUpdatingLocation];
    
}

- (IBAction)btnClick:(UIButton *)sender {
    
    UIApplication *app = [UIApplication sharedApplication];
    switch (sender.tag) {
            
    case 0:
            // 调用系统拨号，拨打电话
        [app openURL:[NSURL URLWithString:@"tel://10010"]];
        break;
    case 1:
            // 调用系统信息，发送信息
        [app openURL:[NSURL URLWithString:@"sms://10010"]];
        break;
    case 2:
            // 调用系统邮箱，向指定邮箱发送邮件
        [app openURL:[NSURL URLWithString:@"mailto://12345@qq.com"]];
        break;
    case 3:
            // 调用Safari，访问指定网页
        [app openURL:[NSURL URLWithString:@"https://www.baidu.com"]];
        break;
    default:
        break;
    }
}



- (IBAction)openMaps:(UIButton *)sender
{

    self.tag = sender.tag;
    [self actionSheet:@"地图"];
        
       
}

- (void)openMapWithTag:(NSInteger)tag
{
    UIApplication *app = [UIApplication sharedApplication];
    CGFloat lat = self.locationPoint.latitude;
    CGFloat lng = self.locationPoint.longitude;
    switch (tag) {
        case 0:
            if ([app canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]) {
                [app openURL:[self urlFromString:[NSString stringWithFormat:@"baidumap://map/marker?location=%lf,%lf&title=我的位置&content=你猜我在哪&src=com.heima|OpenURLDemo",lat,lng]]];
            }
            break;
        case 1:
            if([app canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
                [app openURL:[self urlFromString:[NSString stringWithFormat:@"iosamap://viewMap?sourceApplication=OpenURLDemo&poiname=我的位置&lat=%lf&lon=%lf&dev=1",lat,lng]]];
            }
            break;
        case 2:
            if ([app canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
                [app openURL:[NSURL URLWithString:@"comgooglemaps://"]];
            }
            break;
        case 3:

            break;
        case 4:
            if(SYSTEM_VERSION_LESS_THAN(@"6.0")) {
                [app openURL:[self urlFromString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",lat,lng,lat+1,lng+1]]];
            } else {  // 直接调用 iOS 自带的 appleMap
                // 当前坐标
                MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
                // 目的坐标
                MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat + 1, lng + 1) addressDictionary:nil]];
                // 设置目的地名称
                toLocation.name = @"目的地";
                // 打开程序，并设置起始点，终止点，路径方式，显示路径时间
                [MKMapItem openMapsWithItems:@[currentLocation,toLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
            }
            break;
        default:
            break;
    }

}

- (void)actionSheet:(NSString *)str
{
    NSString *title = [NSString stringWithFormat:@"是否显示%@",str];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:title message:@"跳转到地图 APP" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [view show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [self openMapWithTag:self.tag];
    }
}


- (NSURL *)urlFromString:(NSString *)string
{
    NSString *address = string;
    address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:address];
    return url;
}

// 调用 updateLocation时执行这个代理，获取用户当前位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // 获取位置对象
    CLLocation *location = [locations firstObject];
    
    // 获取经纬度
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    // 传值
    self.locationPoint = coordinate;
}

// 懒加载
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        // 创建位置管理器
        _locationManager = [CLLocationManager new];
        // 设置代理
        self.locationManager.delegate = self;
        // 设置位置筛选器，发生一定的位置改变后调用位置更新
        self.locationManager.distanceFilter = 10;
        // 设置精准度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return _locationManager;
}

@end
