//
//  ViewController.m
//  RoboMeBasicSample
//
//  Copyright (c) 2013 WowWee Group Limited. All rights reserved.
//

#import "ViewController.h"
#import "ViewController.mm"
#import "GCDAsyncSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFNetworking.h"
#import "AVFoundation/AVFoundation.h"
#import "UIImageView+AFNetworking.h"



#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define PORT 1234


@interface ViewController () {
    dispatch_queue_t socketQueue;
    NSMutableArray *connectedSockets;
    BOOL isRunning;
    
    GCDAsyncSocket *listenSocket;
}
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;


@property (strong, nonatomic) IBOutlet UIWebView *urlWebView;
@property (nonatomic, strong) RoboMe *roboMe;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create RoboMe object
    self.roboMe = [[RoboMe alloc] initWithDelegate: self];
    
    // start listening for events from RoboMe
    [self.roboMe startListening];
    
    // Do any additional setup after loading the view, typically from a nib.
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Setup an array to store all accepted client connections
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    isRunning = NO;
    [self displayText:@"Hello World!!!"];
    NSString *ip=@"The IP address is";
    NSLog(@"ipaddress : %@", [self getIPAddress]);
    [self displayText:FORMAT(@"%@%@",ip,[self getIPAddress])];
    
    [self toggleSocketState];//Starting the Socket
    
    
    
}

// Print out given text to text view
- (void)displayText: (NSString *)text {
    NSString *outputTxt = [NSString stringWithFormat: @"%@\n%@", self.outputTextView.text, text];
    
    // print command to output box
    [self.outputTextView setText: outputTxt];
    
    // scroll to bottom
    [self.outputTextView scrollRangeToVisible:NSMakeRange([self.outputTextView.text length], 0)];
}

#pragma mark - RoboMeConnectionDelegate

// Event commands received from RoboMe
- (void)commandReceived:(IncomingRobotCommand)command {
    // Display incoming robot command in text view
    [self displayText: [NSString stringWithFormat: @"Received: %@" ,[RoboMeCommandHelper incomingRobotCommandToString: command]]];
    
    // To check the type of command from RoboMe is a sensor status use the RoboMeCommandHelper class
    if([RoboMeCommandHelper isSensorStatus: command]){
        // Read the sensor status
        SensorStatus *sensors = [RoboMeCommandHelper readSensorStatus: command];
        
        // Update labels
        [self.edgeLabel setText: (sensors.edge ? @"ON" : @"OFF")];
        [self.chest20cmLabel setText: (sensors.chest_20cm ? @"ON" : @"OFF")];
        [self.chest50cmLabel setText: (sensors.chest_50cm ? @"ON" : @"OFF")];
        [self.cheat100cmLabel setText: (sensors.chest_100cm ? @"ON" : @"OFF")];
    }
}

- (void)volumeChanged:(float)volume {
    if([self.roboMe isRoboMeConnected] && volume < 0.75) {
        [self displayText: @"Volume needs to be set above 75% to send commands"];
    }
}

- (void)roboMeConnected {
    [self displayText: @"RoboMe Connected!"];
}

- (void)roboMeDisconnected {
    [self displayText: @"RoboMe Disconnected"];
}

#pragma mark -
#pragma mark User-Defined Robo Movement

- (NSString *)direction:(NSString *)message {
    
    return @"";
}

