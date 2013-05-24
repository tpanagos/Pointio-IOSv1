#import "workspaceViewController.h"

@interface workspaceViewController ()

@end

@implementation workspaceViewController

@synthesize folderName = _folderName;
@synthesize JSONSharedFoldersArray = _JSONSharedFoldersArray;
@synthesize sessionKey = _sessionKey;
@synthesize fileNames = _fileNames;
@synthesize containerID = _containerID;
@synthesize remotePath = _remotePath;
@synthesize fileIDs = _fileIDs;
@synthesize shareID = _shareID;
@synthesize fileShareIDs = _fileShareIDs;
@synthesize containerIDs = _containerIDs;
@synthesize filePaths = _filePaths;
@synthesize containerIDHistory = _containerIDHistory;
@synthesize i;
@synthesize nestedFoldersCounter;
@synthesize lastFolderTitle = _lastFolderTitle;

NSString* chosenFolderTitle;
NSString* rootFolderTitle;
NSMutableArray* tempContainer;

UIImageView* imgView;
UIImageView* imgView2;
UILabel* sharedFolderLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    i = 0;
    nestedFoldersCounter = 0;
    self.navigationItem.backBarButtonItem.enabled = YES;
    self.navigationItem.backBarButtonItem.title = @"Back";
    self.navigationItem.title = _folderName;
    _remotePath = @"/";
    rootFolderTitle = self.navigationItem.title;
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
            [self getFileNamesAndFileIDs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                [TestFlight passCheckpoint:@"User loaded his workspace successfully"];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        });
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    if(!imgView){
    sharedFolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 16, 150, 50)];
    sharedFolderLabel.backgroundColor = [UIColor clearColor];
    sharedFolderLabel.text = _folderName;
    sharedFolderLabel.textColor = [UIColor whiteColor];
    [sharedFolderLabel setTextAlignment:UITextAlignmentCenter];
    sharedFolderLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    imgView.image = [UIImage imageNamed:@"blueBarImageClean.png"];
    [self.navigationController.view addSubview:imgView];
    imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 27, 50, 29)];
    imgView2.image = [UIImage imageNamed:@"backButton.png"];
    [self.navigationController.view addSubview:imgView2];
    [self.navigationController.view addSubview:sharedFolderLabel];
        if([_lastFolderTitle length]!=0){
            self.navigationItem.title = _lastFolderTitle;
            [sharedFolderLabel setText:_lastFolderTitle];
        }
    imgView.alpha = 0;
    imgView2.alpha = 0;
    sharedFolderLabel.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 1;
        imgView2.alpha = 1;
        sharedFolderLabel.alpha = 1;
        }];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [UIView animateWithDuration:0.25 animations:^(void) {
        imgView.alpha = 0;
        imgView2.alpha = 0;
        sharedFolderLabel.alpha = 0;
    }];
    imgView = nil;
    imgView2 = nil;
    sharedFolderLabel = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) getFileNamesAndFileIDs{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString* URLString = [NSString stringWithFormat:@"https://connect.cloudxy.com/api/v1/folder/%@/contents.json",_shareID];
        [request setURL:[NSURL URLWithString:URLString]];
        [request setHTTPMethod:@"POST"];
        [request addValue:_sessionKey forHTTPHeaderField:@"Authorization"];
    if([_containerID length] >0 && [_remotePath length]>0){
        NSData* payload = [[NSString stringWithFormat:@"path=%@&containerid=%@",_remotePath,_containerID] dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:payload];
        [request setValue:[NSString stringWithFormat:@"%d", [payload length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
    if(!response){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Request response is nil" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    } else {
        NSArray* listFilesResponse = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        _containerID = [listFilesResponse valueForKey:@"CONTAINERID"];
        _fileNames = nil;
        _fileIDs = nil;
        _fileShareIDs = nil;
        _filePaths = nil;
        _containerIDs = nil;
        _fileNames = [NSMutableArray array];
        _filePaths = [NSMutableArray array];
        _fileIDs = [NSMutableArray array];
        _fileShareIDs = [NSMutableArray array];
        _containerIDs = [NSMutableArray array];
        NSDictionary* result = [listFilesResponse valueForKey:@"RESULT"];
        NSArray* columns = [result valueForKey:@"COLUMNS"];
        NSArray* data = [result valueForKey:@"DATA"];
        for(int j=0; j<[data count];j++){
            NSArray* data2 = [data objectAtIndex:j];
            NSDictionary* temp = [NSDictionary dictionaryWithObjects:data2 forKeys:columns];
            [_fileNames addObject:[temp valueForKey:@"NAME"]];
            [_fileIDs addObject:[temp valueForKey:@"FILEID"]];
            [_fileShareIDs addObject:[temp valueForKey:@"SHAREID"]];
            [_containerIDs addObject:[temp valueForKey:@"CONTAINERID"]];
            [_filePaths addObject:[temp valueForKey:@"PATH"]];
            
            
        }
    }
    NSLog(@"NUMBER OF FILES = %i",[_fileNames count]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_fileNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_fileNames objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) viewDidAppear:(BOOL)animated{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    i = indexPath.row;
    if([[_fileIDs objectAtIndex:i] rangeOfString:@"folder:"].location == NSNotFound){
        NSLog(@"IS NOT A FOLDER");
        [self performSegueWithIdentifier:@"viewDocument" sender:nil];
    } else {
        NSLog(@"IS A FOLDER");
        if (!_containerIDHistory) {
            _containerIDHistory = [NSMutableArray array];
        }
        [_containerIDHistory addObject:_containerID];
        [self setRemotePath:[_remotePath stringByAppendingFormat:@"%@/",[_fileNames objectAtIndex:i]]];
        [self setContainerID:[_containerIDs objectAtIndex:i]];
        NSLog(@"REMOTE PATH = %@",_remotePath);
        nestedFoldersCounter++;
        chosenFolderTitle = [_fileNames objectAtIndex:indexPath.row];
        NSLog(@"CHOSEN FOLDER = %@",chosenFolderTitle);
        _lastFolderTitle = chosenFolderTitle;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [self getFileNamesAndFileIDs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationItem setTitle:chosenFolderTitle];
                [self.tableView reloadData];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:chosenFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(showPastFolder)];
                self.navigationItem.hidesBackButton = YES;
                self.navigationItem.leftBarButtonItem = item;
            });
        });
    }
}

