//
//  ViewController.m
//  FaceDetect
//
//  Created by SangChan Lee on 12. 9. 20..
//  Copyright (c) 2012년 SangChan Lee. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *frameOutput;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) UIImageView * glasses;
@property (nonatomic, strong) UIView * leftEyeView;
@property (nonatomic, strong) UIView * rightEyeView;
@property (nonatomic, strong) UIView * mouthView;
@property (nonatomic, strong) UIView * faceView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) IBOutlet UIView *preview;
@end

@implementation ViewController

@synthesize session = _session;
@synthesize videoDevice = _videoDevice;
@synthesize videoInput = _videoInput;
@synthesize frameOutput = _frameOutput;
@synthesize context = _context;
@synthesize faceDetector = _faceDetector;
@synthesize glasses = _glasses;
@synthesize preview = _preview;
@synthesize previewLayer = _previewLayer;
@synthesize leftEyeView = _leftEyeView;
@synthesize rightEyeView = _rightEyeView;
@synthesize mouthView = _mouthView;

-(CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

#define degreesToRadians(degrees) ((degrees)/180.0 * M_PI)

-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage  = [[CIImage alloc]initWithCVPixelBuffer:pb options:(__bridge NSDictionary*)attachments];
    if (attachments) {
        CFRelease(attachments);
    }
    
//    CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
//    [scaleFilter setValue:ciImage forKey:@"inputImage"];
//    [scaleFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputScale"];
//    [scaleFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputAspectRatio"];
//    CIImage *finalImage = [scaleFilter valueForKey:@"outputImage"];
    
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6]
                                                    forKey:CIDetectorImageOrientation]];
    
    BOOL faceFound = NO;
    for (CIFaceFeature *face in features) {
        //NSLog(@"%@",[face description]);
        
        CGRect faceRect = [face bounds];
        CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
        
        CGFloat widthScaleBy = self.preview.bounds.size.width / ciImage.extent.size.height;
		CGFloat heightScaleBy = self.preview.bounds.size.height / ciImage.extent.size.width;
        
        faceRect.size.width *= widthScaleBy;
		faceRect.size.height *= heightScaleBy;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;
        
        
        NSLog(@"face x = %f, y = %f, w = %f , h = %f",face.bounds.origin.x,face.bounds.origin.y
              ,face.bounds.size.width,face.bounds.size.height);
        
        
        [self.faceView setFrame:faceRect];
        [self.faceView setHidden:NO];
//        if (face.hasLeftEyePosition) {
//            NSLog(@"leftEye x = %f, y = %f",face.leftEyePosition.x,face.leftEyePosition.y);
//            CGRect leftEye = CGRectMake(face.leftEyePosition.y, face.leftEyePosition.x
//                                        , 4, 4);
//            [self.leftEyeView setFrame:leftEye];
//            //[self.leftEyeView setTransform:CGAffineTransformMakeRotation(degreesToRadians(180))];
//            [self.leftEyeView setHidden:!face.hasLeftEyePosition];
//            
//        }
//        
//        if (face.hasRightEyePosition) {
//            NSLog(@"rightEye x = %f, y = %f",face.rightEyePosition.x,face.rightEyePosition.y);
//            CGRect rightEye = CGRectMake(face.rightEyePosition.y, face.rightEyePosition.x
//                                        , 4, 4);
//            [self.rightEyeView setFrame:rightEye];
//            //[self.rightEyeView setTransform:CGAffineTransformMakeRotation(degreesToRadians(180))];
//            [self.rightEyeView setHidden:!face.hasRightEyePosition];
//            
//        }
//        
//        if (face.hasMouthPosition) {
//            NSLog(@"Mouth x = %f, y = %f",face.mouthPosition.x,face.mouthPosition.y);
//            CGRect mouth = CGRectMake(face.mouthPosition.y, face.mouthPosition.x
//                                        , 4, 4);
//            [self.mouthView setFrame:mouth];
//            //[self.mouthView setTransform:CGAffineTransformMakeRotation(degreesToRadians(180))];
//            [self.mouthView setHidden:!face.hasMouthPosition];
//            
//        }
        
        if (face.hasTrackingID) {
            NSLog(@"tracking ID = %d",face.trackingID);
        }
        if (face.hasLeftEyePosition && face.hasRightEyePosition) {
            CGPoint eyeCenter = CGPointMake(face.leftEyePosition.x*0.5+face.rightEyePosition.x*0.5, face.leftEyePosition.y*0.5+face.rightEyePosition.y*0.5);
                
            //set the glasses position
            double scalex =self.preview.bounds.size.height/ciImage.extent.size.width;
            double scaley =self.preview.bounds.size.width/ciImage.extent.size.height;
            self.glasses.center = CGPointMake(scaley*eyeCenter.y-self.glasses.bounds.size.height/4.0,scalex*(eyeCenter.x));
                
                
            //set the angle
            double deltax = face.leftEyePosition.x-face.rightEyePosition.x;
            double deltay = face.leftEyePosition.y-face.rightEyePosition.y;
            double angle = atan2(deltax, deltay);
            self.glasses.transform = CGAffineTransformMakeRotation(angle+M_PI);
                
            //set size
            double scale = 3.0*sqrt(deltax*deltax+deltay*deltay);
            self.glasses.bounds = CGRectMake(0, 0, scale, scale);
            
            faceFound = YES;
            
            break;
        }
    }
    
    //[self.glasses setHidden:!faceFound];
   // NSLog(@"glasses = %@",[self.glasses description]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSDictionary *detectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyLow ,CIDetectorAccuracy, nil];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    
    //self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == AVCaptureDevicePositionFront) {
            self.videoDevice = d;
            break;
        }
    }
    
    if (self.videoDevice == nil) {
        self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    [self.session addInput:self.videoInput];
    
    
    self.frameOutput = [[AVCaptureVideoDataOutput alloc]init];
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    self.frameOutput.alwaysDiscardsLateVideoFrames = YES;
    
    [self.frameOutput setSampleBufferDelegate:(id)self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.frameOutput];
    [[self.frameOutput connectionWithMediaType:AVMediaTypeVideo]setEnabled:YES];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    CALayer *rootLayer = [self.preview layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    [self.session startRunning];
    
    self.glasses = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"glasses.png"]];
    [self.glasses setHidden:YES];
    [self.preview addSubview:self.glasses];
    
    self.faceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.faceView setBackgroundColor:[UIColor blackColor]];
    [self.faceView setAlpha:0.2];
    [self.faceView setOpaque:YES];
    [self.faceView setHidden:YES];
    [self.preview addSubview:self.faceView];
    
    self.leftEyeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.leftEyeView setBackgroundColor:[UIColor blueColor]];
    [self.leftEyeView setOpaque:YES];
    [self.leftEyeView setHidden:YES];
    [self.preview addSubview:self.leftEyeView];
    
    self.rightEyeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.rightEyeView setBackgroundColor:[UIColor redColor]];
    [self.rightEyeView setOpaque:YES];
    [self.rightEyeView setHidden:YES];
    [self.preview addSubview:self.rightEyeView];
    
    self.mouthView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.mouthView setBackgroundColor:[UIColor brownColor]];
    [self.mouthView setOpaque:YES];
    [self.mouthView setHidden:YES];
    [self.preview addSubview:self.mouthView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
