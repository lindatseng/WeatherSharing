//
//  DetailViewController.m
//  finaltest2
//
//  Created by admin on 11/12/28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "Annotation.h"
#import "JSONKit.h"
#import "LocationInfo.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <math.h>
enum {
    temperature,
    weather,
    cwb
}CurrentView;
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size) 
{	
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	CVPixelBufferRelease( pixelBuffer );
}

// create a CGImage with provided pixel buffer, pixel buffer must be uncompressed kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut) 
{	
	OSStatus err = noErr;
	OSType sourcePixelFormat;
	size_t width, height, sourceRowBytes;
	void *sourceBaseAddr = NULL;
	CGBitmapInfo bitmapInfo;
	CGColorSpaceRef colorspace = NULL;
	CGDataProviderRef provider = NULL;
	CGImageRef image = NULL;
	
	sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	else
		return -95014; // only uncompressed pixel formats
	
	sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
	width = CVPixelBufferGetWidth( pixelBuffer );
	height = CVPixelBufferGetHeight( pixelBuffer );
	
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
	
	colorspace = CGColorSpaceCreateDeviceRGB();
    
	CVPixelBufferRetain( pixelBuffer );
	provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
	image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
	
bail:
	if ( err && image ) {
		CGImageRelease( image );
		image = NULL;
	}
	if ( provider ) CGDataProviderRelease( provider );
	if ( colorspace ) CGColorSpaceRelease( colorspace );
	*imageOut = image;
	return err;
}

// utility used by newSquareOverlayedImageForFeatures for 
static CGContextRef CreateCGBitmapContextForSize(CGSize size);
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow = (size.width * 4);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
									 size.width,
									 size.height,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing(context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}



@interface DetailViewController ()
{
    BOOL isLocated;
    BOOL isDetectingFace;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
-(void)myPosition;
- (void)setupAVCapture;
- (void)teardownAVCapture;
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation;
-(void)setFaceSwitch;
-(void)changeCurrentView;
@end

@implementation DetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize mapView = _mapView;
@synthesize obsInfo;
@synthesize userFeedback;
@synthesize queue;
@synthesize currentView;
- (void)dealloc
{
    [_masterPopoverController release];
    [locationManager release];
    [self teardownAVCapture];
	[faceDetector release];
	[square release];
    [super dealloc];
}



#pragma mark - Managing the detail item

+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
	NSArray *sublayers = [NSArray arrayWithArray:[previewLayer sublayers]];
	NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
	NSInteger featuresCount = [features count], currentFeature = 0;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for ( CALayer *layer in sublayers ) {
		if ( [[layer name] isEqualToString:@"FaceLayer"] )
			[layer setHidden:YES];
	}	
	
	if ( featuresCount == 0 || !detectFaces ) {
		[CATransaction commit];
		return; // early bail.
	}
    
