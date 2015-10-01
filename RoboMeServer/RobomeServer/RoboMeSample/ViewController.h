//
//  ViewController.h
//  RoboMeBasicSample
//
//  Copyright (c) 2013 WowWee Group Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RoboMe/RoboMe.h>

@interface ViewController : UIViewController <RoboMeDelegate>
{
    NSString *viewdata;
}

@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (strong, nonatomic) IBOutlet UILabel *Label;

@property (weak, nonatomic) IBOutlet UILabel *edgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chest20cmLabel;
@property (weak, nonatomic) IBOutlet UILabel *chest50cmLabel;
@property (weak, nonatomic) IBOutlet UILabel *cheat100cmLabel;

@property (weak, nonatomic) IBOutlet UIImageView *weatherImage;


@end