- (void) showPastFolder{
    NSMutableArray* subs = [NSMutableArray arrayWithArray:[_remotePath componentsSeparatedByString:@"/"]];
    [subs removeLastObject];
    [subs removeLastObject];
    
    NSString* temp = [[NSString alloc] init];
    tempContainer = nil;
    tempContainer = [NSMutableArray array];
    for(int j = 0;j<[subs count];j++){
        if (![[subs objectAtIndex:j] isEqualToString:@""]) {
            [tempContainer addObject:[subs objectAtIndex:j]];
        }
    }
    NSLog(@"TEMP CONTAINER = %@",tempContainer);
    for(int j = 0;j<[tempContainer count];j++){
        if(j ==0){
            temp = [NSString stringWithFormat:@"/%@",[tempContainer objectAtIndex:0]];
        } else {
            temp = [temp stringByAppendingFormat:@"/%@/",[tempContainer objectAtIndex:j]];
        }
    }
    NSLog(@"TEMP STRING PATH = %@",temp);
    _remotePath = temp;
    _containerID = [_containerIDHistory lastObject];
    
    nestedFoldersCounter--;
    if(nestedFoldersCounter == 0) {
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.leftBarButtonItem = nil;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getFileNamesAndFileIDs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
            if([tempContainer count] != 0){
            self.navigationItem.title = [tempContainer lastObject];
            [sharedFolderLabel setText:[tempContainer lastObject]];
            } else {
                self.navigationItem.title = rootFolderTitle;
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:0];
                }];
                [sharedFolderLabel setText:rootFolderTitle];
                [UIView animateWithDuration:0.15 animations:^(void) {
                    [sharedFolderLabel setAlpha:1];
                }];
            }
            [_containerIDHistory removeLastObject];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"viewDocument"]){
        docViewerViewController* dvvc = [segue destinationViewController];
        [dvvc setShareID:[_fileShareIDs objectAtIndex:i]];
        [dvvc setFileName:[_fileNames objectAtIndex:i]];
        [dvvc setFileID:[_fileIDs objectAtIndex:i]];
        [dvvc setRemotePath:_remotePath];
        [dvvc setContainerID:_containerID];
        [dvvc setSessionKey:_sessionKey];
        NSLog(@"LAST FOLDER TITLE = %@",_lastFolderTitle);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate


- (BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


@end
