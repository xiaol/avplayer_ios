//
//  LPLineLayout.m
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPLineLayout.h"
#import "LPLineLayoutAttributes.h"
#import "LPLineTransitionDecoration.h"
#import <objc/runtime.h>

static char LPScrollDirectionKey;

static NSString *LPLineDecorationViewKind = @"line.decoration.reuse.id";
static NSString * const LPLineCollectionViewKeyPath = @"collectionView";
//static const NSString * LPLineCollectionViewContext;

typedef NS_ENUM(NSUInteger, LPScrollDirection) {
    LPScrollDirectionUnknown = 0,
    LPScrollDirectionLeft,
    LPScrollDirectionRight
};

@interface CADisplayLink (LPScrollDirection)

@property (nonatomic, assign) LPScrollDirection direction;

@end

@implementation CADisplayLink (LPScrollDirection)

- (void)setDirection:(LPScrollDirection)direction {
    objc_setAssociatedObject(self, &LPScrollDirectionKey, @(direction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LPScrollDirection)direction {
    return [(NSNumber *)objc_getAssociatedObject(self, &LPScrollDirectionKey) unsignedIntegerValue];
}

@end


@interface UICollectionViewCell (LPSnapshot)

- (UIView *)snapshot;

@end

@implementation UICollectionViewCell (LPSnapshot)

- (UIView *)snapshot {
//    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
//        return [self snapshotViewAfterScreenUpdates:YES];
//    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return [[UIImageView alloc] initWithImage:image];
//    }
}

@end


@interface LPLineLayout () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) CGPoint maskCenter;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, weak) id<LPLineLayoutDataSource> dataSource;
@property (nonatomic, weak) id<LPLineLayoutDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) CGFloat autoScrollTrigger;
@property (nonatomic, assign) CGPoint panTranslation;

@property (nonatomic, assign) BOOL gesturesSetuped;

@end

@implementation LPLineLayout

+ (Class)layoutAttributesClass {
    return [LPLineLayoutAttributes class];
}

- (void)setupGestures {
    if (!_gesturesSetuped) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPress.delegate = self;
        for (UIGestureRecognizer *gr in self.collectionView.gestureRecognizers) {
            if ([gr isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gr requireGestureRecognizerToFail:_longPress];
            }
        }
        [self.collectionView addGestureRecognizer:_longPress];
        
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _pan.delegate = self;
        [self.collectionView addGestureRecognizer:_pan];
        
        _gesturesSetuped = YES;
    }
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self setupGestures];
    
    self.minimumInteritemSpacing = ItemSpacing;
    self.sectionInset = UIEdgeInsetsMake(SectionInset, SectionInset, SectionInset, SectionInset);
    self.itemSize = CGSizeMake(ItemWidth, ItemHeight);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _autoScrollTrigger = 30.0f;
    
    [self registerClass:[LPLineTransitionDecoration class] forDecorationViewOfKind:LPLineDecorationViewKind];
}

- (NSInteger)itemCount {
    return [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
}

- (id<LPLineLayoutDelegate>)delegate {
    return (id<LPLineLayoutDelegate>)self.collectionView.delegate;
}

- (id<LPLineLayoutDataSource>)dataSource {
    return (id<LPLineLayoutDataSource>)self.collectionView.dataSource;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *tempAttrsArray = [NSMutableArray arrayWithArray:attributesArray];
    CGFloat decorationW = 28.0f;
    CGFloat decorationH = 28.0f;
    CGFloat substraction = (decorationW - self.minimumInteritemSpacing) / 2.0f;
    CGFloat decorationY = (self.itemSize.height - decorationH) / 2.0f + self.sectionInset.top;
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
//            [self applyCellAttributes:attributes];
            if (attributes.indexPath.item != [self itemCount] - 1) {
                NSIndexPath *indexPath = attributes.indexPath;
                LPLineLayoutAttributes *decorationAttr = [LPLineLayoutAttributes layoutAttributesForDecorationViewOfKind:LPLineDecorationViewKind withIndexPath:indexPath];
                decorationAttr.transitionType = [self.delegate collectionView:self.collectionView
                                                                       layout:self
                                                    transitionTypeAtIndexPath:indexPath];
                CGFloat decorationX = CGRectGetMaxX(attributes.frame) - substraction + 2;
                decorationAttr.frame = CGRectMake(decorationX, decorationY, decorationW, decorationH);
                decorationAttr.zIndex = attributes.zIndex + 1;
                [tempAttrsArray addObject:decorationAttr];
            }
        }
    }
    return tempAttrsArray.copy;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
