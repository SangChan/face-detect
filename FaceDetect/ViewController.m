//
//  ViewController.m
//  FaceDetect
//
//  Created by SangChan Lee on 12. 9. 20..
//  Copyright (c) 2012년 SangChan Lee. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *frameOutput;
@property (nonatomic, strong) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic,strong) UIImageView * glasses;
@end

@implementation ViewController

@synthesize session = _session;
@synthesize videoDevice = _videoDevice;
@synthesize videoInput = _videoInput;
@synthesize frameOutput = _frameOutput;
@synthesize imgView = _imgView;
@synthesize context = _context;
@synthesize faceDetector = _faceDetector;
@synthesize glasses = _glasses;

-(CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

-(CIDetector *)faceDetector {
    if (!_faceDetector) {
        NSDictionary *detectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh,CIDetectorAccuracy, nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return _faceDetector;
}

-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage  = [CIImage imageWithCVPixelBuffer:pb];
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage];
    bool faceFound = false;
    for (CIFaceFeature *face in features) {
        NSLog(@"%@",[face description]);
        if (face.hasLeftEyePosition && face.hasRightEyePosition) {
            CGPoint eyeCenter = CGPointMake(face.leftEyePosition.x*0.5+face.rightEyePosition.x*0.5, face.leftEyePosition.y*0.5+face.rightEyePosition.y*0.5);
            
            //set the glasses position
            //double scalex = self.imgView.bounds.size.height/ciImage.extent.size.width;
            //double scaley = self.imgView.bounds.size.width/ciImage.extent.size.height;
            //self.glasses.center = CGPointMake(scaley*eyeCenter.y-self.glasses.bounds.size.height/4.0, scalex*(eyeCenter.x));
            double scalex =self.imgView.bounds.size.height/ciImage.extent.size.width;
            double scaley =self.imgView.bounds.size.width/ciImage.extent.size.height;
            self.glasses.center = CGPointMake(scaley*eyeCenter.y-self.glasses.bounds.size.height/4.0,scalex*(eyeCenter.x));
            
            
            //set the angle
            double deltax = face.leftEyePosition.x-face.rightEyePosition.x;
            double deltay = face.leftEyePosition.y-face.rightEyePosition.y;
            double angle = atan2(deltax, deltay);
            self.glasses.transform = CGAffineTransformMakeRotation(angle+M_PI);
            
            //set size
            double scale = 3.0*sqrt(deltax*deltax+deltay*deltay);
            self.glasses.bounds = CGRectMake(0, 0, scale, scale);
            faceFound = true;
            
            break;
        }
    }
    
    if(faceFound){
        [self.glasses setHidden:NO];
    }else{
        [self.glasses setHidden:YES];
    }
    
    
    // do some filtering
    
//    CIFilter * filter = [CIFilter filterWithName:@"CIHueAdjust"];
//    [filter setDefaults];
//    [filter setValue:ciImage forKey:@"inputImage"];
//    [filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputAngle"];
//    
//    CIImage *result = [filter valueForKey:@"outputImage"];

    CGImageRef ref = [self.context createCGImage:ciImage fromRect:ciImage.extent];
    self.imgView.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(ref);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    
    self.frameOutput = [[AVCaptureVideoDataOutput alloc]init];
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.frameOutput];
    
    [self.frameOutput setSampleBufferDelegate:(id)self queue:dispatch_get_main_queue()];
    
    [self.session startRunning];
    
    self.glasses = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glasses.png"]];
    [self.glasses setHidden:YES];
    [self.view addSubview:self.glasses];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
