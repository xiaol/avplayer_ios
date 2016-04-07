//
//  LPLineTransitionDecoration.m
//  iVideo
//
//  Created by apple on 16/2/23.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPLineTransitionDecoration.h"
#import "LPLineLayoutAttributes.h"
#import "LPEditNotification.h"

@interface LPLineTransitionDecoration ()
@property (nonatomic, strong) LPLineLayoutAttributes *attributes;
@property (nonatomic, assign) LPVideoTransitionType transitionType;
@property (nonatomic, assign) NSUInteger item;
@end

@implementation LPLineTransitionDecoration

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _transitionView = [[UIImageView alloc] init];
        _transitionView.frame = CGRectInset(self.bounds, 2.0f, 2.0f);
        _transitionView.image = [UIImage imageNamed:@"推入"];
        [self addSubview:_transitionView];
        
        _transitionView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchTransitionType:)];
        [_transitionView addGestureRecognizer:gr];
        
        [noteCenter addObserver:self selector:@selector(deleteItemNote:) name:LPDeleteItemNotification object:nil];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    LPLineLayoutAttributes *attr = (LPLineLayoutAttributes *)layoutAttributes;
    self.attributes = attr;
    self.transitionView.image = [self imageWithTransitionType:attr.transitionType];
    self.transitionType = attr.transitionType;
    self.item = attr.indexPath.item;
}

- (UIImage *)imageWithTransitionType:(LPVideoTransitionType)type {
    switch (type) {
        case LPVideoTransitionTypeNone:
            return [UIImage imageNamed:@"推入"];
            break;
        case LPVideoTransitionTypeDissolve:
            return [UIImage imageNamed:@"溶解"];
        default:
            return nil;
            break;
    }
}

- (void)switchTransitionType:(UITapGestureRecognizer *)gr {
    gr.enabled = NO;
    [noteCenter postNotificationName:LPTransitionTypeChangedNotification object:self userInfo:@{LPTransitionTypeKey : @(self.transitionType), LPTransitionItemKey : @(self.item)}];
    self.transitionType = 1 - self.transitionType;
    self.transitionView.image = [self imageWithTransitionType:self.transitionType];
    gr.enabled = YES;
}

- (void)deleteItemNote:(NSNotification *)note {
    NSDictionary *info = note.userInfo;
    NSIndexPath *ip = info[LPDeleteIndexPathKey];
    BOOL noneTrans = [info[LPDeleteNoneTransitionKey] boolValue];
    if (!noneTrans) {
        LPVideoTransitionType type = [info[LPDeleteFirstTypeKey] unsignedIntegerValue];
        if (ip.item == 0 && self.attributes.indexPath.item == 0) {
            self.transitionType = type;
            self.transitionView.image = [self imageWithTransitionType:type];
        }
    } else {
        self.transitionType = LPVideoTransitionTypeNone;
        self.transitionView.image = [self imageWithTransitionType:LPVideoTransitionTypeNone];
    }
}

@end
