//
//  ASKClient.h
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface ASKClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)askQuestion:(NSString *)question withAnswerChoices:(NSArray *)answerChoices completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@end
