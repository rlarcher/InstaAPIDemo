//
//  ViewController.h
//  InstaAPIDemo
//
//  Created by Ryan Archer on 8/19/16.
//  Copyright © 2016 RyanArcher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSString *profile_image_url;

@property UIWebView *authView;

@property NSMutableArray *images;

@end

