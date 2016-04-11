//
//  LPMovieSizesView.m
//  iVideo
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPMovieSizesView.h"

static const NSInteger LabelCount = 3;

@interface LPMovieSizesView ()
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *borderLayers;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) NSUInteger availableCount;
@property (nonatomic, strong) UILabel *selectedLabel;
@property (nonatomic, copy) LPMovieSizeSelectionHandler handler;
@property (nonatomic, strong) NSArray *titles;
@end

@implementation LPMovieSizesView

- (instancetype)initWithPadding:(CGFloat)padding
             availableSizeCount:(NSInteger)count
               selectionHandler:(LPMovieSizeSelectionHandler)handler {
    if (self = [super init]) {
        _padding = padding;
        _availableCount = count;
        _handler = handler;
        _titles = @[@"480P\n720*480", @"720P\n1280*720", @"1080P\n1920*1080"];
        
        [self setupSubviews];
        
        self.selectedLabel = self.labels[count - 1];
    }
    return self;
}

- (void)setupSubviews {
    NSMutableArray *labels = [NSMutableArray array];
    NSMutableArray *borders = [NSMutableArray array];
    for (NSInteger i = 0; i < LabelCount; ++ i) {
        BOOL available = i < self.availableCount;
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.attributedText = [self attributedStringWithString:self.titles[i] available:available selected:NO];
        [labels addObject:label];
        [self addSubview:label];
        label.userInteractionEnabled = available;
        label.tag = i;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [label addGestureRecognizer:gr];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = available ? ThemeColor.CGColor : [UIColor lightGrayColor].CGColor;
        layer.lineWidth = 1.f;
        layer.fillColor = [UIColor clearColor].CGColor;
        [borders addObject:layer];
        [label.layer addSublayer:layer];
    }
    self.labels = labels;
    self.borderLayers = borders;
}

- (NSAttributedString *)attributedStringWithString:(NSString *)string
                                         available:(BOOL)available
                                          selected:(BOOL)selected {
    NSInteger newLineLocation = [string rangeOfString:@"\n"].location;
    NSRange titleRange = NSMakeRange(0, newLineLocation);
    NSRange subtitleRange = NSMakeRange(newLineLocation + 1, string.length - newLineLocation - 1);
    
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
    UIFont *subtitleFont = [UIFont boldSystemFontOfSize:10];
    [as addAttribute:NSFontAttributeName value:titleFont range:titleRange];
    [as addAttribute:NSFontAttributeName value:subtitleFont range:subtitleRange];
    UIColor *titleColor = selected ? HighlightedColor : ThemeColor;
    UIColor *subtitleColor = [UIColor lightGrayColor];
    [as addAttribute:NSForegroundColorAttributeName value:titleColor range:titleRange];
    [as addAttribute:NSForegroundColorAttributeName value:subtitleColor range:subtitleRange];
    return as;
}

- (void)setSelectedLabel:(UILabel *)selectedLabel {
    if (self.selectedLabel && selectedLabel.tag == self.selectedLabel.tag) return;
    
    NSInteger selectedTag = selectedLabel.tag;
    NSInteger previousTag = self.selectedLabel.tag;
    if (self.selectedLabel) {
        self.selectedLabel.attributedText = [self attributedStringWithString:self.titles[previousTag]
                                                                   available:YES
                                                                    selected:NO];
        CAShapeLayer *border = self.borderLayers[previousTag];
        border.strokeColor = ThemeColor.CGColor;
    }
    selectedLabel.attributedText = [self attributedStringWithString:self.titles[selectedTag]
                                                          available:YES
                                                           selected:YES];
    CAShapeLayer *border = self.borderLayers[selectedTag];
    border.strokeColor = HighlightedColor.CGColor;
    
    _selectedLabel = selectedLabel;
}

- (void)tap:(UIGestureRecognizer *)gr {
    NSInteger tag = gr.view.tag;
    self.selectedLabel = self.labels[tag];
    if (self.handler) {
        self.handler(tag);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = (self.width - self.padding * (LabelCount - 1)) / LabelCount;
    CGFloat y = 0;
    CGFloat x = 0;
    CGFloat h = self.height;
    for (NSInteger i = 0; i < LabelCount; ++ i) {
        UILabel *label = self.labels[i];
        label.x = x + (w + self.padding) * i;
        label.y = y;
        label.width = w;
        label.height = h;
        
        CAShapeLayer *border = self.borderLayers[i];
        border.path = [UIBezierPath bezierPathWithRoundedRect:label.bounds cornerRadius:5].CGPath;
    }
}
@end
