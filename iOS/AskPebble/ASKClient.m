//
//  ASKClient.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKClient.h"

@implementation ASKClient

+ (instancetype)sharedClient
{
    static ASKClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *URL = [NSURL URLWithString:@"http://localhost:3000"];
        sharedClient = [[self alloc] initWithBaseURL:URL];
        sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return sharedClient;
}

- (void)askQuestion:(NSString *)question withAnswerChoices:(NSArray *)answerChoices completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    NSDictionary *parameters = @{@"question": question, @"choices": answerChoices};
    
    [self POST:@"ask" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(YES, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(NO, error);
    }];
}

@end
