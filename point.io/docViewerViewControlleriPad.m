#import "docViewerViewControlleriPad.h"

@interface docViewerViewControlleriPad ()

@end

@implementation docViewerViewControlleriPad

@synthesize docWebView = _docWebView;
@synthesize shareID = _shareID;
@synthesize fileName = _fileName;
@synthesize fileID = _fileID;
@synthesize containerID = _containerID;
@synthesize remotePath = _remotePath;
@synthesize fileDownloadURL = _fileDownloadURL;
@synthesize downloadData = _downloadData;
@synthesize shareFileButton = _shareFileButton;
@synthesize errorOccuredLabel = _errorOccuredLabel;


UIImageView* imgView;
UIImageView* imgView2;
UIImageView* imgView3;
UIImageView* imgView4;
UILabel* fileNameLabel;

UIAlertView* maxDownloadsReachedError;

NSArray* tempArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
//        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
            return YES;
        } else {
            return NO;
        }
    }
}


- (BOOL)splitViewController:(UISplitViewController*)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

- (void) viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLists" object:nil];
    
    if(self.splitViewController){
        self.splitViewController.delegate = nil;
        self.splitViewController.delegate = self;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.splitViewController){
        self.splitViewController.delegate = nil;
        self.splitViewController.delegate = self;
    }
    [_errorOccuredLabel setAlpha:0];
    [_shareFileButton setEnabled:NO];
	self.navigationItem.title = _fileName;
    _docWebView.delegate = self;
    _docWebView.scalesPageToFit = YES;
    self.navigationItem.backBarButtonItem.title = @"Back";
    [self.navigationController setToolbarHidden:NO animated:YES];
    if(![self isConnectedToInternet]){
        UIAlertView* err = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there is no internet connection, please check the settings" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        UIImageView* temp = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
        temp.image = [UIImage imageNamed:@"noInternetConnection.png"];
        [err addSubview:temp];
        [err setBackgroundColor:[UIColor clearColor]];
        [err show];
    } else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            [self load];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [_shareFileButton setEnabled:YES];
                if(!tempArray){
                    [UIView animateWithDuration:2.0 animations:^(void) {
                        [_errorOccuredLabel setAlpha:1];
                    }];
                    [_shareFileButton setEnabled:NO];
                    imgView4.alpha = 0.5;
                }
                if(tempArray && [[tempArray valueForKey:@"ERROR"]integerValue] == 1){
                    NSString* message = [tempArray valueForKey:@"MESSAGE"];
                    if([message isEqualToString:@"ERROR - Could not download file: You have exceeded the max number of monthly Downloads allowed for a member of your group"]){
                        NSLog(@"SHOULD SHOW ALERT");
                        UIAlertView* maxDownloadsReachedError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have exceeded the maximum number of monthly downloads allowed for a member of your group" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                        UIImageView* errorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 280, 174)];
                        errorImgView.image = [UIImage imageNamed:@"maxDownloadsError.png"];
                        [maxDownloadsReachedError addSubview:errorImgView];
                        [maxDownloadsReachedError setTag:99];
                        maxDownloadsReachedError.delegate = self;
                        [maxDownloadsReachedError show];
                        [_shareFileButton setEnabled:NO];
                        imgView4.alpha = 0.5;
                    }
                } else {
                    imgView4.alpha = 1;
                }
            });
        });
    }
    
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 99){
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
        imgView4.alpha = 0;
        fileNameLabel.alpha = 0;
    }];
    imgView = nil;
    imgView = nil;
    imgView2 = nil;
    imgView4 = nil;
    fileNameLabel = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
        fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 16, 150, 50)];
        fileNameLabel.backgroundColor = [UIColor clearColor];
        fileNameLabel.text = _fileName;
        fileNameLabel.textColor = [UIColor whiteColor];
        [fileNameLabel setTextAlignment:UITextAlignmentCenter];
        fileNameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
        [self.navigationController.view addSubview:imgView];
        imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 50, 29)];
        imgView2.image = [UIImage imageNamed:@"backButton.png"];
        [self.navigationController.view addSubview:imgView2];
        [self.navigationController.view addSubview:fileNameLabel];
        imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1.1f, 320, 44)];
        imgView3.image = [UIImage imageNamed:@"blueBarImageClean"];
        [self.navigationController.toolbar addSubview:imgView3];
        imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 78, 30)];
        imgView4.image = [UIImage imageNamed:@"shareFileButton"];
        [self.navigationController.toolbar addSubview:imgView4];
    }
    imgView.alpha = 0;
    imgView2.alpha = 0;
    imgView3.alpha = 0;
    imgView4.alpha = 0;
    fileNameLabel.alpha = 0;
    _shareFileButton.width = 0.01;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        if(_fileDownloadURL){
            imgView4.alpha = 1;
        } else {
            imgView4.alpha = 0.5;
        }
        fileNameLabel.alpha = 1;
    }];
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [TestFlight passCheckpoint:@"User viewed a document"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)shareFilePressed:(id)sender {
    [self performSegueWithIdentifier:@"goToShare" sender:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"goToShare"]){
        sharingViewController *svc = [segue destinationViewController];
        [svc setFileDownloadURL:_fileDownloadURL];
        [svc setFileName:_fileName];
        [svc setDownloadData:_downloadData];
        [svc setFileID:_fileID];
        [svc setShareID:_shareID];
        [svc setRemotePath:_remotePath];
        [svc setContainerID:_containerID];
        [svc setSessionKey:_sessionKey];
    }
}

