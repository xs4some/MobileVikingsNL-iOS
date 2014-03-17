//
//  MVLoginService.m
//  Mobile Vikings
//
//  Created by Hendrik Bruinsma on 14-01-14.
//  Copyright (c) 2014 XS4some. All rights reserved.
//

#import "MVLoginService.h"
#import "AppDelegate.h"
#import "MVUserData.h"

#define kLoginUrl @"https://mobilevikings.com/nld/nl/account/login/?"
#define kErrorDomain @"https://www.mobilevikings.com/"

@interface MVLoginService ()

@property (nonatomic, strong) NSString *token;

@end

@implementation MVLoginService

- (id)initServiceWithToken:(NSString *)token passCode:(NSString *)passCode {
    NSDictionary *headers = @{ @"Referer" : kLoginUrl,
                               @"X-Requested-With" : @"XMLHttpRequest",
                               @"X-CSRFToken" : token};
    
    NSDictionary *credentials = [MVUserData credentialsWithPassCode:passCode];
    
    NSDictionary *params = @{ @"csrfmiddlewaretoken" : token,
                              @"username" : [credentials objectForKey:@"userName"],
                              @"password" : [credentials objectForKey:@"passWord"],
                              @"next" : @"/nld/nl"};
    
    self = [super initWithURLString:kLoginUrl params:params httpMethod:@"POST"];

    [self addHeaders:headers];
    [self setPostDataEncoding:MKNKPostDataEncodingTypeURL];
    
    return self;
}

- (void)loginCompletionBlock:(void(^)(void))completionBlock onError:(MKNKErrorBlock)errorBlock {
    [self addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (![completedOperation isCachedResponse]) {
            if ([completedOperation.responseString rangeOfString:@"form-error"].location != NSNotFound) {
                NSError *error = [NSError errorWithDomain:kErrorDomain code:kCFErrorHTTPBadCredentials userInfo:@{@"":@""}];
                [ApplicationDelegate.engine emptyCache];
                errorBlock(error);
            }
            else {
                completionBlock();
            }
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [ApplicationDelegate.engine emptyCache];
        errorBlock(error);
    }];
    
    [ApplicationDelegate.engine enqueueOperation:self forceReload:YES];
}

@end
