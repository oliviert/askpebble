//
//  UITableView+IndexPathFromView.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "UITableView+IndexPathFromView.h"

@implementation UITableView (IndexPathFromView)

- (NSIndexPath *)indexPathForCellWithSubview:(UIView *)view
{
    CGPoint correctedPoint = [view convertPoint:[view bounds].origin toView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:correctedPoint];
    
    return indexPath;
}

@end
