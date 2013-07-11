//
//  CraigViewController.m
//  CraigSlidingTiles
//
//  Created by Event on 7/11/13.
//  Copyright (c) 2013 Craig Co. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CraigViewController.h"

#define TILESIZE 73.0f

@implementation CraigViewController

@synthesize gameBoard, winNotice;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // autostart
    [self startGame];
}

- (UIButton *) addTileWithValue: (int)value atPosition: (int)position {
    UIButton *myTile = [UIButton buttonWithType:UIButtonTypeCustom];

    if(value > 0) {

        // Draw a custom gradient
        CAGradientLayer *btnGradient = [CAGradientLayer layer];
        btnGradient.frame = CGRectMake(0, 0, TILESIZE, TILESIZE);
        btnGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                              (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                              nil];
        [myTile.layer insertSublayer:btnGradient atIndex:0];

        CALayer *btnLayer = [myTile layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:10.0f];

        [myTile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    } else {
        myTile.backgroundColor = [UIColor clearColor];
        myTile.layer.borderColor = [UIColor clearColor].CGColor;
        [myTile setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
    [myTile setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
    myTile.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
    myTile.frame = [self getRectForObjectAtIndex: position];
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
    
    gameInProgress = YES;
    self.winNotice.hidden = YES;
}

- (BOOL) checkWin {
    // check for order
    for (int i = 0; i < 16; i++) {
        int posValue = [[gameValues objectAtIndex:i] intValue];
        
        if(i != posValue) return NO;
    }
    gameInProgress = NO;
    self.winNotice.hidden = NO;
    return YES;
}

- (IBAction) startOverTapped:(id)sender {
    [self startGame];
}

- (void) tileTapped:(id)sender {
    if(gameInProgress == NO) return;
    
    NSString *titleText = ((UIButton *)sender).titleLabel.text;
    int titleInt = [titleText intValue];
    int valueIndex = [gameValues indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        // find the index of the value tapped.
        if([(NSNumber *)obj intValue] == titleInt) {
            return YES;
        } else {
            return NO;
        }
    }];
    //NSLog(@"you tapped tile with value %@ which is at position %d", titleText, valueIndex);
    
    if(titleInt > 0) {
        if(valueIndex > 3) {
            //check above
            int aboveIndex = valueIndex - 4;
            if([[gameValues objectAtIndex:aboveIndex] intValue] == 0) {
                [self moveFrom:valueIndex to:aboveIndex];
                return;
            }
        }
        if(valueIndex < 12) {
            // check below
            int belowIndex = valueIndex + 4;
            if([[gameValues objectAtIndex:belowIndex] intValue] == 0) {
                [self moveFrom:valueIndex to:belowIndex];
                return;
            }
        }
        if(valueIndex % 4 > 0) {
            // check left
            int leftIndex = valueIndex - 1;
            if([[gameValues objectAtIndex:leftIndex] intValue] == 0) {
                [self moveFrom:valueIndex to:leftIndex];
                return;
            }
        }
        if(valueIndex % 4 < 3) {
            //check right
            int rightIndex = valueIndex + 1;
            if([[gameValues objectAtIndex:rightIndex] intValue] == 0) {
                [self moveFrom:valueIndex to:rightIndex];
                return;
            }

        }
    }
}

- (void) moveFrom:(int)fromIndex to:(int)toIndex {
    [gameValues exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    [gameViews exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    
    UIButton *zeroButton = [gameViews objectAtIndex:fromIndex];
    zeroButton.hidden = YES;
    UIButton *movedButton = [gameViews objectAtIndex:toIndex];
    
    [self playMoveSound];
    [UIView animateWithDuration:0.3 animations:^{
        movedButton.frame = [self getRectForObjectAtIndex:toIndex];
    } completion:^(BOOL finished){
        zeroButton.frame = [self getRectForObjectAtIndex:fromIndex];
        zeroButton.hidden = NO;
        [self checkWin];
    }];
}

- (CGRect) getRectForObjectAtIndex: (int)index {
    int row = (int)floor(index / 4);
    int col = index % 4;
    
    return CGRectMake(col * 75, row * 75, TILESIZE, TILESIZE);
}

- (void) playMoveSound {
    SystemSoundID audioEffect;
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"hit-01" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
/*
    // call the following function when the sound is no longer used
    // (must be done AFTER the sound is done playing)
    AudioServicesDisposeSystemSoundID(audioEffect);
*/
}

@end
