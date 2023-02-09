
#if DoNotKMPLayerCanShareVideo
#else
#import "AppNodeTask.h"
@interface AppNodeTask()
@property(copy)NSString* speed;
@property(strong)NSDate *fiveDateTime;
@property(assign)float totalRead;
@property(strong)NSDate *date;

@property(assign)float valu1;

@property(assign)float fiveReadData;
@property(retain)NSTimer *checkVideoTimer;
@end
@implementation AppNodeTask
-(id)init{
    self = [super init];
    self.valu1 = -1;
    return self;
}

-(void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)jisuan:(float)count{
    self.fiveReadData += count;
    self.totalRead += count;
    NSDate *currentDate = [NSDate date];
    if ([currentDate timeIntervalSinceDate:self.date] >= 1) {
        //时间差
        double time = [currentDate timeIntervalSinceDate:self.date];
        //把速度转成KB或M
        self.speed = [self formatByteCount:self.totalRead/time];
    
        self.totalRead = 0.0;
        self.date = currentDate;
        if (self.uuid) {
            [[NSNotificationCenter defaultCenter]postNotificationName:[NSString stringWithFormat:@"SpeedTaskNotifi_%@",self.uuid] object:self.speed];
        }
    }
}

-(void)startCheckToSlow{
    [self stopCheckToSlow];
    self.fiveDateTime = [NSDate date];
    self.checkVideoTimer  = [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(isStoSlow:) userInfo:nil repeats:YES];
}

-(void)isStoSlow:(NSTimer*)timer{
    NSDate *currentDate = [NSDate date];
    double time = [currentDate timeIntervalSinceDate:self.fiveDateTime];
    if (time>0) {
        float kbspeed = self.fiveReadData/(1024.0*time);
        if (kbspeed<2) {//默认失败速度太小?
            [self stopCheckToSlow];
            if ([self.delegate respondsToSelector:@selector(speedSlow:)] ) {
                [self.delegate speedSlow:self.uuid];
            }
        }
        self.fiveReadData = 0;
        self.fiveDateTime = currentDate;
    }
}

-(void)stopCheckToSlow{
    [self.checkVideoTimer invalidate];
    self.checkVideoTimer = nil;
}

-(void)jisuan2:(NSProgress*)progress{
    if (self.valu1>=0) {
        [self jisuan: fabs( progress.completedUnitCount - self.valu1)];
    }
    else{
        self.date = [NSDate date];
    }
    self.valu1 = progress.completedUnitCount;
}

    
- (NSString*)formatByteCount:(long long)size
{
        return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
@end
#endif
