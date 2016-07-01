//
//  ViewController.m
//  NSURLProtocolExample
//
//  Created by Ocean on 6/30/16.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "CustomURLProtocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)buttonAction:(id)sender {
    
//    CustomURLProtocol *cus = [[CustomURLProtocol alloc] init];
    
    NSMutableArray *protocolClasses = [[NSMutableArray alloc]init];
    [protocolClasses addObject:[CustomURLProtocol class]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses = protocolClasses;
    
    AFHTTPSessionManager *manage = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:configuration];
    
    
    [manage POST:@"http://api.douban.com/v2/book/isbn/9787505715660" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress)
    {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSLog(@"request suceess:%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"request faile:%@",error.description);
    }];
    
}
@end
