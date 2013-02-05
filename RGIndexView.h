//
//  RGIndexView.h
//
//  Created by Roman Gille on 04.12.12.
//  Copyright (c) 2012 Roman Gille. All rights reserved.
//
//  Distributed under the permissive zlib license
//  Get the latest version from this location:
//
//  https://github.com/r-dent/RGIndexView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <UIKit/UIKit.h>

typedef enum {
    RGIndexViewDisplayModeTruncate = 0,
    RGIndexViewDisplayModeFull
} RGIndexViewDisplayMode;

@protocol RGIndexViewDelegate;


@interface RGIndexView : UIView

@property (nonatomic, strong) IBOutlet id<RGIndexViewDelegate> delegate;
@property (nonatomic, readonly) BOOL vertical;
@property (nonatomic, readonly) BOOL willTruncate;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, assign) RGIndexViewDisplayMode displayMode;

- (void) reloadIndex;

@end


@protocol RGIndexViewDelegate <NSObject>

@required

- (NSString*)textForIndex:(int)index;
- (int)numberOfItemsInIndexView;


@optional

- (void)indexView:(RGIndexView*)indexView didSelectIndex:(int)index;
- (void)indexView:(RGIndexView*)indexView didBeginSelectingAtIndex:(int)index;
- (void)indexView:(RGIndexView*)indexView didEndSelectingAtIndex:(int)index;

@end
