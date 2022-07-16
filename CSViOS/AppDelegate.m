//
//  AppDelegate.m
//  CSViOS
//
//  Created by Nimesh Neema on 09/07/22.
//

#import "AppDelegate.h"

@interface AppDelegate () <CHCSVParserDelegate>

    // Extract data from combined.csv (3,442,048)
@property (strong, nonatomic) NSMutableArray *combinedAll;
@property (strong, nonatomic) NSString *combinedCurrent;

    // Find matches from pp-complete.csv (27,176,256)
@property (strong, nonatomic) NSMutableArray *ppCompleteAll;
@property (strong, nonatomic) NSMutableString *ppCompleteCurrent;

@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *address3;

@property (nonatomic) NSUInteger ppCompleteCurrentLine;

@property (strong, nonatomic) CHCSVParser *combinedParser;
@property (strong, nonatomic) CHCSVParser *ppCompleteParser;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.combinedAll = [[NSMutableArray alloc] init];
    self.combinedCurrent = nil;
    
    self.ppCompleteAll = [[NSMutableArray alloc] init];
    self.ppCompleteCurrent = [[NSMutableString alloc] init];
    
    self.address1 = nil;
    self.address2 = nil;
    self.address3 = nil;
    
    self.ppCompleteCurrentLine = 0;
    
    NSString *combinedFilePath = [[NSBundle mainBundle] pathForResource:@"combined" ofType:@"csv"];
    self.combinedParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:combinedFilePath]];
    self.combinedParser.delegate = self;
    
    NSString *ppCompleteFilePath = [[NSBundle mainBundle] pathForResource:@"pp-complete" ofType:@"csv"];
    self.ppCompleteParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:ppCompleteFilePath]];
    self.ppCompleteParser.delegate = self;
    
    [self.combinedParser parse];
    // [self.ppCompleteParser parse];
    
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
        self.ppCompleteCurrentLine = recordNumber;
    }
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (parser == self.combinedParser) {
        // NSLog(@"CombinedParser Line#: %ld, %@", recordNumber, self.combinedCurrent);
    } else {
        
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    if (parser == self.combinedParser) {
        NSLog(@"End combinedParser");
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
                
                self.combinedCurrent = [trimmedString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            } else {
                self.combinedCurrent = @"";
            }
            [self.combinedAll addObject:[self.combinedCurrent lowercaseString]];
        }
    } else {
        if (fieldIndex == 7) {
            self.address1 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
        } else if (fieldIndex == 8) {
            self.address2 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
        } else if (fieldIndex == 9) {
            self.address3 = [field substringWithRange:NSMakeRange(1, [field length] - 2)];
        } else if (fieldIndex == 10) {
            if (self.address1.length != 0) {
                [self.ppCompleteCurrent appendString:self.address1];
                
                if (self.address2.length != 0) {
                    [self.ppCompleteCurrent appendFormat:@", %@", self.address2];
                    
                    if (self.address3.length != 0) {
                        [self.ppCompleteCurrent appendFormat:@", %@", self.address3];
                    }
                } else {
                    if (self.address3.length != 0) {
                        [self.ppCompleteCurrent appendFormat:@", %@", self.address3];
                    }
                }
            } else {
                if (self.address2.length != 0) {
                    [self.ppCompleteCurrent appendString:self.address2];
                    
                    if (self.address3.length != 0) {
                        [self.ppCompleteCurrent appendFormat:@", %@", self.address3];
                    }
                } else {
                    if (self.address3.length != 0) {
                        [self.ppCompleteCurrent appendString:self.address3];
                    }
                }
            }
        
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
            self.ppCompleteCurrent = [NSMutableString stringWithString:[[regex stringByReplacingMatchesInString:self.ppCompleteCurrent options:0 range:NSMakeRange(0, [self.ppCompleteCurrent length]) withTemplate:@" "] lowercaseString]];
        }
    }
    
    return;
}

//- (void)checkAddress {
//    for (NSUInteger i = 1; i <= [self.combinedAll count]; i++) {
//        if ([combinedFullAddressLowercased isEqualToString:fullAddressLowercased]) {
//             NSLog(@"combined.csv: %ld, pp-complete.csv: %ld : %@", i+1, self.ppCompleteCurrentLine, fullAddressLowercased);
//        }
//    }
//
//    self.ppCompleteCurrent = [[NSMutableString alloc] init];
//}

@end
