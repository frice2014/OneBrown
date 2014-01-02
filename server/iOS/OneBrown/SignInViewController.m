//
//  SignInViewController.m
//  OneBrown
//
//  Created by Benjamin Murphy on 1/2/14.
//  Copyright (c) 2014 Benjamin Murphy. All rights reserved.
//

#import "SignInViewController.h"
#import "LoginLogic.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize data;
@synthesize byteIndex;
@synthesize dataToWrite;
@synthesize userField;
@synthesize passField;
@synthesize inputStream;
@synthesize outputStream;
@synthesize signInButton;
@synthesize overlayView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.frame];
    overlay.backgroundColor = [UIColor clearColor];
    self.overlayView = overlay;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayViewActivated)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.numberOfTouchesRequired = 1;
    [self.overlayView addGestureRecognizer:gestureRecognizer];
    
    self.overlayView.hidden = YES;
    
    [self.view addSubview:self.overlayView];
    
    [self configureUsernameAndPassword];
}

- (void)configureUsernameAndPassword {
    
    UITextField *usernameField = [[UITextField alloc] initWithFrame: CGRectMake(35, 150, 250, 31)];
    UITextField *passwordField = [[UITextField alloc] initWithFrame: CGRectMake(35, 200, 250, 31)];
    
    usernameField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    
    usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    usernameField.placeholder = @"Username or Email";
    passwordField.placeholder = @"Password";
    
    passwordField.secureTextEntry = YES;
    
    usernameField.delegate = self;
    passwordField.delegate = self;
    
    self.userField = usernameField;
    self.passField = passwordField;
    
    [self.view addSubview: usernameField];
    [self.view addSubview: passwordField];
    
    UIButton *signIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [signIn setFrame: CGRectMake(110, 250, 88, 44)];
    [signIn setTitle:@"Sign In" forState:UIControlStateNormal];
    [signIn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    
    signIn.layer.borderWidth = 1.0f;
    signIn.layer.borderColor = [UIColor colorWithRed:0 green:122.0f/255.0f blue:1.0f alpha:1.0f].CGColor;
    signIn.layer.cornerRadius = 8.0f;
    
    self.signInButton = signIn;
    
    [self.view addSubview:signIn];
    
}

- (void)signIn: (id)sender {
    
    BOOL valid = [LoginLogic validateUsername:self.userField.text] && [LoginLogic validatePassword:self.passField.text];
    
    if (valid) {
    
        NSDictionary* JSON = @{@"user" : self.userField.text, @"pass" : self.passField.text};
        
        NSError *e;
        
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSON options:kNilOptions error:&e];
        
        self.dataToWrite = JSONData;
        
        [self initializeConnection];
        
    }
}

- (void)overlayViewActivated {
    [self.userField resignFirstResponder];
    [self.passField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate protocol implementation

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.overlayView.hidden = YES;
    
    BOOL valid = [LoginLogic validateUsername:self.userField.text] && [LoginLogic validatePassword:self.passField.text];
    
    self.signInButton.hidden = (valid) ? YES : NO;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.overlayView.hidden = NO;
}

#pragma mark - Network code

- (void)initializeConnection {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(Nil, (CFStringRef)@"host.com", 4444, &readStream, &writeStream);
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            
            NSLog(@"Opened stream");
            self.byteIndex = 0;
            
            break;
            
        }
        case NSStreamEventHasBytesAvailable: {
            
            if (!self.data) {
                self.data = [NSMutableData data];
            }
            
            if (aStream == self.inputStream) {
                
                uint8_t buffer[1024];
                int len;
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        [data appendBytes:buffer length:len];
                    }
                    else {
                        NSLog(@"No buffer");
                    }
                }
                
            }
            break;
        }
        
        case NSStreamEventHasSpaceAvailable: {
            
            uint8_t *readBytes = (uint8_t *)[self.dataToWrite bytes];
            readBytes += byteIndex;
            int data_length = [self.dataToWrite length];
            int len = ((data_length - byteIndex >= 1024) ? 1024 : (data_length - byteIndex));
            uint8_t buffer[len];
            (void)memcpy(buffer, readBytes, len);
            len = [outputStream write:buffer maxLength:len];
            byteIndex += len;
            break;
            
        }
            
        case NSStreamEventErrorOccurred: {
            NSLog(@"Error occurred %@", [aStream streamError]);
            break;
        }
            
        case NSStreamEventEndEncountered: {
            NSLog(@"Stream ended");
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            if (aStream == self.inputStream) {
                self.inputStream = nil;
            }
            else {
                self.outputStream = nil;
            }
            break;
        }
        default: {
            NSLog(@"Default");
            break;
        }
    }
    
}

@end
