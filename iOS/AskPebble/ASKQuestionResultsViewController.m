//
//  ASKQuestionResultsViewController.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKQuestionResultsViewController.h"

#define kSystemDefaultLeftAndRightPadding 20

@interface ASKQuestionResultsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;

@property (nonatomic, strong) NSArray *answerChoices;
@property (nonatomic, strong) NSArray *responseCounts;

@property (nonatomic, strong) NSMutableArray *barWidthConstraints;
@property (nonatomic, assign) BOOL barWidthConstraintsNeedUpdate;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)doneButtonWasTapped;

@end

@implementation ASKQuestionResultsViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.answerChoices = @[@"Pizza", @"Hotdog", @"Lasagna", @"Pasta"];
    self.responseCounts = @[@15, @20, @30, @40];
    
    NSInteger highestResponseCount = 40;
    CGFloat maxBarWidth = self.view.frame.size.width - (kSystemDefaultLeftAndRightPadding * 2);
    CGFloat barHeight = 50;
    
    UIView *previousBar = nil;
    
    NSArray *barColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor]];
    
    self.barWidthConstraints = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [self.answerChoices count]; i++) {
        UILabel *answerChoiceLabel = [[UILabel alloc] init];
        answerChoiceLabel.text = self.answerChoices[i];
        [self.view addSubview:answerChoiceLabel];
        
        UIView *bar = [[UIView alloc] init];
        bar.backgroundColor = barColors[i];
        [self.view addSubview:bar];
        
        NSInteger responseCount = [self.responseCounts[i] integerValue];

        UILabel *responseCountLabel = [[UILabel alloc] init];
        responseCountLabel.text = [NSString stringWithFormat:@"%i", responseCount];
        responseCountLabel.textColor = [UIColor whiteColor];
        responseCountLabel.font = [UIFont boldSystemFontOfSize:17];
        [bar addSubview:responseCountLabel];
        
        CGFloat barWidth = maxBarWidth * ((float)responseCount / (float)highestResponseCount);
        NSDictionary *metrics = @{@"barWidth": @(barWidth), @"barHeight": @(barHeight)};
        
        NSMutableDictionary *views = [NSDictionaryOfVariableBindings(bar, _questionLabel, answerChoiceLabel, responseCountLabel) mutableCopy];
        if (previousBar != nil) {
            [views addEntriesFromDictionary:NSDictionaryOfVariableBindings(previousBar)];
        }
        
        answerChoiceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        bar.translatesAutoresizingMaskIntoConstraints = NO;
        responseCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[answerChoiceLabel]" options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bar]" options:0 metrics:metrics views:views]];
        
        NSLayoutConstraint *barWidthConstraint = [[NSLayoutConstraint constraintsWithVisualFormat:@"[bar(barWidth)]" options:0 metrics:metrics views:views] firstObject];
        [self.view addConstraint:barWidthConstraint];
        [self.barWidthConstraints addObject:barWidthConstraint];
        
        if (previousBar == nil) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_questionLabel]-20-[answerChoiceLabel]" options:0 metrics:metrics views:views]];
        }
        else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousBar]-10-[answerChoiceLabel]" options:0 metrics:metrics views:views]];
        }
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[answerChoiceLabel]-5-[bar(barHeight)]" options:0 metrics:metrics views:views]];
        
        [bar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[responseCountLabel]-10-|" options:0 metrics:metrics views:views]];
        [bar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[responseCountLabel]|" options:0 metrics:metrics views:views]];
        
        previousBar = bar;
    }
}

#pragma mark - Actions

- (IBAction)doneButtonWasTapped
{
    self.completionHandler();
}


#pragma mark - Updating Bar Widths

- (void)updateBarWidthsAnimated:(BOOL)animated
{
    [self updateBarWidthConstraints];
    
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

- (void)updateBarWidthConstraints
{
    if (self.barWidthConstraintsNeedUpdate) {
        NSInteger highestResponseCount = [[self.responseCounts valueForKeyPath:@"@max.self"] integerValue];
        CGFloat maxBarWidth = self.view.frame.size.width - (kSystemDefaultLeftAndRightPadding * 2);
        
        for (NSInteger i = 0; i < [self.answerChoices count]; i++) {
            NSInteger responseCount = [self.responseCounts[i] integerValue];
            CGFloat barWidth = maxBarWidth * ((float)responseCount / (float)highestResponseCount);
            
            NSLayoutConstraint *barWidthConstraint = self.barWidthConstraints[i];
            
            barWidthConstraint.constant = barWidth;
        }
    }
    
    self.barWidthConstraintsNeedUpdate = NO;
}

@end
