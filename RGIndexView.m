//
//  RGIndexView.m
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

#import "RGIndexView.h"

@interface RGIndexView() {
    int _numberOfItems;
    int _lastSelectedIndex;
    int _numberOfItemsToDisplay;
}

@end

@implementation RGIndexView

static int kRGIndexViewIndexLabelBaseTag = 10;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)layoutSubviews {
    [self alignLabels];
}

- (BOOL)vertical {
    return self.frame.size.height > self.frame.size.width;
}

- (BOOL)willTruncate {
    return _numberOfItems > _numberOfItemsToDisplay;
}

- (void)alignLabels {
    for (int i = 0; i < _numberOfItems; i++) {
        UIView* view = [self viewWithTag:kRGIndexViewIndexLabelBaseTag +i];
        view.frame = [self frameForLabelAtIndex:i];
    }
}

- (CGSize)indexLabelSizeForCount:(int)count {
    if (self.vertical) {
        return CGSizeMake(self.frame.size.width,
                          self.frame.size.height / count);
    }
    else {
        return CGSizeMake(self.frame.size.width / count,
                          self.frame.size.height);
    }
}

- (CGRect)frameForLabelAtIndex:(int)index {
    CGSize labelSize = [self indexLabelSizeForCount:_numberOfItemsToDisplay];
    
    if (self.vertical) {
        return CGRectMake(0,
                          index * self.frame.size.height / _numberOfItemsToDisplay,
                          labelSize.width,
                          labelSize.height);
    }
    else {
        return CGRectMake(index * self.frame.size.width / _numberOfItemsToDisplay,
                          0,
                          labelSize.width,
                          labelSize.height);
    }
}

- (void)reloadIndex {
    if (_font == nil) {
        self.font = [UIFont systemFontOfSize:17];
    }
    if (_textColor == nil) {
        self.textColor = [UIColor blackColor];
    }
    
    _numberOfItems = [_delegate numberOfItemsInIndexView];
    if (self.vertical) {
        _numberOfItemsToDisplay = ([self indexLabelSizeForCount:_numberOfItems].height < _font.pointSize) ? floor(self.frame.size.height / _font.pointSize) : _numberOfItems;
    }
    else {
        _numberOfItemsToDisplay = ([self indexLabelSizeForCount:_numberOfItems].width < _font.pointSize) ? floor(self.frame.size.width / _font.pointSize) : _numberOfItems;
    }
    
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < _numberOfItemsToDisplay; i++) {
        UILabel* indexLabel = [[UILabel alloc] initWithFrame:[self frameForLabelAtIndex:i]];
        indexLabel.backgroundColor = [UIColor clearColor];
        indexLabel.textColor = _textColor;
        indexLabel.font = _font;
        indexLabel.textAlignment = UITextAlignmentCenter;
        if (self.willTruncate) {
            indexLabel.text = i % 2 == 1 ? @"·" : [_delegate textForIndex:[self getIndexFromSelectableIndex:i]];
        }
        else {
            indexLabel.text = [_delegate textForIndex:i];
        }
        indexLabel.tag = kRGIndexViewIndexLabelBaseTag +i;
        [self addSubview:indexLabel];
    }
}

- (int)getIndexFromSelectableIndex:(int)selectableIndex {
    float si = selectableIndex;
    NSNumber* index = [NSNumber numberWithDouble: (si / _numberOfItemsToDisplay) * _numberOfItems];
    return index.intValue;
}

- (int)getSelectedIndexFromTouch:(UITouch*)touch {
    int index;
    CGSize elementSize = [self indexLabelSizeForCount:_numberOfItemsToDisplay];
    CGPoint positionInView = [touch locationInView:self];
    CGFloat itemSize = self.vertical ? elementSize.height : elementSize.width;
    CGFloat selectionPosition = self.vertical ? positionInView.y : positionInView.x;
    index = floor(selectionPosition / itemSize);
    
    if (self.willTruncate) {
        index = [self getIndexFromSelectableIndex:index];
    }
    index = MAX(MIN(index, _numberOfItemsToDisplay - 1), 0);
    
    NSLog(@"index changed to %i", index);
    return index;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [touches anyObject];
    _lastSelectedIndex = [self getSelectedIndexFromTouch:touch];
    
    if ([_delegate respondsToSelector:@selector(indexView:didBeginSelectingAtIndex:)]) {
        [_delegate indexView:self didBeginSelectingAtIndex:_lastSelectedIndex];
    }
    if ([_delegate respondsToSelector:@selector(indexView:didSelectIndex:)]) {
        [_delegate indexView:self didSelectIndex:_lastSelectedIndex];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    int selectedIndex = [self getSelectedIndexFromTouch:touch];
    if (selectedIndex != _lastSelectedIndex) {
        _lastSelectedIndex = selectedIndex;
        if ([_delegate respondsToSelector:@selector(indexView:didSelectIndex:)]) {
            [_delegate indexView:self didSelectIndex:selectedIndex];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _lastSelectedIndex = [self getSelectedIndexFromTouch:touch];
    
    if ([_delegate respondsToSelector:@selector(indexView:didEndSelectingAtIndex:)]) {
        [_delegate indexView:self didEndSelectingAtIndex:_lastSelectedIndex];
    }
}

@end
