//
//  ViewController.m
//  InstaAPIDemo
//
//  Created by Ryan Archer on 8/19/16.
//  Copyright © 2016 RyanArcher. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "InstaAPIDemoConstants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [[NSMutableArray alloc] init];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    NSString *requestPath = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", INSTA_CLIENT_ID, INSTA_REDIRECT_URI];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestPath]];
    self.authView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.authView.delegate = self;
    [self.authView loadRequest:request];
    [self.view addSubview:self.authView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadPhotos {
    // retrieve token for use in requests
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:INSTA_TOKEN_STRING];
    NSLog(@"Got the token and it is %@",token);
    // set up request
    NSString *requestPath = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@",token];
    NSURL *url = [NSURL URLWithString:requestPath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSArray *images = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"data"];
    NSString *imageURL = nil;
    // go through the 20 most recent photos
    for (int i = 0; i < [images count]; i++) {
        imageURL = [[[[images objectAtIndex:i] objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"];
        // add photo url to array
        [self.images addObject:imageURL];
    }
    [self.authView removeFromSuperview];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *cellImageView = (UIImageView*)[cell viewWithTag:100];
    // if images have been loaded then add them to cell
    if([self.images count] >= 1) {
        NSURL *prof_url = [NSURL URLWithString:[self.images objectAtIndex:indexPath.row]];
        NSData *imageData = [NSData dataWithContentsOfURL:prof_url];
        cellImageView.image = [[UIImage alloc] initWithData:imageData];
        [cell addSubview:cellImageView];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(MAX_PICS, [self.images count]);
}

#pragma mark - UIWebView Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // get token from request string
    NSString* url = [[request URL] absoluteString];
    NSArray *splitUrl = [url componentsSeparatedByString:@"token="];
    // check if token is in request string
    if ([splitUrl count] > 1) {
        NSString *token = [splitUrl objectAtIndex:1];
        NSLog(@"%@",token);
        // save token
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:token forKey:INSTA_TOKEN_STRING];
        [self loadPhotos];
        return NO;
    }
    return YES;
}

@end
