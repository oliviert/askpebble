//
//  UITableView+IndexPathFromView.h
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (IndexPathFromView)

- (NSIndexPath *)indexPathForCellWithSubview:(UIView *)view;

@end