- (void)perform:(NSString *)command {
    
    NSString *cmd = [command uppercaseString];
    NSArray *array = [cmd componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    NSLog(@"array is %@",array);
    dispatch_async(dispatch_get_main_queue(), ^{
       
    

    if ([cmd isEqualToString:@"LEFT"]) {
        [self.roboMe sendCommand:kRobot_TurnLeft90Degrees];
        [self displayText:@" Turning Left"];
        
    } else if ([cmd isEqualToString:@"RIGHT"]) {
        [self.roboMe sendCommand: kRobot_TurnRight90Degrees];
        [self displayText:@" Turning Right"];
        
    } else if ([cmd isEqualToString:@"BACKWARD"]) {
        [self.roboMe sendCommand: kRobot_MoveBackwardFastest];
        [self displayText:@" Moving Back"];
    } else if ([cmd isEqualToString:@"FORWARD"]) {
        [self.roboMe sendCommand: kRobot_MoveForwardFastest];
        [self displayText:@" Moving Forward"];
    } else if([cmd isEqualToString:@"STOP"]){
        [self.roboMe sendCommand:kRobot_Stop];
        [self displayText:@"Stopping!!"];
    }
    else if([cmd isEqualToString:@"HEAD UP"]){
        [self.roboMe sendCommand:kRobot_HeadTiltAllUp];
        [self displayText:@"Tilting Up The Head"];
    }
    else if([cmd isEqualToString:@"HEAD DOWN"]){
        [self.roboMe sendCommand:kRobot_HeadTiltAllDown];
        [self displayText:@"Tilting Down The Head"];
    }
    else if([cmd isEqualToString:@"ROTATE LEFT"]){
        [self.roboMe sendCommand:kRobot_TurnLeft180Degrees];
        
    }
    else if([cmd isEqualToString:@"ROTATE RIGHT"]){
        [self.roboMe sendCommand:kRobot_TurnRight180Degrees];
        
    }
    else if([array[0] isEqualToString:@"TEMP"]){
    
         [self.urlWebView loadHTMLString:@"" baseURL:nil];
        NSLog(@"The zip is %@",array[1]);
        NSString *BASEURL = @"http://api.openweathermap.org/data/2.5/weather?zip=";
        NSString *zip = @"64110";
        NSString *urlrest=@",us";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            zip=array[1];
        NSString *url = [NSString stringWithFormat:@"%@%@%@", BASEURL, zip, urlrest];
        NSLog(@"%@", url);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSDictionary   *total =responseObject   ;
            NSArray *array=[responseObject objectForKey:@"weather"];
            NSDictionary *dict=[array objectAtIndex:0];
           
            NSString *Cname= [ total objectForKey:@"name"];
          
           
            NSString  *imageurl=@"http://openweathermap.org/img/w/";
            NSString *filename=@"10d";
            NSString *ext=@".png";
            filename   =[dict objectForKey:@"icon"];
            NSString  *urlnew= [NSString stringWithFormat:@"%@%@%@", imageurl,filename,ext];
            
            NSDictionary *main =[total objectForKey:@"main"];
            NSLog(@"%@",[main objectForKey:@"temp"]);
            NSString *temperature = [main objectForKey:@"temp"];
            NSInteger myint = [temperature integerValue];
            myint=myint-273;
            _Label.text=Cname;
           
            NSString *Descript=[NSString stringWithFormat:@"The Temperature at %@ is %ld Celcius and the weather looks like %@",Cname,(long)myint,[dict objectForKey:@"description" ]];
            [self displayText:FORMAT(@"%@",Descript)];
            [_weatherImage setImageWithURL:([NSURL URLWithString:urlnew]) ];
            self.synthesizer = [[AVSpeechSynthesizer alloc] init];
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:Descript];
            utterance.rate = 0.2;
            [self.synthesizer speakUtterance:utterance];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }];
        
    }
    else if([array[0] isEqualToString:@"FOOD"]){
        NSLog(@"The search tag is %@",array[1]);
        NSString *BASEURL = @"http://food2fork.com/api/search?key=c7ab08246c73625249ed95a6188128df&q=";
        NSString *searchtag = @"chicken+shredded";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        searchtag=array[1];
        NSString *url = [NSString stringWithFormat:@"%@%@", BASEURL, searchtag];
        NSLog(@"%@", url);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
         //   NSDictionary   *total =responseObject   ;
            NSArray *recipearray=[responseObject objectForKey:@"recipes"];
            NSDictionary *toprecipe=[recipearray objectAtIndex:0];
            NSString *recipetitle=[toprecipe objectForKey:@"title"];
            NSLog(@"The Recipe Title is : %@",recipetitle);
            [self displayText:FORMAT(@"\n \n Name: %@",recipetitle)];
            NSString *source_url=[toprecipe objectForKey:@"source_url"];
            NSLog(@"The source url is : %@",source_url);
            NSString *image_url=[toprecipe objectForKey:@"image_url"];
            NSLog(@"The image url is : %@",image_url);
            [_weatherImage setImageWithURL:([NSURL URLWithString:image_url]) ];
            _Label.text=recipetitle;
            NSString *recipe_id=[toprecipe objectForKey:@"recipe_id"];
            NSLog(@"recipe id is%@",recipe_id);
            //_weadesc.text=[dict objectForKey:@"description"];
            NSString *recipebaseurl=@"http://food2fork.com/api/get?key=c7ab08246c73625249ed95a6188128df&rId=";
             NSString *recipeurl = [NSString stringWithFormat:@"%@%@", recipebaseurl, recipe_id];
            NSLog(@"The recipe url is %@",recipeurl);
            [manager GET:recipeurl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                NSDictionary   *totalrecipe =responseObject;
                NSLog(@"total recipe json is %@",totalrecipe);
                NSDictionary *recipejson=[totalrecipe objectForKey:@"recipe"];
                NSLog(@"The recipe json is %@",recipejson);
                NSArray *recipe=[recipejson objectForKey:@"ingredients"];
                
                NSString *recipesource_url=[recipejson objectForKey:@"source_url"];
                NSURL *url=[NSURL URLWithString:recipesource_url];
                NSURLRequest *urlrequest = [NSURLRequest requestWithURL:url];
                [_urlWebView loadRequest:urlrequest];
                
               
                [self displayText:FORMAT(@"The Source URL is %@ \n Ingredients Required:- \n",recipesource_url)];
                for (int i=0; i<(sizeof(recipe)); i++) {
               
                    
                    [self displayText:FORMAT(@"%d) %@",i+1,recipe[i])];
                }
                
                }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:[error description]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil, nil];
                     [alert show];
                 }];
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }];
        
    }

    
    });

    

}

