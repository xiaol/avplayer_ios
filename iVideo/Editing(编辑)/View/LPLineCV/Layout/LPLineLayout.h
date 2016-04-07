//
//  LPLineLayout.h
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPVideoTransition.h"

@protocol LPLineLayoutDataSource <UICollectionViewDataSource>

@optional

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
@end

@protocol LPLineLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required

- (LPVideoTransitionType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout transitionTypeAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didMoveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LPLineLayout : UICollectionViewFlowLayout

@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *pan;

@end
