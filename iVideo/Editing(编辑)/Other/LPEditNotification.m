//
//  LPEditNotification.m
//  iVideo
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 lvpin. All rights reserved.
//

#import "LPEditNotification.h"

NSString * const LPTransitionTypeChangedNotification = @"transition.type.changed";
NSString * const LPTransitionTypeKey = @"transition.type";
NSString * const LPTransitionItemKey = @"transition.item";

NSString * const LPDeleteItemNotification = @"delete.item.note";
NSString * const LPDeleteIndexPathKey = @"delete.ip";
NSString * const LPDeleteFirstTypeKey = @"deleted.first.type";
NSString * const LPDeleteNoneTransitionKey = @"delete.none.transition";

NSString * const LPTimelineVideosChangedNotification = @"timeline.videos.changed";
NSString * const LPTimelineVideosChangedTypeKey = @"timeline.videos.changed.key";