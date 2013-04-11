//
//  TwitterWrapper.h
//  WithGCDTwitter
//
//  Created by mikanovic on 2013/04/11.
//  Copyright (c) 2013 mikanovic20. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterWrapper : NSObject

+ (void)homeTimeLine:(void(^)(NSArray *timeLine))doneProc;

@end
