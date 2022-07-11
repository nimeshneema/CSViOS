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
    self.combinedAddresses = [[NSMutableArray alloc] init];
    self.fullAddress = [[NSMutableString alloc] init];
    self.lines = [[NSMutableArray alloc] init];
    
    self.address1 = nil;
    self.address2 = nil;
    self.address3 = nil;
    
    NSString *combinedFilePath = [[NSBundle mainBundle] pathForResource:@"combined" ofType:@"csv"];
    NSString *ppCompleteFilePath = [[NSBundle mainBundle] pathForResource:@"pp-complete" ofType:@"csv"];
     
    self.combinedParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:combinedFilePath]];
    self.combinedParser.delegate = self;
    
    self.ppCompleteParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:ppCompleteFilePath]];
    self.ppCompleteParser.delegate = self;
    
    [self.combinedParser parse];
    
    return YES;
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (parser == self.combinedParser) {
         // NSLog(@"DidEndLine: %ld, Added items: %ld", recordNumber, [self.combinedAddresses count]);
    } else {
        
    }
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    if (parser == self.combinedParser) {
        NSLog(@"Begin combinedParser");
    } else {
        NSLog(@"Begin ppCompleteParser");
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    if (parser == self.combinedParser) {
        NSLog(@"End combinedParser");
        [self.ppCompleteParser parse];
    } else {
        NSLog(@"End ppCompleteParser");
        NSLog(@"%@", self.lines);
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
                
                [self.combinedAddresses addObject:[trimmedString substringWithRange:NSMakeRange(1, [trimmedString length] - 2)]];
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
            self.fullAddress = [NSMutableString stringWithFormat:@"%@ %@ %@", self.address1, self.address2, self.address3];
        
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
    for (int i = 1; i <= [self.combinedAddresses count]; i++) {
        if ([self.fullAddress isEqualToString:[self.combinedAddresses objectAtIndex:(i-1)]]) {
            [self.lines addObject:[NSNumber numberWithInt:i]];
            NSLog(@"%d: %@", i, self.fullAddress);
        }
    }
}

@end
