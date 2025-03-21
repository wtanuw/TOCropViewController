//
//  TOCropOverlayView.m
//
//  Copyright 2015-2022 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropOverlayView.h"

static const CGFloat kTOCropOverLayerCornerWidth = 20.0f;

@interface TOCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left

@property (nonatomic, strong) NSArray *topLeftLineViews; //vertical, horizontal
@property (nonatomic, strong) NSArray *bottomLeftLineViews;
@property (nonatomic, strong) NSArray *bottomRightLineViews;
@property (nonatomic, strong) NSArray *topRightLineViews;

@end

@implementation TOCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    UIView *(^newLineView)(void) = ^UIView *(void){
        return [self createNewLineView];
    };
    self.cropFrameWidth = 1.0f;
    self.cropCornerLength = kTOCropOverLayerCornerWidth;
    self.cropCornerWidth = 3.0f;

    _outerLineViews     = @[newLineView(), newLineView(), newLineView(), newLineView()];
    
    _topLeftLineViews   = @[newLineView(), newLineView()];
    _bottomLeftLineViews = @[newLineView(), newLineView()];
    _topRightLineViews  = @[newLineView(), newLineView()];
    _bottomRightLineViews = @[newLineView(), newLineView()];
    
    self.displayHorizontalGridLines = YES;
    self.displayVerticalGridLines = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_outerLineViews) {
        [self layoutLines];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (_outerLineViews) {
        [self layoutLines];
    }
}