- (void) load{
    NSURLResponse* urlResponseList;
    NSError* requestErrorList;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* URLString = [NSString stringWithFormat:@"https://connect.cloudxy.com/api/v1/folder/%@/download.json",_shareID];
    [request setURL:[NSURL URLWithString:URLString]];
    [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    NSArray* objects,* keys;
    NSLog(@"EXTENSION IS %@",[_fileName pathExtension]);
    if (([[_fileName pathExtension] isEqualToString:@"doc"]) || ([[_fileName pathExtension] isEqualToString:@"xls"]) || ([[_fileName pathExtension] isEqualToString:@"ppt"])) {
        objects = [NSArray arrayWithObjects:_containerID,_remotePath,_fileName,_fileID,@"true",nil];
        keys = [NSArray arrayWithObjects:@"containerid",@"remotepath",@"filename",@"fileid",@"convertToPdf",nil];
        NSLog(@"WILL CONVERT TO PDF");
    } else {
        objects = [NSArray arrayWithObjects:_containerID,_remotePath,_fileName,_fileID,@"false",nil];
        keys = [NSArray arrayWithObjects:@"containerid",@"remotepath",@"filename",@"fileid",@"convertToPdf",nil];
    }
    NSDictionary* params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSString* key in params){
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    NSString* requestParams = [pairs componentsJoinedByString:@"&"];
    //    requestParams = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
    //                                                                                              NULL,
    //                                                                                              (CFStringRef)requestParams,
    //                                                                                              NULL,
    //                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
    //                                                                                              kCFStringEncodingUTF8 ));
    URLString = [URLString stringByAppendingFormat:@"?%@",requestParams];
    URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:URLString]];
    NSLog(@"URL STRING = %@",URLString);
    [request setHTTPMethod:@"GET"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if (response) {
        NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"TEMP = %@",temp);
        NSString* extension = [_fileName pathExtension];
        NSLog(@"FILE NAME = %@",_fileName);
        extension = [extension lowercaseString];
        NSString* downloadString = [temp valueForKey:@"RESULT"];
        _fileDownloadURL = [NSURL URLWithString:downloadString];
        NSURLRequest* fileRequest = [NSURLRequest requestWithURL:_fileDownloadURL];
        [_docWebView loadRequest:fileRequest];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        tempArray = [temp copy];
    } else {
        NSLog(@"Something is wrong...");
        [UIView animateWithDuration:2.0 animations:^(void) {
            [_errorOccuredLabel setAlpha:1];
        }];
        [imgView4 setAlpha:0.5];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }
}

- (void)viewDidUnload {
    [self setErrorOccuredLabel:nil];
    [super viewDidUnload];
}

- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
