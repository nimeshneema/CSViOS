//
//  AppDelegate.m
//  CSViOS
//
//  Created by Nimesh Neema on 09/07/22.
//

#import "AppDelegate.h"

@interface AppDelegate () <CHCSVParserDelegate>

    // Extract data from combined.csv
@property (strong, nonatomic) NSMutableArray *combinedCSVAllAddresses;
@property (strong, nonatomic) NSString *combinedCSVcurrentlyReadAddress;

    // Find matches from pp-complete.csv
@property (strong, nonatomic) NSMutableString *ppCompleteCSVFullyConstructedAddress;

@property (strong, nonatomic) NSString *ppCompleteCSVAddress1;
@property (strong, nonatomic) NSString *ppCompleteCSVAddress2;
@property (strong, nonatomic) NSString *ppCompleteCSVAddress3;

@property (nonatomic) NSUInteger ppCompleteCSVCurrentLine;

@property (strong, nonatomic) CHCSVParser *combinedParser;
@property (strong, nonatomic) CHCSVParser *ppCompleteParser;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.combinedCSVAllAddresses = [[NSMutableArray alloc] init];
    self.combinedCSVcurrentlyReadAddress = nil;
    
    self.ppCompleteCSVFullyConstructedAddress = [[NSMutableString alloc] init];
    
    self.ppCompleteCSVAddress1 = nil;
    self.ppCompleteCSVAddress2 = nil;
    self.ppCompleteCSVAddress3 = nil;
    
    self.ppCompleteCSVCurrentLine = 0;
    
    NSString *combinedFilePath = [[NSBundle mainBundle] pathForResource:@"combined" ofType:@"csv"];
    self.combinedParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:combinedFilePath]];
    self.combinedParser.delegate = self;
    
    NSString *ppCompleteFilePath = [[NSBundle mainBundle] pathForResource:@"pp-complete" ofType:@"csv"];
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
    if (parser == self.combinedParser) {
        
    } else {
        self.ppCompleteCSVCurrentLine = recordNumber;
    }
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (parser == self.combinedParser) {
        // NSLog(@"CombinedParser Line#: %ld, %@", recordNumber, self.combinedCSVcurrentlyReadAddress);
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
        if (fieldIndex == 1) {
            if (field != nil && field.length > 0) {
                NSString *fieldString = field;
                
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
                NSString *trimmedString = [regex stringByReplacingMatchesInString:fieldString options:0 range:NSMakeRange(0, [fieldString length]) withTemplate:@" "];
                
                self.combinedCSVcurrentlyReadAddress = [trimmedString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            } else {
                self.combinedCSVcurrentlyReadAddress = @"";
            }
            [self.combinedCSVAllAddresses addObject:self.combinedCSVcurrentlyReadAddress];
        }
    } else {
        switch (fieldIndex) {
            case 7:
                self.ppCompleteCSVAddress1 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
                break;
            case 8:
                self.ppCompleteCSVAddress2 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
                break;
            case 9:
                self.ppCompleteCSVAddress3 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
                break;
            default:
                break;
        }
        
        if (fieldIndex == 10) {
            if (self.ppCompleteCSVAddress1.length != 0) {
                [self.ppCompleteCSVFullyConstructedAddress appendString:self.ppCompleteCSVAddress1];
                
                if (self.ppCompleteCSVAddress2.length != 0) {
                    [self.ppCompleteCSVFullyConstructedAddress appendFormat:@", %@", self.ppCompleteCSVAddress2];
                    
                    if (self.ppCompleteCSVAddress3.length != 0) {
                        [self.ppCompleteCSVFullyConstructedAddress appendFormat:@", %@", self.ppCompleteCSVAddress3];
                    }
                } else {
                    if (self.ppCompleteCSVAddress3.length != 0) {
                        [self.ppCompleteCSVFullyConstructedAddress appendFormat:@", %@", self.ppCompleteCSVAddress3];
                    }
                }
            } else {
                if (self.ppCompleteCSVAddress2.length != 0) {
                    [self.ppCompleteCSVFullyConstructedAddress appendString:self.ppCompleteCSVAddress2];
                    
                    if (self.ppCompleteCSVAddress3.length != 0) {
                        [self.ppCompleteCSVFullyConstructedAddress appendFormat:@", %@", self.ppCompleteCSVAddress3];
                    }
                } else {
                    if (self.ppCompleteCSVAddress3.length != 0) {
                        [self.ppCompleteCSVFullyConstructedAddress appendString:self.ppCompleteCSVAddress3];
                    }
                }
            }
        
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
            self.ppCompleteCSVFullyConstructedAddress = [NSMutableString stringWithString:[regex stringByReplacingMatchesInString:self.ppCompleteCSVFullyConstructedAddress options:0 range:NSMakeRange(0, [self.ppCompleteCSVFullyConstructedAddress length]) withTemplate:@" "]];
            
            [self checkAddress];
        }
    }
    
    return;
}

- (void)checkAddress {
    for (NSUInteger i = 1; i <= [self.combinedCSVAllAddresses count]; i++) {
        NSString *combinedFullAddressLowercased = [self.combinedCSVAllAddresses[i-1] lowercaseString];
        NSString *fullAddressLowercased = [self.ppCompleteCSVFullyConstructedAddress lowercaseString];
        
        if ([combinedFullAddressLowercased isEqualToString:fullAddressLowercased]) {
            NSLog(@"combined.csv: %ld, pp-complete.csv: %ld : %@", i+1, self.ppCompleteCSVCurrentLine, fullAddressLowercased);
        }
        
    }
    
    self.ppCompleteCSVFullyConstructedAddress = [[NSMutableString alloc] init];
}

@end