//    if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
//        [self applyCellAttributes:attributes];
//    }
//    return attributes;
//}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    LPLineLayoutAttributes *attr = (LPLineLayoutAttributes *)[super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
    attr.transitionType = [self.delegate collectionView:self.collectionView
                                                 layout:self
                              transitionTypeAtIndexPath:indexPath];
    return attr;
}

- (void)applyCellAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if ([attributes.indexPath isEqual:self.selectedIndexPath]) {
        attributes.hidden = YES;
    }
}

- (void)dealloc {
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            self.panTranslation = [pan translationInView:self.collectionView];
            self.maskView.center = CGPointMake(self.maskCenter.x + self.panTranslation.x, self.maskCenter.y);
            
            [self exchangeCells];
            
            if (CGRectGetMaxX(self.maskView.frame) > CGRectGetMaxX(self.collectionView.bounds) - self.autoScrollTrigger && self.panTranslation.x > 0) {
                if (ceilf(self.collectionView.contentOffset.x) + self.collectionView.bounds.size.width < self.collectionView.contentSize.width) {
                    [self startTimerWithDirection:LPScrollDirectionRight];
                }
            } else if (CGRectGetMinX(self.maskView.frame) < CGRectGetMinX(self.collectionView.bounds) + self.autoScrollTrigger && self.panTranslation.x < 0) {
                if (self.collectionView.contentOffset.x > - self.collectionView.contentInset.left) {
                    [self startTimerWithDirection:LPScrollDirectionLeft];
                }
            } else {
                [self invalidateTimer];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gr {
    CGPoint location = [gr locationInView:self.collectionView];
    
//    static UIView *snapshot = nil;
    switch (gr.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
            if (indexPath) {
                if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]
                     && ![self.dataSource collectionView:self.collectionView canMoveItemAtIndexPath:indexPath])
                    return;
                
                self.selectedIndexPath = indexPath;
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                    [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:indexPath];
                }
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//                cell.highlighted = YES;
//                UIView *highlightedSnapshot = [cell snapshot];
//                highlightedSnapshot.alpha = 1.0;
//                cell.highlighted = NO;
                UIView *snapshot = [cell snapshot];
                snapshot.alpha = 0.0;
                self.maskView = [[UIView alloc] initWithFrame:cell.frame];
                [self.maskView addSubview:snapshot];
//                [self.maskView addSubview:highlightedSnapshot];
                [self.collectionView addSubview:self.maskView];
                
                self.maskCenter = self.maskView.center;
                
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options:0
                                 animations:^{
                                     self.maskView.transform = CGAffineTransformMakeScale(1.05, 1.05);
//                                     highlightedSnapshot.alpha = 0.0;
                                     snapshot.alpha = 1.0;
                                 } completion:^(BOOL finished) {
//                                     [highlightedSnapshot removeFromSuperview];
                                     cell.alpha = 0.0;
                                     if ([self.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
                                         [self.delegate collectionView:self.collectionView
                                                                layout:self
                                       didBeginDraggingItemAtIndexPath:self.selectedIndexPath];
                                     }
                                 }];
//                [self invalidateLayout];
            }
        }   break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [self invalidateTimer];
            NSIndexPath *indexPath = self.selectedIndexPath;
            if (indexPath) {
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
                    [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:indexPath];
                }
                
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                self.longPress.enabled = NO;
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options:0
                                 animations:^{
                                     self.maskView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                     self.maskView.center = attributes.center;
                                 } completion:^(BOOL finished) {
                                     self.longPress.enabled = YES;
                                     self.selectedIndexPath = nil;
                                     [self.maskView removeFromSuperview];
                                     self.maskView = nil;
                                     self.maskCenter = CGPointZero;
                                     cell.alpha = 1.0;
//                                     [self invalidateLayout];
                                     
                                     if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
                                         [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:indexPath];
                                     }
                                 }];
            }
        }   break;
        default:
            break;
        }
}

