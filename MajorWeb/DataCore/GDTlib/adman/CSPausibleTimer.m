#import "CSPausibleTimer.h"
typedef NS_ENUM(NSInteger, SMTimerType) {
    SMTimerTypeUnknown = 0,
    SMTimerTypeScheduleInvocation,
    SMTimerTypeScheduleSelector,
    SMTimerTypeTimerInvocation,
    SMTimerTypeTimerSelector
};

@interface CSPausibleTimer ()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) id info;
@property (nonatomic) BOOL repeats;
@property (nonatomic) NSDate *timerStateDate;
@property (nonatomic) SMTimerType timerType;
@property (nonatomic) BOOL isPaused;

/**
 *  This stores the interval when a timer is paused, is used to calculate resume
 */
@property (nonatomic) NSTimeInterval pausedTimeInterval;

@end

@implementation CSPausibleTimer

#pragma mark - Class methods
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    invocation:(NSInvocation *)invocation
                                       repeats:(BOOL)repeats {
    return [[self alloc] initWithScheduledTimerWithTimeInterval:interval
                                                     invocation:invocation
                                                        repeats:repeats];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)target
                                      selector:(SEL)selector
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)repeats {
    return [[self alloc] initWithScheduledTimerWithInterval:interval
                                                     target:target
                                                   selector:selector
                                                   userInfo:userInfo
                                                    repeats:repeats];
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                           invocation:(NSInvocation *)invocation
                              repeats:(BOOL)repeats {
    return [[self alloc] initWithTimerWithTimeInterval:interval
                                            invocation:invocation
                                               repeats:repeats];
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                               target:(id)target
                             selector:(SEL)selector
                             userInfo:(id)userInfo
                              repeats:(BOOL)repeats {
    return [[self alloc] initWithTimerWithTimeInterval:interval
                                                target:target
                                              selector:selector
                                              userInfo:userInfo
                                               repeats:repeats];
}

#pragma mark - Initializers
- (instancetype)initWithScheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                            invocation:(NSInvocation *)invocation
                                               repeats:(BOOL)repeats {
    self = [super init];
    
    if (self) {
        [self resetInterval];
        [self configureNotifications];
        [self testForMissingInvocation:invocation];
        self.timerType      = SMTimerTypeScheduleInvocation;
        self.interval       = interval;
        self.invocation     = invocation;
        self.repeats        = repeats;
        self.timerStateDate = [NSDate new];
        [self scheduledTimerWithTimeInterval:interval
                                  invocation:invocation
                                     repeats:repeats];
    }
    
    return self;
}

- (instancetype)initWithScheduledTimerWithInterval:(NSTimeInterval)interval
                                            target:(id)target
                                          selector:(SEL)selector
                                          userInfo:(id)userInfo
                                           repeats:(BOOL)repeats {
    self = [super init];
    
    if (self) {
        [self resetInterval];
        [self configureNotifications];
        [self testForMissingTarget:target selector:selector];
        self.interval       = interval;
        self.target         = target;
        self.selector       = selector;
        self.info           = userInfo;
        self.repeats        = repeats;
        self.timerStateDate = [NSDate new];
        self.timerType      = SMTimerTypeScheduleSelector;
        [self scheduledTimerWithTimeInterval:interval
                                      target:target
                                    selector:selector
                                    userInfo:userInfo
                                     repeats:repeats];
    }
    
    return self;
}

- (instancetype)initWithTimerWithTimeInterval:(NSTimeInterval)interval
                                   invocation:(NSInvocation *)invocation
                                      repeats:(BOOL)repeats {
    self = [super init];
    
    if (self) {
        [self resetInterval];
        [self configureNotifications];
        [self testForMissingInvocation:invocation];
        self.timerType      = SMTimerTypeTimerInvocation;
        self.interval       = interval;
        self.invocation     = invocation;
        self.repeats        = repeats;
        self.timerStateDate = [NSDate new];
        [self timerWithTimeInterval:interval
                         invocation:invocation
                            repeats:repeats];
    }
    
    return self;
}

- (instancetype)initWithTimerWithTimeInterval:(NSTimeInterval)interval
                                       target:(id)target
                                     selector:(SEL)selector
                                     userInfo:(id)userInfo
                                      repeats:(BOOL)repeats {
    self = [super init];
    
    if (self) {
        [self resetInterval];
        [self configureNotifications];
        [self testForMissingTarget:target selector:selector];
        self.timerType      = SMTimerTypeTimerSelector;
        self.interval       = interval;
        self.target         = target;
        self.selector       = selector;
        self.info           = userInfo;
        self.repeats        = repeats;
        self.timerStateDate = [NSDate new];
        [self timerWithTimeInterval:interval
                             target:target
                           selector:selector
                           userInfo:userInfo
                            repeats:repeats];
    }
    
    return self;
}

#pragma mark - Utility methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetInterval {
    self.pausedTimeInterval = 0;
}

#pragma mark - Notifications
- (void)configureNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseTimer)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeTimer)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:self];
}