	CGSize parentFrameSize = [self.view frame].size;
	NSString *gravity = [previewLayer videoGravity];
	BOOL isMirrored = [previewLayer isMirrored];
	CGRect previewBox = [DetailViewController videoPreviewBoxForGravity:gravity 
                                                        frameSize:parentFrameSize 
                                                     apertureSize:clap.size];
	//tailViewController video
	for ( CIFaceFeature *ff in features ) {
		// find the correct position for the square layer within the previewLayer
		// the feature box originates in the bottom left of the video frame.
		// (Bottom right if mirroring is turned on)
		

        CGRect faceRect = [ff bounds];
        
		// flip preview width and height
		CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
        
        NSLog(@"width %f", faceRect.size.width);
        NSLog(@"height %f", faceRect.size.height);
        
        MKCoordinateRegion region = _mapView.region;
//        region.center.latitude = 25.03;
//        region.center.longitude = 121.5;
        MKCoordinateSpan span;
        
        NSLog(@"faceState %d", faceState);
        switch (faceState) {
            case 1:
                
                if(faceRect.size.width>185)
                {faceState=2;
                span.latitudeDelta = 0.5;
                span.longitudeDelta = 0.5;} 
                else
                {span.latitudeDelta = 2.0;
                 span.longitudeDelta = 2.0;}
                break;
            case 2:
                if(faceRect.size.width>285)
                {faceState=3;
                    span.latitudeDelta = 0.1;
                    span.longitudeDelta = 0.1;} 
                else if(faceRect.size.width<160)
                {faceState=1;
                 span.latitudeDelta = 2.0;
                 span.longitudeDelta = 2.0;} 
                else
                {span.latitudeDelta = 0.5;
                 span.longitudeDelta = 0.5;}
                break;
            case 3:
                if(faceRect.size.width>360)
                {faceState=4;
                    span.latitudeDelta = 0.02;
                    span.longitudeDelta = 0.02;} 
                else if(faceRect.size.width<235)
                {faceState=2;
                    span.latitudeDelta = 0.5;
                    span.longitudeDelta = 0.5;} 
                else
                {   span.latitudeDelta = 0.1;
                    span.longitudeDelta = 0.1;}
                break;
            case 4:
                if(faceRect.size.width<335)
                {faceState=3;
                    span.latitudeDelta = 0.1;
                    span.longitudeDelta = 0.1;} 
                else
                {span.latitudeDelta = 0.02;
                 span.longitudeDelta = 0.02;
                }
                break;
            default:
                break;
        }
        
//        if(faceRect.size.width>360)
//        {   span.latitudeDelta = 0.02;
//            span.longitudeDelta = 0.02;
//        }
//        else if(faceRect.size.width>300&&faceRect.size.width<=360)
//        {   span.latitudeDelta = 0.06;
//            span.longitudeDelta = 0.06;}
//        else if(faceRect.size.width>230&&faceRect.size.width<=300)
//        {   span.latitudeDelta = 0.18;
//            span.longitudeDelta = 0.18;
//        }
//        else if(faceRect.size.width>160&&faceRect.size.width<=230)
//        {   span.latitudeDelta = 0.54;
//            span.longitudeDelta = 0.54;}
//        else
//        {   span.latitudeDelta = 1.5;
//            span.longitudeDelta = 1.5;}
        
        region.span = span;
        [_mapView setRegion:region animated:YES];
        
        
        
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
		// scale coordinates so they fit in the preview box, which may be scaled
		CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
		CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
        faceRect.size.width *= widthScaleBy;
		faceRect.size.height *= heightScaleBy;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;
        
		if ( isMirrored )
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
        
		else
			faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
		
		CALayer *featureLayer = nil;
		
		// re-use an existing layer if possible
		while ( !featureLayer && (currentSublayer < sublayersCount) ) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
		
		// create a new one if necessary
		if ( !featureLayer ) {
			featureLayer = [CALayer new];
			[featureLayer setContents:(id)[square CGImage]];
			[featureLayer setName:@"FaceLayer"];
			[previewLayer addSublayer:featureLayer];
			[featureLayer release];
		}
		[featureLayer setFrame:faceRect];
		
		switch (orientation) {
			case UIDeviceOrientationPortrait:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
				break;
			case UIDeviceOrientationLandscapeLeft:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
				break;
			case UIDeviceOrientationLandscapeRight:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
				break;
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
			default:
				break; // leave the layer in its last known orientation
		}
		currentFeature++;
	}
	
	[CATransaction commit];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{	
    
    if(!isDetectingFace){
        
    }
    else{
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants. 
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.  
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
	NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
	[ciImage release];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
	});
    }
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}



// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil 
												  cancelButtonTitle:@"Dismiss" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	});
}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll

// turn on/off face detection


// find where the video box is positioned within the preview layer based on the video size and gravity
- (void)setupAVCapture
{
	NSError *error = nil;
	
	AVCaptureSession *session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	require( error == nil, bail );
	
    isUsingFrontFacingCamera = NO;
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a still image output
	stillImageOutput = [AVCaptureStillImageOutput new];
	[stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:AVCaptureStillImageIsCapturingStillImageContext];
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	effectiveScale = 1.0;
	previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    //	CALayer *rootLayer = [previewView layer];
    //	[rootLayer setMasksToBounds:YES];
    //	[previewLayer setFrame:[rootLayer bounds]];
    //	[rootLayer addSublayer:previewLayer];
	[session startRunning];
    
bail:
	[session release];
	if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil 
												  cancelButtonTitle:@"Dismiss" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		[self teardownAVCapture];
	}
}

