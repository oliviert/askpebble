//
//  ASKQuestionResultsViewController.h
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASKQuestionResultsViewController : UIViewController

@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSArray *answerChoices;
@property (nonatomic, copy) NSString *questionID;

@property (nonatomic, copy) void (^completionHandler)(); //required

@end