- (void)layoutLines
{
    CGSize boundsSize = self.bounds.size;
    
    //border lines
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];
        
        CGRect frame = CGRectZero;
        if (_cropExpandWidth == 0) {
//            switch (i) {
//                case 0: frame = (CGRect){0,-1.0f,boundsSize.width+2.0f, 1.0f}; break; //top
//                case 1: frame = (CGRect){boundsSize.width,0.0f,1.0f,boundsSize.height}; break; //right
//                case 2: frame = (CGRect){-1.0f,boundsSize.height,boundsSize.width+2.0f,1.0f}; break; //bottom
//                case 3: frame = (CGRect){-1.0f,0,1.0f,boundsSize.height+1.0f}; break; //left
//            }
            NSInteger horizontalFrameWidth = _cropFrameWidth;
            NSInteger verticalFrameWidth = _cropFrameWidth;
            NSInteger x = -_cropFrameWidth;
            NSInteger y = -_cropFrameWidth;
            switch (i) {
                case 0: frame = (CGRect){x,y,boundsSize.width+verticalFrameWidth+verticalFrameWidth, horizontalFrameWidth}; break; //top
                case 1: frame = (CGRect){boundsSize.width,0.0f,verticalFrameWidth,boundsSize.height}; break; //right
                case 2: frame = (CGRect){x,boundsSize.height,boundsSize.width+verticalFrameWidth+verticalFrameWidth,horizontalFrameWidth}; break; //bottom
                case 3: frame = (CGRect){x,0,verticalFrameWidth,boundsSize.height+horizontalFrameWidth}; break; //left
            }
        } else {
        NSInteger horizontalFrameWidth = _cropFrameWidth;
        NSInteger verticalFrameWidth = _cropFrameWidth;
        NSInteger x = -_cropFrameWidth - _cropExpandWidth;
        NSInteger y = -_cropFrameWidth;
        NSInteger width = boundsSize.width+_cropFrameWidth*2+_cropExpandWidth*2;
        NSInteger height = boundsSize.height+_cropFrameWidth;
        switch (i) {
            case 0: frame = (CGRect){x,y,width, horizontalFrameWidth}; break; //top
            case 1: frame = (CGRect){boundsSize.width+_cropExpandWidth,0.0f,verticalFrameWidth,boundsSize.height}; break; //right
            case 2: frame = (CGRect){x,boundsSize.height,width,horizontalFrameWidth}; break; //bottom
            case 3: frame = (CGRect){x,0,verticalFrameWidth,height}; break; //left
//            case 1: frame = (CGRect){width,y,verticalFrameWidth,height}; break; //right
//            case 2: frame = (CGRect){x,height,width,horizontalFrameWidth}; break; //bottom
//            case 3: frame = (CGRect){x,y,verticalFrameWidth,height}; break; //left
        }
        }
        
        lineView.frame = frame;
    }
    
    //corner liness
    NSArray *cornerLines = @[self.topLeftLineViews, self.topRightLineViews, self.bottomRightLineViews, self.bottomLeftLineViews];
    for (NSInteger i = 0; i < 4; i++) {
        NSArray *cornerLine = cornerLines[i];
        
        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        if (_cropExpandWidth == 0) {
            switch (i) {
                case 0: //top left
                    verticalFrame = (CGRect){-_cropCornerWidth,-_cropCornerWidth,_cropCornerWidth,_cropCornerLength+_cropCornerWidth};
                    horizontalFrame = (CGRect){0,-_cropCornerWidth,_cropCornerLength,_cropCornerWidth};
                    break;
                case 1: //top right
                    verticalFrame = (CGRect){boundsSize.width,-_cropCornerWidth,_cropCornerWidth,_cropCornerLength+_cropCornerWidth};
                    horizontalFrame = (CGRect){boundsSize.width-_cropCornerLength,-_cropCornerWidth,_cropCornerLength,_cropCornerWidth};
                    break;
                case 2: //bottom right
                    verticalFrame = (CGRect){boundsSize.width,boundsSize.height-_cropCornerLength,_cropCornerWidth,_cropCornerLength+_cropCornerWidth};
                    horizontalFrame = (CGRect){boundsSize.width-_cropCornerLength,boundsSize.height,_cropCornerLength,_cropCornerWidth};
                    break;
                case 3: //bottom left
                    verticalFrame = (CGRect){-_cropCornerWidth,boundsSize.height-_cropCornerLength,_cropCornerWidth,_cropCornerLength};
                    horizontalFrame = (CGRect){-_cropCornerWidth,boundsSize.height,_cropCornerLength+_cropCornerWidth,_cropCornerWidth};
                    break;
            }
        } else {
            switch (i) {
                case 0: //top left
                    verticalFrame = (CGRect){-_cropCornerWidth-_cropExpandWidth,-_cropCornerWidth,
                        _cropCornerWidth,_cropCornerLength+_cropCornerWidth};
                    horizontalFrame = (CGRect){0-_cropExpandWidth,-_cropCornerWidth,
                        _cropCornerLength,_cropCornerWidth};
                    break;
                case 1: //top right
                    verticalFrame = (CGRect){boundsSize.width+_cropExpandWidth,0-_cropCornerWidth,
                        _cropCornerWidth,_cropCornerLength+_cropCornerWidth};
                    horizontalFrame = (CGRect){boundsSize.width-_cropCornerLength+_cropExpandWidth,-_cropCornerWidth,
                        _cropCornerLength,_cropCornerWidth};
                    break;
                case 2: //bottom right
                    verticalFrame = (CGRect){boundsSize.width+_cropExpandWidth,boundsSize.height-_cropCornerLength,
                        _cropCornerWidth,_cropCornerLength+_cropCornerWidth};
                    horizontalFrame = (CGRect){boundsSize.width-_cropCornerLength+_cropExpandWidth,boundsSize.height,
                        _cropCornerLength,_cropCornerWidth};
                    break;
                case 3: //bottom left
                    verticalFrame = (CGRect){-_cropCornerWidth-_cropExpandWidth,boundsSize.height-_cropCornerLength,
                        _cropCornerWidth,_cropCornerLength};
                    horizontalFrame = (CGRect){-_cropCornerWidth-_cropExpandWidth,boundsSize.height,
                        _cropCornerLength+_cropCornerWidth,_cropCornerWidth};
                    break;
            }
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    //grid lines - horizontal
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    //grid lines - vertical
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;
    
    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
    
        return;
    }
    
    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
        
        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

#pragma mark - Property methods

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;
    
    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.horizontalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;
    
    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayVerticalGridLines) {
        self.verticalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.verticalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}

- (void)updateView
{
    if (_outerLineViews) {
        [self layoutLines];
    }
    
}

- (void)updateColor
{
    [_outerLineViews enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    [_topLeftLineViews enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    [_bottomLeftLineViews enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    [_topRightLineViews enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    [_bottomRightLineViews enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    UIView *(^newLineView)(void) = ^UIView *(void){
        return [self createNewLineView];
    };

    _outerLineViews     = @[newLineView(), newLineView(), newLineView(), newLineView()];
    
    _topLeftLineViews   = @[newLineView(), newLineView()];
    _bottomLeftLineViews = @[newLineView(), newLineView()];
    _topRightLineViews  = @[newLineView(), newLineView()];
    _bottomRightLineViews = @[newLineView(), newLineView()];
    
}



#pragma mark - Private methods

- (nonnull UIView *)createNewLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    if (self.cropFrameColor) {
        newLine.backgroundColor = self.cropFrameColor;
    } else {
        newLine.backgroundColor = [UIColor redColor];
    }
    [self addSubview:newLine];
    return newLine;
}

@end