// clean up capture setup
- (void)teardownAVCapture
{
	[videoDataOutput release];
	if (videoDataOutputQueue)
		dispatch_release(videoDataOutputQueue);
	[stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
	[stillImageOutput release];
	[previewLayer removeFromSuperlayer];
	[previewLayer release];
}

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
-(void)setFaceSwitch{
    
    if(isDetectingFace){
        UIBarButtonItem *c = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Face OFF"] style:UIBarButtonItemStyleBordered target:self action:@selector(setFaceSwitch)];
        UIBarButtonItem *a= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(myPosition)];

        NSArray *temp = [NSArray arrayWithObjects: c,a,b,nil];
        [self setToolbarItems:temp];
        isDetectingFace=!isDetectingFace;
    }
    else{
        UIBarButtonItem *c = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Face ON"] style:UIBarButtonItemStyleBordered target:self action:@selector(setFaceSwitch)];
        UIBarButtonItem *a= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(myPosition)];

        NSArray *temp = [NSArray arrayWithObjects: c,a,b,nil];
        [self setToolbarItems:temp];
        isDetectingFace=!isDetectingFace;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished");
    NSString *response = [request responseString];
    id result = [response objectFromJSONString];  
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSLog(@"dictionary");
        
        NSDictionary *temp1 = [response objectFromJSONString];
        NSDictionary *data = [temp1 objectForKey:@"result"];
        
        
        NSString *locationName = [data objectForKey:@"locationName"];
        NSString *description = [data objectForKey:@"description"];
        float longitude = [[LocationInfo sharedInfo] longitudeForLocation:locationName];
        float latitude = [[LocationInfo sharedInfo] latitudeForLocation:locationName];
        CLLocationCoordinate2D coordinate = {latitude,longitude};
        Annotation *annotation =[[Annotation alloc]initWithTitle:locationName subTitle:description andCoordinate:coordinate];
        
        [_mapView addAnnotation:annotation];
       
        
        
        
        
        
        
        //data from suitingweather.appspot.com 中央氣象局
    }
    else if([result isKindOfClass:[NSArray class]]){
        NSLog(@"array");
        //userFeedback=result;
        //data from sharemyweather.appspot.com 使用者回報
        for (NSUInteger i=0; i<[result count]; i++) {
            NSLog(@"%d",i);
            NSDictionary *data = [result objectAtIndex:i];
            
            NSString *date= [data objectForKey:@"date"];
            NSString *tmp1=[date substringFromIndex:11];
            int hour=[[tmp1 substringToIndex:2] intValue];
            int minute= [[[tmp1 substringFromIndex:3] substringToIndex:2]intValue];
            hour=(hour+8)%24;
            NSString *description;
            
            float longitude =[[data objectForKey:@"lng"] floatValue];
            float latitude = [[data objectForKey:@"lat"] floatValue];
            int weatherType = [[data objectForKey:@"weatherType"] intValue];
            int temperatureType = [[data objectForKey:@"temper"] intValue];
            CLLocationCoordinate2D coordinate = {latitude,longitude};
            
            if (temperatureType==Cold) {
                description=[[NSString alloc]initWithFormat:@"Cold and "];
            }
            else if(temperatureType==Normal){
                description=[[NSString alloc]initWithFormat:@"Normal and "];
            }
            else if(temperatureType==Hot){
                description=[[NSString alloc]initWithFormat:@"Hot and "];
            }
            else {
                description=[[NSString alloc]initWithFormat:@""];
            }
            
            if (weatherType==Rainy) {
                description= [description stringByAppendingString:@"Rainy"];
            }
            else if(weatherType==Cloudy){
                description= [description stringByAppendingString:@"Cloudy"];
            }
            else if(weatherType==Sunny){
                description= [description stringByAppendingString:@"Sunny"];
            }
            else {
                
            }
            Annotation *annotation =[[Annotation alloc]initWithTitle: [NSString stringWithFormat:@"%02d:%02d",hour,minute]
                                                            subTitle: description
                                                       andCoordinate:coordinate
                                                        andWeather:weatherType andTemperature:temperatureType];
            //NSLog(@"%f,%f,%@,%@",longitude,latitude,weatherType,temperatureType);
            [userFeedback addObject:annotation];
            [_mapView addAnnotation:annotation];
        }
        
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    
    static NSString *sunnyIdentifier=@"sunny";
    static NSString *cloudyIdentifier=@"cloudy";
    static NSString *rainyIdentifier=@"rainy";
    static NSString *coldIdentifier=@"cold";
    static NSString *normalIdentifier=@"normal";
    static NSString *hotIdentifier=@"hot";
    static NSString *cwbIdentifier=@"cwb";
    if([annotation isKindOfClass:[Annotation class]]){NSLog(@"if1");
        //Try to get an unused annotation, similar to uitableviewcells
        Annotation *anno=annotation;
        MKAnnotationView *annotationView=nil;
        NSLog(@"%d",anno.weatherState);
        if (currentView==weather) {
        
        
        switch (anno.weatherState) {
            case Sunny:{
                annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:sunnyIdentifier];
            }
                break;
            case Cloudy:{
                annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:cloudyIdentifier];
            }
                break;
            case Rainy:{
                annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:rainyIdentifier];
            }
                break;
            default:
                
                break;
        }
        }
        else if(currentView==temperature){
            switch (anno.temperatureState) {
                case Cold:{
                    annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:coldIdentifier];
                }
                    break;
                case Hot:{
                    annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:hotIdentifier];
                }
                    break;
                case Normal:{
                    annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:normalIdentifier];
                }
                    break;
                default:
                    
                    break;
            }
        }
        else{
            annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:cwbIdentifier];
        }
        //If one isn't available, create a new one
        if(!annotationView){
            NSLog(@"if2");
            if (currentView==weather) {
            switch (anno.weatherState) {
                    
                case Sunny:{
                    annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:sunnyIdentifier];
                    
                    annotationView.image=[UIImage imageNamed:@"Sunny.png"];
                }
                    break;
                case Cloudy:{
                    annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:cloudyIdentifier];
                    annotationView.image=[UIImage imageNamed:@"Cloudy.png"];
                }
                    break;
                case Rainy:{
                    annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:rainyIdentifier];
                    annotationView.image=[UIImage imageNamed:@"Rainy.png"];
                }
                    break;
                default:
                    //annotationView=nil;
                    annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:rainyIdentifier];
                    //annotationView.image=[UIImage imageNamed:@"normal.png"];
                    break;
            }
            annotationView.canShowCallout=YES;
            }
            else if(currentView==temperature){
                switch (anno.temperatureState) {
                        
                    case Cold:{
                        annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:coldIdentifier];
                        
                        annotationView.image=[UIImage imageNamed:@"cold.png"];
                    }
                        break;
                    case Hot:{
                        annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:hotIdentifier];
                        annotationView.image=[UIImage imageNamed:@"hot.png"];
                    }
                        break;
                    case Normal:{
                        annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:normalIdentifier];
                        annotationView.image=[UIImage imageNamed:@"normal.png"];
                    }
                        break;
                    default:
                        //annotationView=nil;
                        annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:rainyIdentifier];
                        //annotationView.image=[UIImage imageNamed:@"normal.png"];
                        break;
                }
                annotationView.canShowCallout=YES;
            }
            else{
                annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:
                                cwbIdentifier];
                
                annotationView.image=[UIImage imageNamed:@""];
            }
        }
        return annotationView;
    }
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    userFeedback = [[NSMutableArray alloc]initWithCapacity:0];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    _mapView.delegate=self;
    [self.view addSubview:_mapView];
    isLocated = NO;
    isDetectingFace = NO;
    currentView=temperature;
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.toolbarHidden=NO;
    UIBarButtonItem *c = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Face Off"] style:UIBarButtonItemStyleBordered target:self action:@selector(setFaceSwitch)];
    
    UIBarButtonItem *a= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(myPosition)];
    NSArray *items = [[NSArray alloc]initWithObjects:c,a,b, nil];
    [self setToolbarItems:items];
    
    
    UIBarButtonItem *d = [[UIBarButtonItem alloc]initWithTitle:@"Temperature" style:UIBarButtonItemStyleBordered target:self action:@selector(changeCurrentView)];
    self.navigationItem.rightBarButtonItem=d;
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    queue.maxConcurrentOperationCount=1;
    
