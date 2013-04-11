//
//  TwitterWrapper.m
//  WithGCDTwitter
//
//  Created by mikanovic on 2013/04/11.
//  Copyright (c) 2013 mikanovic20. All rights reserved.
//

#import "TwitterWrapper.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

NSString *TWITTER_HOME_TIME_LINE_URL = @"http://api.twitter.com/1/statuses/home_timeline.json";

@implementation TwitterWrapper

+ (void)homeTimeLine:(void(^)(NSArray *timeLine))doneProc
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType
         options:nil
      completion:^(BOOL granted, NSError *error){
                   
          if (!granted) {
              NSLog(@"Not Granted!");
              return;
          }
          
          NSArray *accounts = [accountStore accountsWithAccountType:accountType];
          ACAccount *twitterAccount = accounts[0];
          SLRequest *request =
          [SLRequest requestForServiceType:SLServiceTypeTwitter
                             requestMethod:SLRequestMethodGET
                                       URL:[NSURL URLWithString:TWITTER_HOME_TIME_LINE_URL]
                                parameters:@{@"include_rts" : @"1", @"count" : @"100"}];
          
          [request setAccount:twitterAccount];
          
          [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
              if ([urlResponse statusCode] == 200) {
                  NSError *jsonParsingError = nil;
                  NSArray *twitterResponse = [NSJSONSerialization
                                              JSONObjectWithData:responseData
                                              options:0
                                              error:&jsonParsingError];
                  doneProc(twitterResponse);
              } else {
                  NSLog(@"Twitter get error %d", [urlResponse statusCode]);
              }
          }];
    }];
}

@end
