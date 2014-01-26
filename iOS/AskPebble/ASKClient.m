//
//  ASKClient.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKClient.h"
#import "ASKQuestion.h"
#import "ASKAnswerChoice.h"

@implementation ASKClient

+ (instancetype)sharedClient
{
    static ASKClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *URL = [NSURL URLWithString:@"http://localhost:3000"];
        sharedClient = [[self alloc] initWithBaseURL:URL];
        sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/plain", @"application/json"]];
    });
    
    return sharedClient;
}

- (void)askQuestion:(NSString *)question withAnswerChoices:(NSArray *)answerChoices completionHandler:(void (^)(NSString *questionID, NSError *error))completionHandler
{
    NSDictionary *parameters = @{@"question": question, @"choices": answerChoices};
    
    [self POST:@"ask" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *response = responseObject;
        completionHandler(response[@"qid"], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];
}

- (void)getQuestionWithID:(NSString *)questionID completionHandler:(void (^)(ASKQuestion *question, NSError *error))completionHandler
{
    NSString *path = [NSString stringWithFormat:@"question/%@", questionID];
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *questionDictionary = responseObject;
        
        ASKQuestion *question = [[ASKQuestion alloc] init];
        question.question = questionDictionary[@"question"];
        
        NSArray *answerChoicesDictionaries = questionDictionary[@"choices"];
        NSMutableArray *answerChoices = [NSMutableArray array];
        for (NSDictionary *answerChoiceDictionary in answerChoicesDictionaries) {
            ASKAnswerChoice *answerChoice = [[ASKAnswerChoice alloc] init];
            
            answerChoice.answerChoice = answerChoiceDictionary[@"choice"];
            answerChoice.responseCount = [answerChoiceDictionary[@"count"] integerValue];
            
            [answerChoices addObject:answerChoice];
        }
        
        question.answerChoices = answerChoices;
        
        completionHandler(question, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];

}

@end
