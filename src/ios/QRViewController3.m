//
//  QRViewController3.m
//  QRPlugin01
//
//  Created by ITS-J on 2014/07/11.
//
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QRViewController3.h"

@interface QRViewController3 () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation QRViewController3
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.viewControllerStart = true;
    self.session = [[AVCaptureSession alloc] init];
    @try {

        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *device = nil;
        for (AVCaptureDevice *d in devices) {
            device = d;
            if (d.position == self.devicePosition) {
                break;
            }
        }

        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                            error:&error];
        [self.session addInput:input];

        AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:output];

        // 読取対象
        NSMutableArray *types = [NSMutableArray array];
        if (self.typeQRCode) {
            [types addObject:AVMetadataObjectTypeQRCode];
        }
        if (self.typeUPCE) {
            [types addObject:AVMetadataObjectTypeUPCECode];
        }
        if (self.typeCode39) {
            [types addObject:AVMetadataObjectTypeCode39Code];
        }
        if (self.typeCode39Mod43) {
            [types addObject:AVMetadataObjectTypeCode39Mod43Code];
        }
        if (self.typeEAN13) {
            [types addObject:AVMetadataObjectTypeEAN13Code];
        }
        if (self.typeEAN8) {
            [types addObject:AVMetadataObjectTypeEAN8Code];
        }
        if (self.typeCode93) {
            [types addObject:AVMetadataObjectTypeCode93Code];
        }
        if (self.typeCode128) {
            [types addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes = types;

        // ビデオプレビュー
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:preview];
        [self.view.layer setValue:preview forKey:@"preview"];

        // 四角表示
        //CALayer *boxLayer = [CALayer layer];
        //boxLayer.borderWidth = 1.0f;
        //boxLayer.borderColor = [UIColor whiteColor].CGColor;
        //[self.view.layer addSublayer:boxLayer];
        //[self.view.layer setValue:boxLayer forKey:@"boxLayer"];

        CAShapeLayer *boxLayerDash = [CAShapeLayer layer];
        boxLayerDash.lineWidth = 1.0f;
        boxLayerDash.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:6],
                                                                 [NSNumber numberWithInt:4],nil];
        boxLayerDash.fillColor = [UIColor clearColor].CGColor;
        boxLayerDash.strokeColor = [UIColor whiteColor].CGColor;
        [self.view.layer addSublayer:boxLayerDash];
        [self.view.layer setValue:boxLayerDash forKey:@"boxLayerDash"];

        // メッセージ
        UILabel *msgLabel = [[UILabel alloc] init];
        msgLabel.tag = 3;
        //msgLabel.backgroundColor = [UIColor colorWithRed:0.21 green:0.39 blue:0.55 alpha:1]; //（１）メッセージ背景色
        //msgLabel.layer.cornerRadius = 18.0f;
        msgLabel.clipsToBounds = YES;
        msgLabel.font = [UIFont fontWithName:@"AppleGothic" size:30.0]; //（２）メッセージ文字タイプ
        msgLabel.textColor = [UIColor colorWithRed:0.902 green:0.216 blue:0.353 alpha:1]; // （３）メッセージ文字色
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.view addSubview:msgLabel];

        // ボタン
        CALayer *buttonLayer1 = [CALayer layer];
        buttonLayer1.frame = CGRectMake(0, 0, 200, 60);
        buttonLayer1.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1].CGColor; //（４）ボタン背景色１
        buttonLayer1.borderColor = [UIColor colorWithRed:0.718 green:0.718 blue:0.718 alpha:1].CGColor; //（４）ボタン背景色１枠線
        buttonLayer1.borderWidth = 1.0f; //（４）ボタン背景色１枠線
        //buttonLayer1.cornerRadius = 18.0f;
        [self.view.layer addSublayer:buttonLayer1];
        [self.view.layer setValue:buttonLayer1 forKey:@"buttonLayer1"];

        CALayer *buttonLayer2 = [CALayer layer];
        //buttonLayer2.frame = CGRectMake(0, 0, 196, 30);
        //buttonLayer2.backgroundColor = [UIColor colorWithRed:0.28 green:0.44 blue:0.60 alpha:1].CGColor; // （５）ボタン背景色２
        //buttonLayer2.cornerRadius = 15.0f;
        [self.view.layer addSublayer:buttonLayer2];
        [self.view.layer setValue:buttonLayer2 forKey:@"buttonLayer2"];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = 1;
        button.frame = CGRectMake(0, 0, 200, 60);
        button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        button.clipsToBounds = YES;
        [button setTitle:@"キャンセル" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"AppleGothic" size:30.0]; //（６）ボタン文字タイプ
        //button.titleLabel.textColor = [UIColor whiteColor]; // （７）ボタン文字色
        button.titleLabel.textColor = [UIColor colorWithRed:0.365 green:0.365 blue:0.365 alpha:1]; // （７）ボタン文字色
        [button addTarget:self
                   action:@selector(cancelView:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];

        // 位置調整
        [self controllOrientation];

        [self.session startRunning];
    }
    @catch (NSException *exception) {
        NSLog(@"例外名：%@", exception.name);
        NSLog(@"例外内容：%@", exception.reason);
        [self.session stopRunning];
        self.viewControllerStart = false;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadata in metadataObjects) {
        NSString *code = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
        AudioServicesPlaySystemSound(1391);
        [self closeView:code];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // 画面回転時の呼び出し
    // 位置調整
    [self controllOrientation];
}

