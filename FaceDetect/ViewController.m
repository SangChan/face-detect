//
//  ViewController.m
//  FaceDetect
//
//  Created by SangChan Lee on 12. 9. 20..
//  Copyright (c) 2012년 SangChan Lee. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()
@property(nonatomic,strong) AVCaptureSession *session;
@property(nonatomic,strong) AVCaptureDevice *videoDevice;
@property(nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property(nonatomic,strong) AVCaptureVideoDataOutput *frameOutput;
@end

@implementation ViewController

@synthesize session = _session;
@synthesize videoDevice = _videoDevice;
@synthesize videoInput = _videoInput;
@synthesize frameOutput = _frameOutput;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
