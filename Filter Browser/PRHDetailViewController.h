//
//  PRHDetailViewController.h
//  Filter Browser
//
//  Created by Peter Hosey on 2013-04-07.
//  Copyright (c) 2013 Peter Hosey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRHDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
