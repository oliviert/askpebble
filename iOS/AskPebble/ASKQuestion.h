//
//  ASKQuestion.h
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASKQuestion : NSObject

@property (nonatomic, copy) NSString *questionID;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSArray *answerChoices;

@end
