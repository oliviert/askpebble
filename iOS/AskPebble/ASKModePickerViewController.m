//
//  ASKModePickerViewController.m
//  AskPebble
//
//  Created by Adrien on 1/25/14.
//  Copyright (c) 2014 Adrien. All rights reserved.
//

#import "ASKModePickerViewController.h"

@interface ASKModePickerViewController ()

@end

@implementation ASKModePickerViewController

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSLog(@"push ask");
    }
    else if (indexPath.row == 1) {
        NSLog(@"push respond");
    }
}

@end