#pragma mark - Button callbacks

// The methods below send the desired command to RoboMe.
// Typically you would want to start a timer to repeatly send the
// command while the button is held down. For simplicity this wasn't
// included however if you do decide to implement this we recommand
// sending commands every 500ms for smooth movement.
// See RoboMeCommandHelper.h for a full list of robot commands
- (IBAction)moveForwardBtnPressed:(UIButton *)sender {
    // Adds command to the queue to send to the robot
    [self.roboMe sendCommand: kRobot_MoveForwardFastest];
}

- (IBAction)moveBackwardBtnPressed:(UIButton *)sender {
    [self.roboMe sendCommand: kRobot_MoveBackwardFastest];
}

- (IBAction)turnLeftBtnPressed:(UIButton *)sender {
    [self.roboMe sendCommand: kRobot_TurnLeftFastest];
}

- (IBAction)turnRightBtnPressed:(UIButton *)sender {
    [self.roboMe sendCommand: kRobot_TurnRightFastest];
}

- (IBAction)headUpBtnPressed:(UIButton *)sender {
    [self.roboMe sendCommand: kRobot_HeadTiltAllUp];
}

- (IBAction)headDownBtnPressed:(UIButton *)sender {
    [self.roboMe sendCommand: kRobot_HeadTiltAllDown];
}
#pragma mark -
#pragma mark Socket

- (void)toggleSocketState
{
    if(!isRunning)
    {
        NSError *error = nil;
        if(![listenSocket acceptOnPort:PORT error:&error])
        {
            [self log:FORMAT(@"Error starting server: %@", error)];
            return;
        }
        
        [self displayText:FORMAT(@"Server started on port : %hu",[listenSocket localPort])];
        [self log:FORMAT(@"Echo server started on port %hu", [listenSocket localPort])];
        isRunning = YES;
    }
    else
    {
        // Stop accepting connections
        [listenSocket disconnect];
        
        // Stop any client connections
        @synchronized(connectedSockets)
        {
            NSUInteger i;
            for (i = 0; i < [connectedSockets count]; i++)
            {
                // Call disconnect on the socket,
                // which will invoke the socketDidDisconnect: method,
                // which will remove the socket from the list.
                [[connectedSockets objectAtIndex:i] disconnect];
            }
        }
        
        [self log:@"Stopped Echo server"];
        isRunning = false;
    }
}

- (void)log:(NSString *)msg {
    NSLog(@"%@", msg);
}


- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

#pragma mark -
#pragma mark GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    
    @synchronized(connectedSockets)
    {
        [connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [self displayText: [NSString stringWithFormat: @"Accepted Client: %@:%hu" ,host,port]];
            [self log:FORMAT(@"Accepted client %@:%hu", host, port)];
            
        }
    });
    
    NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
    
    [newSocket readDataWithTimeout:READ_TIMEOUT tag:0];
    newSocket.delegate = self;
    
    //    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    
    if (tag == ECHO_MSG)
    {
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"== didReadData %@ ==", sock.description);
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self log:msg];
    [self perform:msg];
    [sock readDataWithTimeout:READ_TIMEOUT tag:0];
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT)
    {
        NSString *warningMsg = @"Are you still there?\r\n";
        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
        
        return READ_TIMEOUT_EXTENSION;
    }
    
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != listenSocket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [self log:FORMAT(@"Client Disconnected")];
            }
        });
        
        @synchronized(connectedSockets)
        {
            [connectedSockets removeObject:sock];
        }
    }
}

@end
