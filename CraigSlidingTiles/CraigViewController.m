//
//  CraigViewController.m
//  CraigSlidingTiles
//
//  Created by Event on 7/11/13.
//  Copyright (c) 2013 Craig Co. All rights reserved.
//

#import "CraigViewController.h"

@implementation CraigViewController

@synthesize gameBoard, winNotice;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // autostart
    [self startGame];
}


- (UIButton *) addTileWithValue: (int)value atPosition: (int)position {
    int row = (int)floor(position / 4);
    int col = position % 4;
    
    UIButton *myTile = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [myTile setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
    [myTile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    myTile.titleLabel.font = [UIFont boldSystemFontOfSize:25.0];
    myTile.frame = CGRectMake(col * 75, row * 75, 75, 75);
    [myTile addTarget:self action:@selector(tileTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.gameBoard addSubview:myTile];
    
    return myTile;
}

- (void) startGame {
    // reinitialize value collection (don't really need this separate from gameViews, probably)
    gameValues = [[NSMutableArray alloc] initWithCapacity:16];
    NSUInteger i;
    
    // fill
    for (i=0; i<16; i++) {
        [gameValues addObject:[NSNumber numberWithInt:i]];
    }
    
    // shuffle
    do {
        for (i=0; i<16; i++) {
            NSInteger nElements = 16 - i;
            NSInteger n = (arc4random() % nElements) + i;
            [gameValues exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    } while ([self checkWin]);
    
    //NSLog(@"the game values: %@", gameValues);

    // clear views
    for (UIView *subView in self.gameBoard.subviews) {
        [subView removeFromSuperview];
    }
    
    // reinitialize tile collection
    gameViews = [[NSMutableArray alloc] initWithCapacity:16];
    
    for (i=0; i<16; i++) {
        UIButton *newTile = [self addTileWithValue:[[gameValues objectAtIndex:i] integerValue] atPosition:i];
        [gameViews addObject:newTile];
    }
}

- (BOOL) checkWin {
    for (int i = 0; i < 16; i++) {
        int posValue = [[gameValues objectAtIndex:i] integerValue];
        
        if(i != posValue) return NO;
    }
    return YES;
}

- (IBAction) startOverTapped:(id)sender {
    [self startGame];
}

- (void) tileTapped:(id)sender {
    NSString *titleText = ((UIButton *)sender).titleLabel.text;
    int titleInt = [titleText intValue];
    NSLog(@"you tapped tile with value %@", titleText);
    
    if(titleInt > 0) {
        
    }
}

@end