- (void)controllOrientation {
    // 位置調整が必要なオブジェクトの取得
    UIButton *button = (UIButton*)[self.view viewWithTag:1];
    UILabel *msgLabel = (UILabel*)[self.view viewWithTag:3];
    AVCaptureVideoPreviewLayer *preview = [self.view.layer valueForKey:@"preview"];
    //CALayer *boxLayer = [self.view.layer valueForKey:@"boxLayer"];
    CAShapeLayer *boxLayer = [self.view.layer valueForKey:@"boxLayerDash"];
    CALayer *buttonLayer1 = [self.view.layer valueForKey:@"buttonLayer1"];
    CALayer *buttonLayer2 = [self.view.layer valueForKey:@"buttonLayer2"];

    // 画面の幅(短い方)、高さ(長い方)
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    if (width > height) {
        // 起動時に横向きの場合、逆になっている
        width = self.view.bounds.size.height;
        height = self.view.bounds.size.width;
    }

    // 位置調整
    CGFloat marginTop = 20;
    CGFloat marginWidth = 60;
    CGFloat marginHeight = 80;
    CGFloat frameWidth = width;
    CGFloat frameHeight = height;
    CGFloat centerX = self.view.center.x;
    AVCaptureVideoOrientation orientation;
    UIInterfaceOrientation direction = self.interfaceOrientation;
    if(direction == UIInterfaceOrientationPortrait){
        // 縦（ホームボタンが下）
        NSLog(@"%@", @"縦（ホームボタン下）");
        orientation = AVCaptureVideoOrientationPortrait;

    } else if(direction == UIInterfaceOrientationPortraitUpsideDown){
        // 縦（ホームボタンが上）
        NSLog(@"%@", @"縦（ホームボタン上）");
        orientation = AVCaptureVideoOrientationPortraitUpsideDown;

    } else {
        // 横レイアウト
        frameWidth = height;
        frameHeight = width;
        centerX = self.view.center.y;

        if(direction == UIInterfaceOrientationLandscapeLeft){
            // 横（ホームボタンが左）
            NSLog(@"%@", @"横（ホームボタン左）");
            orientation = AVCaptureVideoOrientationLandscapeLeft;

        } else if(direction == UIInterfaceOrientationLandscapeRight){
            // 横（ホームボタン右）
            NSLog(@"%@", @"横（ホームボタン右）");
            orientation = AVCaptureVideoOrientationLandscapeRight;
        }
    }
    // メッセージ
    msgLabel.frame = CGRectMake(marginWidth, marginTop, frameWidth - (marginWidth * 2), 50);
    // 四角表示
    boxLayer.frame = CGRectMake(marginWidth, marginHeight, frameWidth - (marginWidth * 2), frameHeight - (marginHeight * 2));
    // ボタン
    button.center = CGPointMake(centerX, frameHeight - (marginHeight/2));
    // プレビュー
    preview.frame = CGRectMake(0, 0, frameWidth, frameHeight);
    preview.connection.videoOrientation = orientation;
    // メッセージ
    msgLabel.text = @"Re:PitaアプリのQRコードを枠内に合わせてください";
    // ボタン背景
    buttonLayer1.frame = button.frame;
    buttonLayer2.frame = CGRectMake(button.frame.origin.x + 2,
                                    button.frame.origin.y + 2,
                                    buttonLayer2.frame.size.width,
                                    buttonLayer2.frame.size.height);
    // 四角
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    // 以下、→↓←↑の順に点線を描く
    CGPathAddLineToPoint(path, NULL, boxLayer.frame.size.width, 0);
    CGPathAddLineToPoint(path, NULL, boxLayer.frame.size.width, boxLayer.frame.size.height);
    CGPathAddLineToPoint(path, NULL, 0, boxLayer.frame.size.height);
    CGPathAddLineToPoint(path, NULL, 0, 0);
    [boxLayer setPath:path];
    CGPathRelease(path);
}

-(void) cancelView:(id)sender {
    // キャンセル
    [self closeView:nil];
}

-(void) closeView:(NSString*) str {
    if ([delegate respondsToSelector:@selector(closeView:)]) {
        [delegate closeView:str];
    }
    [self.session stopRunning];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
