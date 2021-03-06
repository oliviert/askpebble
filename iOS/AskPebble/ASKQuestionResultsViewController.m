//
//  ASKQuestionResultsViewController.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKQuestionResultsViewController.h"
#import "ASKClient.h"
#import "ASKQuestion.h"

#define kSystemDefaultLeftAndRightPadding 20

@interface ASKQuestionResultsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSMutableArray *responseCountLabels;

@property (nonatomic, strong) NSArray *responseCounts;

@property (nonatomic, strong) NSMutableArray *barWidthConstraints;

@property (nonatomic, strong) NSTimer *updateTimer;

- (IBAction)doneButtonWasTapped;

@end

@implementation ASKQuestionResultsViewController

- (NSArray *)responseCounts
{
    if (_responseCounts == nil) {
        NSMutableArray *responseCounts = [NSMutableArray array];
        for (NSInteger i = 0; i < [self.answerChoices count]; i++) {
            [responseCounts addObject:@0];
        }
        self.responseCounts = [responseCounts copy];
    }
    
    return _responseCounts;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat barHeight = 50;
    UIView *previousBar = nil;
    
    NSArray *barColors = @[[UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0], [UIColor colorWithRed:46.0f/255.0f green:204.0f/255.0f blue:113.0f/255.0f alpha:1.0], [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0], [UIColor colorWithRed:155.0f/255.0f green:89.0f/255.0f blue:182.0f/255.0f alpha:1.0]];
    
    self.barWidthConstraints = [NSMutableArray array];
    self.responseCountLabels = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [self.answerChoices count]; i++) {
        UILabel *answerChoiceLabel = [[UILabel alloc] init];
        answerChoiceLabel.text = self.answerChoices[i];
        [self.view addSubview:answerChoiceLabel];
        
        UIView *backgroundBar = [[UIView alloc] init];
        backgroundBar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [self.view addSubview:backgroundBar];
        
        UIView *bar = [[UIView alloc] init];
        bar.backgroundColor = barColors[i];
        [self.view addSubview:bar];
        
        NSInteger responseCount = [self.responseCounts[i] integerValue];

        UILabel *responseCountLabel = [[UILabel alloc] init];
        responseCountLabel.text = [NSString stringWithFormat:@"%i", (int)responseCount];
        responseCountLabel.textColor = [UIColor whiteColor];
        responseCountLabel.font = [UIFont boldSystemFontOfSize:17];
        [bar addSubview:responseCountLabel];
        [self.responseCountLabels addObject:responseCountLabel];
        
        NSDictionary *metrics = @{@"barHeight": @(barHeight)};
        
        NSMutableDictionary *views = [NSDictionaryOfVariableBindings(bar, _questionLabel, answerChoiceLabel, responseCountLabel, backgroundBar) mutableCopy];
        if (previousBar != nil) {
            [views addEntriesFromDictionary:NSDictionaryOfVariableBindings(previousBar)];
        }
        
        answerChoiceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        bar.translatesAutoresizingMaskIntoConstraints = NO;
        responseCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundBar.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[answerChoiceLabel]" options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bar]" options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[backgroundBar(280)]" options:0 metrics:metrics views:views]];
        
        NSLayoutConstraint *barWidthConstraint = [[NSLayoutConstraint constraintsWithVisualFormat:@"[bar(0)]" options:0 metrics:metrics views:views] firstObject];
        [self.view addConstraint:barWidthConstraint];
        [self.barWidthConstraints addObject:barWidthConstraint];
        
        if (previousBar == nil) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_questionLabel]-20-[answerChoiceLabel]" options:0 metrics:metrics views:views]];
        }
        else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousBar]-10-[answerChoiceLabel]" options:0 metrics:metrics views:views]];
        }
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[answerChoiceLabel]-5-[bar(barHeight)]" options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[answerChoiceLabel]-5-[backgroundBar(barHeight)]" options:0 metrics:metrics views:views]];
        
        [bar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[responseCountLabel]-10-|" options:0 metrics:metrics views:views]];
        [bar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[responseCountLabel]|" options:0 metrics:metrics views:views]];
        
        previousBar = bar;
    }
    
    self.questionLabel.text = self.question;
}

#pragma mark - Setting ID

- (void)setQuestionID:(NSString *)questionID
{
    _questionID = [questionID copy];
    
    [self.updateTimer invalidate];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateResponseCounts) userInfo:nil repeats:YES];
}

- (void)updateResponseCounts
{
    [[ASKClient sharedClient] getQuestionWithID:self.questionID completionHandler:^(ASKQuestion *question, NSError *error) {
        if (question == nil) {
            NSLog(@"Error getting question:%@", error);
        }
        
        self.responseCounts = [question.answerChoices valueForKey:@"responseCount"];
        
        /* To test bar graphs
        NSMutableArray *responseCounts = [NSMutableArray array];
        for (int i = 0; i < [self.answerChoices count]; i++) {
            int randomInt = arc4random_uniform(50) + 1;
            [responseCounts addObject:@(randomInt)];
        }
        
        self.responseCounts = responseCounts;
         */
        
        [self updateBarGraphAnimated:YES];
    }];
}

#pragma mark - Actions

- (IBAction)doneButtonWasTapped
{
    [self.updateTimer invalidate];
    
    self.completionHandler();
}


#pragma mark - Updating UI

- (void)updateBarGraphAnimated:(BOOL)animated
{
    [self updateResponseCountLabels];
    [self updateBarWidthsAnimated:animated];
}

- (void)updateResponseCountLabels
{
    for (NSInteger i = 0; i < [self.answerChoices count]; i++) {
        UILabel *responseCountLabel = self.responseCountLabels[i];
        
        responseCountLabel.text = [NSString stringWithFormat:@"%i", [self.responseCounts[i] intValue]];
    }
}

- (void)updateBarWidthsAnimated:(BOOL)animated
{
    [self updateBarWidthConstraints];
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

- (void)updateBarWidthConstraints
{
    NSInteger highestResponseCount = [[self.responseCounts valueForKeyPath:@"@max.self"] integerValue];
    CGFloat maxBarWidth = self.view.frame.size.width - (kSystemDefaultLeftAndRightPadding * 2);
    
    for (NSInteger i = 0; i < [self.answerChoices count]; i++) {
        NSInteger responseCount = [self.responseCounts[i] integerValue];
        CGFloat barWidth = maxBarWidth * ((float)responseCount / (float)highestResponseCount);
        
        if (highestResponseCount == 0) {
            barWidth = 0;
        }
        
        NSLayoutConstraint *barWidthConstraint = self.barWidthConstraints[i];
        barWidthConstraint.constant = barWidth;
    }
}

@end
