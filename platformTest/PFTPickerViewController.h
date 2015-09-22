//
//  PickerViewController.h
//  platformTest
//
//  Created by Pu Guannan on 4/15/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFTPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *content;
-(void) setContent:(NSArray *)content;
-(NSDictionary*) getSelectedContent;
@end