- (void)pauseOnBackground:(NSNotification *)notification {
    [self pauseTimer];
}

- (void)resumeOnForeground:(NSNotification *)notificaton {
    if (self.isPaused) {
        [self resumeTimer];
    }
}

#pragma mark - Getters
- (BOOL)valid {
    return self.timer.isValid;
}

- (NSDate *)fireDate {
    if (self.timeInterval) {
        return self.timer.fireDate;
    }
    
    return nil;
}

- (NSTimeInterval)timeInterval {
    if (self.timer) {
        return self.timer.timeInterval;
    }
    
    return 0.0;
}

- (id)userInfo {
    return self.info;
}

- (NSTimeInterval)tolerance {
    if (self.timer) {
        return self.timer.tolerance;
    }
    
    return 0.0;
}

#pragma mark - Setters

- (void)setFireDate:(NSDate *)fireDate {
    if (self.timer.isValid) {
        [self.timer setFireDate:fireDate];
    }
}

- (void)setTolerance:(NSTimeInterval)tolerance {
    if (self.timer) {
        [self.timer setTolerance:tolerance];
    }
}

#pragma mark - Timer setup
- (void)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                            invocation:(NSInvocation *)invocation
                               repeats:(BOOL)repeats {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              invocation:invocation
                                                 repeats:repeats];
}

- (void)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                target:(id)target
                              selector:(SEL)selector
                              userInfo:(id)userInfo
                               repeats:(BOOL)repeats {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:target
                                                selector:selector
                                                userInfo:userInfo
                                                 repeats:repeats];
}

- (void)timerWithTimeInterval:(NSTimeInterval)interval
                   invocation:(NSInvocation *)invocation
                      repeats:(BOOL)repeats {
    self.timer = [NSTimer timerWithTimeInterval:interval
                                     invocation:invocation
                                        repeats:repeats];
}

- (void)timerWithTimeInterval:(NSTimeInterval)interval
                       target:(id)target
                     selector:(SEL)selector
                     userInfo:(id)userInfo
                      repeats:(BOOL)repeats {
    self.timer = [NSTimer timerWithTimeInterval:interval
                                         target:target
                                       selector:selector
                                       userInfo:userInfo
                                        repeats:repeats];
}

- (void)testForMissingInvocation:(NSInvocation *)invocation {
    if (!invocation) {
        NSAssert(NO, @"An invocation must be provided");
    }
}

- (void)testForMissingTarget:(id)target selector:(SEL)selector {
    if (!target) {
        NSAssert(NO, @"A target must be provided");
    }
    if (!selector) {
        NSAssert(NO, @"A selector must be provided");
    }
}

- (void)fire {
    if (self.timer) {
        [self.timer fire];
    }
}

- (void)invalidate {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Pause & Resume

- (void)pauseTimer {
    // Determine how much time has passed since the timer stated (which will be negative) and then add it to the original time interval
    self.pausedTimeInterval = self.interval + [self.timerStateDate timeIntervalSinceNow];
    [self invalidate];
}

- (void)reSetPausedTimeInterval:(float)time{
    self.pausedTimeInterval = time;
}

- (void)resumeTimer {
    if (self.isPaused) {
        switch (self.timerType) {
            case SMTimerTypeScheduleInvocation: {
                [self scheduledTimerWithTimeInterval:self.pausedTimeInterval
                                          invocation:self.invocation
                                             repeats:self.repeats];
                break;
            }
                
            case SMTimerTypeScheduleSelector: {
                [self scheduledTimerWithTimeInterval:self.pausedTimeInterval
                                              target:self.target
                                            selector:self.selector
                                            userInfo:self.userInfo
                                             repeats:self.repeats];
                break;
            }
                
            case SMTimerTypeTimerInvocation: {
                [self timerWithTimeInterval:self.pausedTimeInterval
                                 invocation:self.invocation
                                    repeats:self.repeats];
                break;
            }
                
            case SMTimerTypeTimerSelector: {
                [self timerWithTimeInterval:self.pausedTimeInterval
                                     target:self.target
                                   selector:self.selector
                                   userInfo:self.userInfo
                                    repeats:self.repeats];
                break;
            }
                
            default:
                break;
        }
        [self resetInterval];
    }
}

- (BOOL)isPaused {
    return self.pausedTimeInterval != 0;
}

@end
