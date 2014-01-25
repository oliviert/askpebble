//
//  ASKTextFieldCell.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKTextFieldCell.h"

@interface ASKTextFieldCell ()

@property (nonatomic, assign) BOOL addedConstraints;

@end

@implementation ASKTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self != nil) {
        self.textField = [[UITextField alloc] init];
        
        [self.contentView addSubview:self.textField];
    }
    
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.addedConstraints == NO) {
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_textField);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_textField(290)]-15-|" options:0 metrics:0 views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[_textField(42)]-1-|" options:0 metrics:0 views:views]];
        
        self.addedConstraints = YES;
    }
}

@end
