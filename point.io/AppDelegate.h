#import <UIKit/UIKit.h>
#import "TestFlight.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSMutableDictionary* storageStatus;
@property (nonatomic) BOOL hasLoggedIn;
@property (nonatomic, strong) NSMutableArray* enabledConnections;
@property (nonatomic, strong) NSString* sessionKey;
@property (nonatomic, strong) NSString* user;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* shareExpirationDate;

- (void) getEnabledStates:(NSNotification*)notification;
- (void) removeOneIndex:(NSNotification*)notification;

@end
