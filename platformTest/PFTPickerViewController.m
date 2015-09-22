//
//  PickerViewController.m
//  platformTest
//
//  Created by Pu Guannan on 4/15/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import "PFTPickerViewController.h"

@implementation PickerViewController

- (void) setContent:(NSArray *)content
{
    _content = content;
    [_pickerView reloadAllComponents];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _content.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableDictionary* dict = _content[row];
    return [dict valueForKey:@"Text"];
}

- (NSDictionary*) getSelectedContent
{
    return _content[[_pickerView selectedRowInComponent:0]];
}

@end
