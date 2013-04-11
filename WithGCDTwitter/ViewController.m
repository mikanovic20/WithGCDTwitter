//
//  ViewController.m
//  WithGCDTwitter
//
//  Created by mikanovic on 2013/04/11.
//  Copyright (c) 2013 mikanovic20. All rights reserved.
//

#import "ViewController.h"
#import "TwitterWrapper.h"

const int IMAGE_Q_SIZE = 5;
static NSString *DUMMY_ICON_NAME = @"dummy.png";

@interface ViewController ()
{
    NSArray *_timeLine;
    dispatch_queue_t _main_queue;
    dispatch_queue_t _image_queue[IMAGE_Q_SIZE];
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _main_queue = dispatch_get_main_queue();
    char qLabel[256];
    for (int i = 0; i < IMAGE_Q_SIZE; i++) {
        sprintf(qLabel, "com.mik.sample.image%d", i);
        _image_queue[i] = dispatch_queue_create(qLabel, NULL);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [TwitterWrapper homeTimeLine:^(NSArray *timeLine){
        _timeLine = timeLine;
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)getImage:(NSString *)url
{
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSHTTPURLResponse *response;
    NSError *error = nil;
    
    NSData *imageData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    if (imageData && response.statusCode == 200) {
        return [UIImage imageWithData:imageData];
    } else {
        NSLog(@"NSURLConnection error = %@, status = %d", error, response.statusCode);
        return nil;
    }
}

#pragma TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_timeLine count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"
                                                            forIndexPath:indexPath];
    
    NSDictionary *tweet = _timeLine[indexPath.row];
    
    cell.textLabel.text = tweet[@"text"];
    cell.detailTextLabel.text = tweet[@"user"][@"name"];
    //cell.imageView.image = [self getImage:tweet[@"user"][@"profile_image_url"]];
    cell.imageView.image = [UIImage imageNamed:DUMMY_ICON_NAME];
    
    dispatch_async(_image_queue[[indexPath row] % IMAGE_Q_SIZE], ^{
        UIImage *icon = [self getImage:tweet[@"user"][@"profile_image_url"]];
        dispatch_async(_main_queue, ^{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.imageView.image = icon;
        });
    });
    
    return cell;
}

@end
