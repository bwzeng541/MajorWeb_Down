//
//  LoggingConfig.h
//  Test
//
//  Created by Peng Gu on 12/16/14.
//  Copyright (c) 2014 Peng Gu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aspects_App.h"

#define Advert_Close_Click_Notifi @"Advert_Close_Click_Notifi"

#define GLLoggingPageImpression @"GLLoggingPageImpression"
#define GLLoggingTrackedEvents @"GLLoggingTrackedEvents"
#define GLLoggingEventName @"GLLoggingEventName"
#define GLLoggingEventSelectorName @"GLLoggingEventSelectorName"
#define GLLoggingEventHandlerBlock @"GLLoggingEventHandlerBlock"

#ifdef OldGDTSDK
@interface GDTStatsMgr :NSObject
@end

@interface GDTSettingMgr:NSObject
@end
#endif


@interface GLLogging : NSObject
+ (void)runTests:(id)inClass;
+ (GLLogging*)getInstance;
-(void)setupWithConfiguration:(NSDictionary *)configs;

@end
