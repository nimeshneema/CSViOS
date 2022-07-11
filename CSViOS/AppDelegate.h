//
//  AppDelegate.h
//  CSViOS
//
//  Created by Nimesh Neema on 09/07/22.
//

#import <UIKit/UIKit.h>
#import "CHCSVParser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CHCSVParserDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *combinedAddresses;

@property (strong, nonatomic) NSMutableString *fullAddress;
@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *address3;

@property (strong, nonatomic) CHCSVParser *combinedParser;
@property (strong, nonatomic) CHCSVParser *ppCompleteParser;

@end

