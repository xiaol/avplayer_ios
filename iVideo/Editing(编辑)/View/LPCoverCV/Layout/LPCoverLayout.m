//
//  LPCoverLayout.m
//  iVideo
//
//  Created by apple on 16/3/20.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPCoverLayout.h"

@implementation LPCoverLayout

- (CGSize)boundSize {
    return self.collectionView.bounds.size;
}

- (CGFloat)radius {
    return self.boundSize.width / 2.f;
}

- (CGPoint)contentOffset {
    return self.collectionView.contentOffset;
}

- (CGFloat)centerX {
    return [self contentOffset].x + [self radius];
}

- (void)prepareLayout {
    [super prepareLayout];
}

- (CGFloat)scaleFactor {
    return .2f;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributesArray = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect].copy];
    
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        if (attributes.representedElementCategory != UICollectionElementCategoryCell) continue;
        attributes.transform3D = CATransform3DIdentity;
        attributes.zIndex = 0;
        if (!CGRectIntersectsRect(attributes.frame, rect)) continue;
        if (CGRectContainsPoint(attributes.frame, CGPointMake([self centerX], attributes.center.y))) {
            attributes.zIndex = 1;
        }
        CGPoint boundCenter = CGPointMake(attributes.center.x - self.contentOffset.x, attributes.center.y);
        CGFloat distance = ABS([self radius] - boundCenter.x);
        CGFloat normalization = distance / [self radius];
        normalization = MIN(1, normalization);
        CGFloat zoom = 1.f + cos(normalization * M_PI_2) * self.scaleFactor;
//        CGFloat zoom = cos(normalization * M_PI / 4);
        attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.f);
        attributes.alpha = zoom / (1 + self.scaleFactor);
    }
    return attributesArray;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    CGFloat adjustmentX = CGFLOAT_MAX;
    CGRect boundRect = CGRectMake(proposedContentOffset.x, 0, [self boundSize].width, [self boundSize].height);
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:boundRect].copy;
    CGFloat centerPointX = proposedContentOffset.x + [self radius];
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        CGFloat distance = attributes.center.x - centerPointX;
        if (ABS(distance) < ABS(adjustmentX)) {
            adjustmentX = distance;
        }
    }
    return CGPointMake(proposedContentOffset.x + adjustmentX, proposedContentOffset.y);
}
@end
