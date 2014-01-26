//
//  ASKClient.h
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@class ASKQuestion;

@interface ASKClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)askQuestion:(NSString *)question withAnswerChoices:(NSArray *)answerChoices completionHandler:(void (^)(NSString *questionID, NSError *error))completionHandler;
- (void)getQuestionWithID:(NSString *)questionID completionHandler:(void (^)(ASKQuestion *question, NSError *error))completionHandler;

@end
