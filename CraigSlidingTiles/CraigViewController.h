//
//  CraigViewController.h
//  CraigSlidingTiles
//
//  Created by Event on 7/11/13.
//  Copyright (c) 2013 Craig Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CraigViewController : UIViewController {
    NSMutableArray *gameValues; // zero is open
    NSMutableArray *gameViews;
}

- (UIButton *) addTileWithValue: (int)value atPosition: (int)position;

- (void) startGame;

- (BOOL) checkWin;

- (IBAction) startOverTapped:(id)sender;

- (void) tileTapped:(id)sender;

@property IBOutlet UIView *gameBoard;
@property IBOutlet UILabel *winNotice;

@end
