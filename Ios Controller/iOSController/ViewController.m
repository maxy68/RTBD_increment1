//
//  ViewController.m
//  iOSController
//
//
//  Copyright (c) 2015 umkc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *ipAddress;
@property (strong, nonatomic) IBOutlet UITextField *portNumber;

@end

// Create a Account in the following http://nuancemobiledeveloper.com/public/index.php?task=home for Application keys and other details

const unsigned char SpeechKitApplicationKey[] = {/*Fill your Application Key*/};



@implementation ViewController
@synthesize recordButton,voiceSearch;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
#pragma mark Socket Creation
    //Creation of Socket
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    // Fill your ID and Host
    
    [SpeechKit setupWithID:@"NMDPTRIAL_mahidharvarma_gmail_com20150908153035"
                      host:@"sslsandbox.nmdp.nuancemobility.net"
                      port:    443
                    useSSL:YES
                  delegate:nil];
    SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
    [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [socket disconnect];
}

#pragma mark -
#pragma mark UI functions
- (IBAction)tappedOnConnect:(id)sender {
    
#pragma mark Socket Connection
    NSLog(@"Tapped On Connect");
    if (([_ipAddress.text isEqual:NULL])||([_portNumber.text isEqual:NULL])) {
        NSLog(@"IPAddress or Port is Empty");
    }
    else
    {
        NSError *err = nil;
        if (![socket connectToHost:_ipAddress.text onPort:[_portNumber.text intValue] error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"I goofed: %@", err);
        }
        NSLog(@"%@",_ipAddress.text);
        NSLog(@"%d",[_portNumber.text intValue]);
    }
}

- (IBAction)tappedOnForward:(id)sender {
    [socket writeData:[@"FORWARD" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}

- (IBAction)tappedOnRight:(id)sender {
    [socket writeData:[@"RIGHT" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnBackWard:(id)sender {
    [socket writeData:[@"BACKWARD" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnLeft:(id)sender {
    [socket writeData:[@"LEFT" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnRleft:(id)sender {
    [socket writeData:[@"ROTATE LEFT" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnRright:(id)sender {
    [socket writeData:[@"ROTATE RIGHT" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnHeadUp:(id)sender {
    [socket writeData:[@"HEAD UP" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnHeadDown:(id)sender {
    [socket writeData:[@"HEAD DOWN" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
}
- (IBAction)tappedOnWeather:(id)sender {
    if (_textFromVoice.text) {
        NSString *weath = [NSString stringWithFormat:@"TEMP %@",_textFromVoice.text];
        [socket writeData:[(@"%@",weath) dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
        
    }
    
}
- (IBAction)tappedOnRecipe:(id)sender {
    if (_textFromVoice.text) {
        NSString *food = [NSString stringWithFormat:@"FOOD %@",_textFromVoice.text];
        
        [socket writeData:[(@"%@",food) dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    }
    

}

- (IBAction)tappedOnRecord:(id)sender {
    
    
    
    if (transactionState == TS_RECORDING) {
        [voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE) {
        SKEndOfSpeechDetection detectionType;
        NSString* recoType;
        NSString* langType;
        
        transactionState = TS_INITIAL;
        
        //      alternativesDisplay.text = @"";
        
        /* 'Dictation' is selected */
        detectionType = SKLongEndOfSpeechDetection; /* Dictations tend to be long utterances that may include short pauses. */
        recoType = SKDictationRecognizerType; /* Optimize recognition performance for dictation or message text. */
        langType = @"en_US";
        /* Nuance can also create a custom recognition type optimized for your application if neither search nor dictation are appropriate. */
        
        NSLog(@"Recognizing type:'%@' Language Code: '%@' using end-of-speech detection:%lu.", recoType, langType, (unsigned long)detectionType);
        
        // if (voiceSearch) [voiceSearch release];
        
        voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                               detection:detectionType
                                                language:langType
                                                delegate:self];

}
}
- (IBAction)tappedOnSendCommand:(id)sender {
    [socket writeData:[_textFromVoice.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];

}

# pragma mark -
# pragma mark GCDAsynSocket delegate methods
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Data Written");
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Disconnected %@",err);
}

# pragma mark -
# pragma mark Voice Recogniser

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    //
    if (numOfResults > 0)
    {
        //Result to Text Box
        [_textFromVoice setText:[results firstResult]];
            }
    if (numOfResults > 1)
    {
        //        alternativesDisplay.text = [[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"];
    }
    if (results.suggestion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion"
                                                        message:results.suggestion
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        // [alert release];
        
    }
    
    //  [voiceSearch release];
    // voiceSearch = nil;
}
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    // [alert release];
    
    if (suggestion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion"
                                                        message:suggestion
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //  [alert release];
        
    }
    
    //  [voiceSearch release];
    voiceSearch = nil;
}
- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    
    transactionState = TS_RECORDING;
    [recordButton setTitle:@"Recording..." forState:UIControlStateNormal];
    // [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");
    
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
    //
    transactionState = TS_PROCESSING;
    [recordButton setTitle:@"Processing..." forState:UIControlStateNormal];
}

@end
