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

    // Extracts data from combined.csv
@property (strong, nonatomic) NSMutableArray *combinedFullAddresses;
@property (strong, nonatomic) NSString *currentAddress;

    // Extracts data from pp-complete.csv
@property (strong, nonatomic) NSMutableString *fullAddress;

@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *address3;

@property (nonatomic) NSUInteger currentLine;

@property (strong, nonatomic) CHCSVParser *combinedParser;
@property (strong, nonatomic) CHCSVParser *ppCompleteParser;

@end

