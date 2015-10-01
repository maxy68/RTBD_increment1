//
//  ViewController.h
//  iOSController
//
//  Created by Mayanka  on 9/9/15.
//  Copyright (c) 2015 umkc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import <SpeechKit/SpeechKit.h>

@interface ViewController : UIViewController <SpeechKitDelegate, SKRecognizerDelegate>
{
 GCDAsyncSocket *socket;
    enum {
        TS_IDLE,
        TS_INITIAL,
        TS_RECORDING,
        TS_PROCESSING,
    } transactionState;
}
@property (strong,readwrite) SKRecognizer* voiceSearch;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UITextField *textFromVoice;

@end

