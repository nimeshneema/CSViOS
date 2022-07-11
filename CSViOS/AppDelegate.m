//
//  AppDelegate.m
//  CSViOS
//
//  Created by Nimesh Neema on 09/07/22.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.combinedFullAddresses = [[NSMutableArray alloc] init];
    self.currentAddress = nil;
    
    self.fullAddress = [[NSMutableString alloc] init];
    
    self.address1 = nil;
    self.address2 = nil;
    self.address3 = nil;
    
    self.currentLine = 0;
    
    NSString *combinedFilePath = [[NSBundle mainBundle] pathForResource:@"combined" ofType:@"csv"];
    NSString *ppCompleteFilePath = [[NSBundle mainBundle] pathForResource:@"pp-complete" ofType:@"csv"];
     
    self.combinedParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:combinedFilePath]];
    self.combinedParser.delegate = self;
    
    self.ppCompleteParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:ppCompleteFilePath]];
    self.ppCompleteParser.delegate = self;
    
    [self.combinedParser parse];
    
    return YES;
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    if (parser == self.combinedParser) {
        NSLog(@"Begin combinedParser");
    } else {
        NSLog(@"Begin ppCompleteParser");
    }
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    if (parser == self.ppCompleteParser) {
        self.currentLine = recordNumber;
    } else {
        
    }
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (parser == self.combinedParser) {
          NSLog(@"CombinedParser Line#: %ld, \"%@\"",recordNumber, self.currentAddress);
    } else {
        
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    if (parser == self.combinedParser) {
        NSLog(@"End combinedParser");
        [self.ppCompleteParser parse];
    } else {
        NSLog(@"End ppCompleteParser");
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (parser == self.combinedParser) {
        if (fieldIndex == 81) {
            if (field != nil && field.length > 0) {
                NSString *fieldString = field;
                
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
                NSString *trimmedString = [regex stringByReplacingMatchesInString:fieldString options:0 range:NSMakeRange(0, [fieldString length]) withTemplate:@" "];
                
                self.currentAddress = [trimmedString substringWithRange:NSMakeRange(1, [trimmedString length] - 2)];
                [self.combinedFullAddresses addObject:[trimmedString substringWithRange:NSMakeRange(1, [trimmedString length] - 2)]];
            }
        }
    } else {
        switch (fieldIndex) {
            case 7:
                self.address1 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
                break;
            case 8:
                self.address2 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
                break;
            case 9:
                self.address3 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
                break;
            default:
                break;
        }
        
        if (fieldIndex == 10) {
            if (self.address1.length != 0) {
                [self.fullAddress appendString:self.address1];
                
                if (self.address2.length != 0) {
                    [self.fullAddress appendFormat:@", %@", self.address2];
                    
                    if (self.address3.length != 0) {
                        [self.fullAddress appendFormat:@", %@", self.address3];
                    }
                } else {
                    if (self.address3.length != 0) {
                        [self.fullAddress appendFormat:@", %@", self.address3];
                    }
                }
            } else {
                if (self.address2.length != 0) {
                    [self.fullAddress appendString:self.address2];
                    
                    if (self.address3.length != 0) {
                        [self.fullAddress appendFormat:@", %@", self.address3];
                    }
                } else {
                    if (self.address3.length != 0) {
                        [self.fullAddress appendString:self.address3];
                    }
                }
            }
        
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
            NSString *trimmedString = [regex stringByReplacingMatchesInString:self.fullAddress options:0 range:NSMakeRange(0, [self.fullAddress length]) withTemplate:@" "];
            self.fullAddress = [NSMutableString stringWithString:trimmedString];
            
            [self checkAddress];
        }
    }
    
    return;
}

- (void)checkAddress {
    // NSLog(@"Searching Constructed Address: %@", self.fullAddress);
    
    for (NSUInteger i = 1; i <= [self.combinedFullAddresses count]; i++) {
        NSString *combinedFullAddressLowercased = [self.combinedFullAddresses[i-1] lowercaseString];
        NSString *fullAddressLowercased = [self.fullAddress lowercaseString];
        
        if ([combinedFullAddressLowercased containsString:fullAddressLowercased]) {
            NSLog(@"combined.csv: %ld, pp-complete.csv: %ld : %@", i, self.currentLine, self.fullAddress);
        }
    }
    
    self.fullAddress = [[NSMutableString alloc] init];
}

@end
