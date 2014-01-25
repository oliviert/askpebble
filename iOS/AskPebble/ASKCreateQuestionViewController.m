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

#define kMaxChoicesCount 4

@interface ASKCreateQuestionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSMutableArray *answerChoices;

@property (nonatomic, weak) UITextField *activeTextField;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *createQuestionButton;

- (IBAction)createQuestionButtonWasTapped;

@end

@implementation ASKCreateQuestionViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.answerChoices = [NSMutableArray arrayWithArray:@[@"", @""]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    
    for (NSString *answerChoice in self.answerChoices) {
        if ([answerChoice length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Actions

- (IBAction)createQuestionButtonWasTapped
{
    ASKQuestionResultsViewController *resultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ASKQuestionResultsViewController class])];
    
    [self.navigationController pushViewController:resultsViewController animated:YES];
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
        }
        
        textFieldCell.textField.delegate = self;
        
        if (indexPath.section == 0) {
            textFieldCell.textField.placeholder = NSLocalizedString(@"Enter a question...", @"");
        }
        else {
            NSString *placeholderFormat = NSLocalizedString(@"answer choice %i", @"");
            NSString *placeholder = [NSString stringWithFormat:placeholderFormat, indexPath.row + 1];
            
            textFieldCell.textField.placeholder = placeholder;
        }
        
        return textFieldCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == [self.answerChoices count]) {
        [self.answerChoices addObject:@""];
        
        [tableView beginUpdates];
        
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([self.answerChoices count] == kMaxChoicesCount) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        [tableView endUpdates];
        
        self.createQuestionButton.enabled = [self isValidQuestion];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    
    CGPoint correctedPoint = [self.activeTextField convertPoint:[self.activeTextField bounds].origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    CGPoint correctedPoint = [textField convertPoint:[textField bounds].origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
    
    if (indexPath.section == 0) {
        self.question = newString;
    }
    else {
        [self.answerChoices replaceObjectAtIndex:indexPath.row withObject:newString];
    }
    
    self.createQuestionButton.enabled = [self isValidQuestion];
    
    return YES;
}

@end
