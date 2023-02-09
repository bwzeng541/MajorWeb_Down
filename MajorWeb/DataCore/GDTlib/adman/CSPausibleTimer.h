//
//  CSPausibleTimer.h
//  uFilmer
//
//  Created by Chris Shaheen on 3/28/13.
//  Copyright (c) 2013 Codeslaw. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface CSPausibleTimer : NSObject



- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    invocation:(NSInvocation *)invocation
                                       repeats:(BOOL)repeats;


+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)target
                                      selector:(SEL)selector
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)repeats;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                           invocation:(NSInvocation *)invocation
                              repeats:(BOOL)repeats;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                               target:(id)target
                             selector:(SEL)selector
                             userInfo:(id)userInfo
                              repeats:(BOOL)repeats;

- (void)fire;
- (void)invalidate;

/**
 *  Pauses the timer
 */
- (void)pauseTimer;

/**
 *  Resumes a timer if it is currently paused
 */
- (void)resumeTimer;

/**
 *  Provide the current state of the timer
 *
 *  @return Is the timer paused
 */
- (BOOL)isPaused;

- (void)reSetPausedTimeInterval:(float)time;
@property (nonatomic, readonly) BOOL valid;
@property (nonatomic) NSDate *fireDate;
@property (nonatomic, readonly) NSTimeInterval timeInterval;
@property (nonatomic, readonly) id userInfo;
@property (nonatomic) NSTimeInterval tolerance;

@property (nonatomic, readonly) BOOL isPaused;



@end