//    for(NSUInteger i=0;i<[[LocationInfo sharedInfo].OBSLocations count];i++){
//        NSString *temp1 = [NSString stringWithFormat:@"http://suitingweather.appspot.com/obs?location=%@&output=json",
//                           [[[LocationInfo sharedInfo].OBSLocations objectAtIndex:i]objectForKey:@"identifier"]];
//        NSURL *url = [NSURL URLWithString:temp1];
//        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//        //[request startAsynchronous];
//        [request setDelegate:self];
//        [[self queue] addOperation:request];
//    }
    
    NSString *temp1 = [NSString stringWithFormat:@"http://sharemyweather.appspot.com/download"];
    NSURL *url = [NSURL URLWithString:temp1];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [[self queue] addOperation:request];
    
    
    
    detectFaces = YES;
    [self setupAVCapture];
	square = [[UIImage imageNamed:@"squarePNG"] retain];
	NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
	faceDetector = [[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions] retain];
	[detectorOptions release];
    
    AVCaptureDevicePosition desiredPosition;
	if (isUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];
			break;
		}
	}
	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
    faceState = 1;

}
-(void)changeCurrentView{
    switch (currentView) {
        case temperature:{
            UIBarButtonItem *d = [[UIBarButtonItem alloc]initWithTitle:@"Weather" style:UIBarButtonItemStyleBordered target:self action:@selector(changeCurrentView)];
            self.navigationItem.rightBarButtonItem=d;
            currentView=weather;
            [_mapView removeAnnotations:_mapView.annotations];
            for (NSUInteger i=0;i<[userFeedback count]; i++) {
                [_mapView addAnnotation:[userFeedback objectAtIndex:i]];
            }
        }
            break;
        case weather:{
            UIBarButtonItem *d = [[UIBarButtonItem alloc]initWithTitle:@"cwb" style:UIBarButtonItemStyleBordered target:self action:@selector(changeCurrentView)];
            self.navigationItem.rightBarButtonItem=d;
            currentView=cwb;
            [_mapView removeAnnotations:_mapView.annotations];
            for (NSUInteger i=0;i<[userFeedback count]; i++) {
                [_mapView addAnnotation:[userFeedback objectAtIndex:i]];
            }
        }
            break;
        case cwb:{
            UIBarButtonItem *d = [[UIBarButtonItem alloc]initWithTitle:@"Temperature" style:UIBarButtonItemStyleBordered target:self action:@selector(changeCurrentView)];
            self.navigationItem.rightBarButtonItem=d;
            currentView=temperature;
            [_mapView removeAnnotations:_mapView.annotations];
            for (NSUInteger i=0;i<[userFeedback count]; i++) {
                [_mapView addAnnotation:[userFeedback objectAtIndex:i]];
            }
        }
            break;
        default:
            break;
    }
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    mylat = newLocation.coordinate.latitude;
    mylng = newLocation.coordinate.longitude;
    
    if(!isLocated){
        MKCoordinateRegion region;
        region.center.latitude = mylat;
        region.center.longitude = mylng;
        MKCoordinateSpan span;
        span.latitudeDelta = .2;
        span.longitudeDelta = .2;
        region.span = span;
        [_mapView setRegion:region animated:YES];
        isLocated = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateSpan span = _mapView.region.span;
    MKCoordinateRegion region = _mapView.region;
    float lat1=region.center.latitude-span.latitudeDelta/2;
    float lat2=region.center.latitude+span.latitudeDelta/2;
    float long1=region.center.longitude-span.latitudeDelta/2;
    float long2=region.center.longitude+span.latitudeDelta/2;
    NSArray *annotations = _mapView.annotations;
    NSArray *data = [LocationInfo sharedInfo].OBSLocations;
    for(NSUInteger i=0;i<[[LocationInfo sharedInfo].OBSLocations count];i++){
        NSDictionary *temp = [data objectAtIndex:i];
        BOOL onMap=NO;
        float lat = [[temp objectForKey:@"lat"] floatValue];
        float longt = [[temp objectForKey:@"longt"] floatValue];
        for (NSUInteger j=0; j<[annotations count]; j++) {
            Annotation *annot = [annotations objectAtIndex:j];
            
            if(annot.coordinate.latitude==lat&&
               annot.coordinate.longitude==longt){
                onMap=YES;
                break;
            }
        }
        if(lat>lat1&&lat<lat2&&longt>long1&&longt<long2&&isLocated&&!onMap){
        
        
//        NSString *temp1 = [NSString stringWithFormat:@"http://suitingweather.appspot.com/obs?location=%@&output=json",
//                           [[[LocationInfo sharedInfo].OBSLocations objectAtIndex:i]objectForKey:@"identifier"]];
//        NSURL *url = [NSURL URLWithString:temp1];
//        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//        //[request startAsynchronous];
//        [request setDelegate:self];
//        [[self queue] addOperation:request];
            
        }
    }


    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) uploadData
{
//    NSURL *uploadurl = [NSURL URLWithString:@"http://sharemyweather.appspot.com/upload"];
//    ASIFormDataRequest *uploadrequest = [ASIFormDataRequest requestWithURL:uploadurl];
//    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
//    [uploadrequest setPostValue:udid forKey:@"iosUID"];
//    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylat] forKey:@"lat"];
//    [uploadrequest setPostValue:[NSNumber numberWithFloat:mylng] forKey:@"lng"];
//    [uploadrequest setPostValue:@"14" forKey:@"temper"];
//    [uploadrequest setPostValue:@"5" forKey:@"weatherType"];
//    [uploadrequest startSynchronous];
//    NSString *rrr = [uploadrequest responseString];
    //NSLog(@"%@",rrr);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
-(void)myPosition{
    MKCoordinateRegion region;
    region.center.latitude = mylat;
    region.center.longitude = mylng;
    MKCoordinateSpan span;
    span.latitudeDelta = .02;
    span.longitudeDelta = .02;
    region.span = span;
    
    
    [_mapView setRegion:region animated:YES];
}
@end
