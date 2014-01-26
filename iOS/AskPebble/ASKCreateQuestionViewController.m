//
//  ASKCreateQuestionViewController.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKCreateQuestionViewController.h"
#import "ASKTextFieldCell.h"
#import "ASKQuestionResultsViewController.h"
#import "UITableView+IndexPathFromView.h"
#import "ASKClient.h"

#define kMaxChoicesCount 4
#define kAnswerChoiceMaxLength 9

@interface ASKCreateQuestionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSMutableArray *answerChoices;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *createQuestionButton;

@property (nonatomic, strong) NSMutableDictionary *textFieldsByIndexPath;
@property (nonatomic, copy) NSIndexPath *activeIndexPath;
@property (nonatomic, weak) UITextField *activeTextField;

- (IBAction)createQuestionButtonWasTapped;

@end

@implementation ASKCreateQuestionViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.answerChoices = [NSMutableArray arrayWithArray:@[@"", @""]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.textFieldsByIndexPath = [NSMutableDictionary dictionary];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Data Validation

- (BOOL)isValidQuestion
{
    if ([self.question length] == 0) {
        return NO;
    }
    
    //only need 2 choices
    for (NSInteger i = 0; i < 2; i++) {
        NSString *answerChoice = self.answerChoices[i];
        
        if ([answerChoice length] == 0) {
            return NO;
        }
    }
    
    for (NSString *answerChoice in self.answerChoices) {
        if ([answerChoice length] > kAnswerChoiceMaxLength) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Reset

- (void)resetUI
{
    self.question = nil;
    self.answerChoices = [NSMutableArray arrayWithArray:@[@"", @""]];
    
    self.createQuestionButton.enabled = [self isValidQuestion];
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)createQuestionButtonWasTapped
{
    NSMutableArray *answerChoices = [NSMutableArray array];
    for (NSString *answerChoice in self.answerChoices) {
        if ([answerChoice length] > 0) {
            [answerChoices addObject:answerChoice];
        }
    }
    
    UINavigationController *resultsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ASKQuestionResultsNavigationController"];
    ASKQuestionResultsViewController *resultsViewController = [resultsNavigationController.viewControllers firstObject];
    
    resultsViewController.question = self.question;
    resultsViewController.answerChoices = answerChoices;
    
    __weak ASKCreateQuestionViewController *weakSelf = self;
    resultsViewController.completionHandler = ^{
        [weakSelf resetUI];
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self presentViewController:resultsNavigationController animated:YES completion:nil];
    [[ASKClient sharedClient] askQuestion:self.question withAnswerChoices:answerChoices completionHandler:^(NSString *questionID, NSError *error) {
        if ([questionID length] > 0) {
            resultsViewController.questionID = questionID;
        }
        else {
            NSLog(@"Error:%@", [error userInfo]);
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        return MIN([self.answerChoices count] + 1, kMaxChoicesCount);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == [self.answerChoices count] && [self.answerChoices count] < kMaxChoicesCount) {
        UITableViewCell *addAnswerChoiceCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        addAnswerChoiceCell.textLabel.text = NSLocalizedString(@"Add Answer Choice", @"");
        addAnswerChoiceCell.textLabel.textAlignment = NSTextAlignmentCenter;
        addAnswerChoiceCell.textLabel.textColor = self.view.tintColor;
        
        return addAnswerChoiceCell;
    }
    else {
        static NSString *reuseIdentifier = @"TextFieldCell";
        
        ASKTextFieldCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        if (textFieldCell == nil) {
            textFieldCell = [[ASKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            
            textFieldCell.textField.delegate = self;
            textFieldCell.textField.clearButtonMode = UITextFieldViewModeAlways;
            
            UILabel *label = [[UILabel alloc] init];
            label.text = @"0/9";
            label.textColor = [UIColor lightGrayColor];
            [label sizeToFit];
            textFieldCell.textField.rightView = label;
            
            textFieldCell.textField.returnKeyType = UIReturnKeyNext;
            textFieldCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        self.textFieldsByIndexPath[indexPath] = textFieldCell.textField;
        
        if (indexPath.section == 0) {
            textFieldCell.textField.placeholder = NSLocalizedString(@"Enter a question...", @"");
            textFieldCell.textField.text = self.question;
            textFieldCell.textField.rightViewMode = UITextFieldViewModeNever;
        }
        else {
            NSString *placeholderFormat = NSLocalizedString(@"answer choice %i", @"");
            textFieldCell.textField.placeholder = [NSString stringWithFormat:placeholderFormat, indexPath.row + 1];
            textFieldCell.textField.text = self.answerChoices[indexPath.row];
            textFieldCell.textField.rightViewMode = UITextFieldViewModeWhileEditing;
            
            UILabel *label = (UILabel *)textFieldCell.textField.rightView;
            label.text = [NSString stringWithFormat:@"%i/%i", [textFieldCell.textField.text length], kAnswerChoiceMaxLength];
        }
        
        if ([indexPath isEqual:self.activeIndexPath] && [textFieldCell.textField isFirstResponder] == NO) {
            [textFieldCell.textField becomeFirstResponder];
        }
        
        return textFieldCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == [self.answerChoices count]) {
        [self.answerChoices addObject:@""];
        
        self.activeIndexPath = indexPath;

        [tableView beginUpdates];
        
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([self.answerChoices count] == kMaxChoicesCount) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        [tableView endUpdates];
        
        self.createQuestionButton.enabled = [self isValidQuestion];
    }
    else {
        UITextField *textField = self.textFieldsByIndexPath[indexPath];
        [textField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCellWithSubview:textField];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    self.activeTextField = textField;
    self.activeIndexPath = indexPath;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
    self.activeIndexPath = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCellWithSubview:textField];
    
    if (indexPath.section == 0) {
        self.question = newString;
    }
    else {
        if ([newString length] > kAnswerChoiceMaxLength) {
            return NO;
        }
        
        [self.answerChoices replaceObjectAtIndex:indexPath.row withObject:newString];
        
        UILabel *label = (UILabel *)textField.rightView;
        label.text = [NSString stringWithFormat:@"%i/%i", [newString length], kAnswerChoiceMaxLength];
    }
    
    self.createQuestionButton.enabled = [self isValidQuestion];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSArray *indexPaths = [[self.textFieldsByIndexPath allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCellWithSubview:textField];
    
    NSInteger currentIndex = [indexPaths indexOfObject:currentIndexPath];
    
    if (currentIndex < [indexPaths count] - 1) {
        NSIndexPath *nextIndexPath = indexPaths[currentIndex + 1];
        UITextField *nextTextField =self.textFieldsByIndexPath[nextIndexPath];
        [nextTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

@end