- (void)exchangeCells {
    NSIndexPath *previousIP = self.selectedIndexPath;
    NSIndexPath *currentIP = [self.collectionView indexPathForItemAtPoint:self.maskView.center];
    
    // 未交换, return
    if (!currentIP || [currentIP isEqual:previousIP]) return;
    
    // 不可交换, return
    if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemFromIndexPath:toIndexPath:)]
        && ![self.dataSource collectionView:self.collectionView canMoveItemFromIndexPath:previousIP toIndexPath:currentIP]) return;
    
    self.selectedIndexPath = currentIP;
    
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:willMoveItemFromIndexPath:toIndexPath:)]) {
        [self.delegate collectionView:self.collectionView
                               layout:self
            willMoveItemFromIndexPath:previousIP toIndexPath:currentIP];
    }
    
    [self invalidateLayout];

    [self.collectionView moveItemAtIndexPath:previousIP toIndexPath:currentIP];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:currentIP];
    cell.alpha = 0.0;

    if ([self.delegate respondsToSelector:@selector(collectionView:layout:didMoveItemFromIndexPath:toIndexPath:)]) {
            [self.delegate collectionView:self.collectionView
                                   layout:self
                 didMoveItemFromIndexPath:previousIP toIndexPath:currentIP];
    }
}


- (void)startTimerWithDirection:(LPScrollDirection)direction {
    if (self.displayLink) {
        LPScrollDirection pastDirection = self.displayLink.direction;
        if (pastDirection == direction) {
            return;
        } else {
            [self invalidateTimer];
        }
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
    self.displayLink.direction = direction;
    
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)autoScroll {
    LPScrollDirection direction = self.displayLink.direction;
    
    if (direction == LPScrollDirectionUnknown) return;
    
    CGSize contentSize = self.collectionView.contentSize;
    CGSize boundsSize = self.collectionView.bounds.size;
    CGPoint offset = self.collectionView.contentOffset;
    UIEdgeInsets inset = self.collectionView.contentInset;
    
    CGFloat increment = 0;
    
    if (direction == LPScrollDirectionLeft) {
        CGFloat percentage = 1.f - (CGRectGetMinX(self.maskView.frame) - offset.x) / self.autoScrollTrigger;
        increment = - 3.5f * percentage;
        if (increment <= - 3.5f) {
            increment = - 3.5f;
        }
    } else if (direction == LPScrollDirectionRight) {
        CGFloat percentage = (CGRectGetMaxX(self.maskView.frame) - offset.x - (boundsSize.width - self.autoScrollTrigger)) / self.autoScrollTrigger;
        increment = 3.5f * percentage;
        if (increment >= 3.5f) {
            increment = 3.5f;
        }
    }
    
    if (offset.x + increment <= - inset.left) { // 到达左端极限
        [UIView animateWithDuration:.07f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.collectionView.contentOffset = CGPointMake(- inset.left, offset.y);
                             
                             CGFloat diff = - inset.left - offset.x;
                             _maskCenter = CGPointMake(_maskCenter.x + diff, _maskCenter.y);
                             _maskView.center = CGPointMake(_maskCenter.x + _panTranslation.x, _maskCenter.y);
                         } completion:nil];
        [self invalidateTimer];
        return;
    } else if (offset.x + boundsSize.width + increment > contentSize.width - inset.right) { // 右端极限
        [UIView animateWithDuration:.07f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.collectionView.contentOffset = CGPointMake(contentSize.width - boundsSize.width - inset.right, offset.y);
                             
                             CGFloat diff = contentSize.width - boundsSize.width - inset.right - offset.x;
                             _maskCenter = CGPointMake(_maskCenter.x + diff, _maskCenter.y);
                             _maskView.center = CGPointMake(_maskCenter.x + _panTranslation.x, _maskCenter.y);
                         } completion:nil];
        [self invalidateTimer];
        return;
    }
    
    _maskCenter = CGPointMake(_maskCenter.x + increment, _maskCenter.y);
    self.maskView.center = CGPointMake(_maskCenter.x + _panTranslation.x, _maskCenter.y);
    self.collectionView.contentOffset = CGPointMake(offset.x + increment, offset.y);

    [self exchangeCells];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - gr delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.longPress]) {
        UIGestureRecognizerState state = self.collectionView.panGestureRecognizer.state;
        if (state != 0 && state != 5) {
            return NO;
        }
    } else if ([gestureRecognizer isEqual:self.pan]) {
        UIGestureRecognizerState state = self.longPress.state;
        if (state == 0 || state == 5) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:self.pan]) {
        return [otherGestureRecognizer isEqual:self.longPress] && (self.longPress.state != 0 && self.longPress.state != 5);
    } else if ([gestureRecognizer isEqual:self.longPress]) {
        return [otherGestureRecognizer isEqual:self.pan];
    } else if ([gestureRecognizer isEqual:self.collectionView.panGestureRecognizer]) {
        return !(self.longPress.state == 0 || self.longPress.state == 5);
    }
    return YES;
}

@end
