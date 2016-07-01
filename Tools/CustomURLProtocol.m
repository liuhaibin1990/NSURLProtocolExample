//
//  CustomURLProtocol.m
//  NSURLProtocolExample
//
//  Created by Ocean on 6/30/16.
//  Copyright © 2016 Ocean. All rights reserved.
//

#import "CustomURLProtocol.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface CustomURLProtocol()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *connection;

@end

@implementation CustomURLProtocol

/**
 这个方法主要是说明你是否打算处理对应的request，如果不打算处理，返回NO，URL Loading System会使用系统默认的行为去处理；如果打算处理，返回YES，然后你就需要处理该请求的所有东西，包括获取请求数据并返回给 URL Loading System。网络数据可以简单的通过NSURLConnection去获取，而且每个NSURLProtocol对象都有一个NSURLProtocolClient实例，可以通过该client将获取到的数据返回给URL Loading System。
 这里有个需要注意的地方，想象一下，当你去加载一个URL资源的时候，URL Loading System会询问CustomURLProtocol是否能处理该请求，你返回YES，然后URL Loading System会创建一个CustomURLProtocol实例然后调用NSURLConnection去获取数据，然而这也会调用URL Loading System，而你在+canInitWithRequest:中又总是返回YES，这样URL Loading System又会创建一个CustomURLProtocol实例导致无限循环。我们应该保证每个request只被处理一次，可以通过+setProperty:forKey:inRequest:标示那些已经处理过的request，然后在+canInitWithRequest:中查询该request是否已经处理过了，如果是则返回NO。
 */

+(BOOL)canInitWithRequest:(NSURLRequest *)request{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

/**
 通常该方法你可以简单的直接返回request，但也可以在这里修改request，比如添加header，修改host等，并返回一个新的request，这是一个抽象方法，子类必须实现。
 */

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    return mutableReqeust;
}

/**
 主要判断两个request是否相同，如果相同的话可以使用缓存数据，通常只需要调用父类的实现。
 */

+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}


- (void)startLoading
{
    NSLog(@"startloading");
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
}

- (void)stopLoading
{
    [self.connection invalidateAndCancel];
}


#pragma mark - NSURLSessionDelegate
/*
 在处理网络请求的时候会调用到该代理方法，我们需要将收到的消息通过client返回给URL Loading System。
 */

//- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//}
//
//- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.client URLProtocol:self didLoadData:data];
//}
//
//- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
//    [self.client URLProtocolDidFinishLoading:self];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    [self.client URLProtocol:self didFailWithError:error];
//}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    
}
-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
}

#pragma mark -- private
+(NSMutableURLRequest*)redirectHostInRequset:(NSMutableURLRequest*)request
{
    if ([request.URL host].length == 0) {
        return request;
    }
    
    NSString *originUrlString = [request.URL absoluteString];
    NSString *originHostString = [request.URL host];
    NSRange hostRange = [originUrlString rangeOfString:originHostString];
    if (hostRange.location == NSNotFound) {
        return request;
    }
    
    //定向到bing搜索主页
    NSString *ip = @"www.tengxun.com";
    
    // 替换host
    NSString *urlString = [originUrlString stringByReplacingCharactersInRange:hostRange withString:ip];
    NSURL *url = [NSURL URLWithString:urlString];
    request.URL = url;
    
    return request;
}

@end
