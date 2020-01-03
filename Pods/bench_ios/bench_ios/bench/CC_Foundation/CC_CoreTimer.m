//
//  CC_TManager.m
//  bench_ios
//
//  Created by gwh on 2018/12/10.
//  Copyright © 2018 apple. All rights reserved.
//

#import "CC_CoreTimer.h"
#import "CC_CoreThread.h"

#import "CC_Date.h"

@interface CC_CoreTimer(){
    NSMutableArray *registerNameMutArr;
    NSMutableArray *registerBlockMutArr;
    NSMutableArray *registerTimeMutArr;
    NSMutableDictionary *registerMutDic;
    
    NSDate *lastDate;
    int pause;
    float minF;
    
    NSString *currentUniqueTimeStamp;
    int currentUniqueTimeStampCount;
}

@property (nonatomic, retain) NSTimer *timer;

@end

@implementation CC_CoreTimer

+ (instancetype)shared {
    return [CC_Base.shared cc_registerSharedInstance:self block:^{
        [CC_CoreThread.shared cc_gotoThread:^{
            [CC_CoreTimer.shared start];
        }];
    }];
}

- (void)start {
    minF = 0.1;
    registerMutDic = [[NSMutableDictionary alloc]init];
    registerBlockMutArr = [[NSMutableArray alloc]init];
    registerNameMutArr = [[NSMutableArray alloc]init];
    registerTimeMutArr = [[NSMutableArray alloc]init];
    [self initTimer];
}

- (void)initTimer {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:minF target:self selector:@selector(runTimer) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)runTimer {
    if (registerTimeMutArr.count == 0) {
        return;
    }
    if (pause) {
        return;
    }
    NSTimeInterval add = 0;
    NSDate *d2 = [NSDate date];
    if (!lastDate) {
        add = minF;
    }else{
        add = [CC_Date cc_compareDate:d2 cut:lastDate];
    }
    lastDate = d2;
    
    for (int i = 0; i < registerTimeMutArr.count; i++) {
        float getT = [registerTimeMutArr[i] floatValue];
        NSString *name = registerNameMutArr[i];
        float need = [registerMutDic[name] floatValue];
        if (getT + add < need) {
            [registerTimeMutArr replaceObjectAtIndex:i withObject:@(getT + add)];
        }else{
            float plus = getT + add - need;
            
            [registerTimeMutArr replaceObjectAtIndex:i withObject:@(plus)];
            
            __block CC_CoreTimer *weakSelf = self;
            [CC_CoreThread.shared cc_gotoMain:^{
                void (^myBlock)(void) = weakSelf->registerBlockMutArr[i];
                myBlock();
            }];
        }
    }
}

- (void)cc_registerT:(NSString *)name interval:(float)interval block:(void (^)(void))block{
    if (!name) {
        CCLOGAssert(@"no name");
    }
    if (!interval) {
        CCLOGAssert(@"interval invalid");
    }
    if (!registerMutDic[name]) {
        //防重复
        pause = 1;
        [registerMutDic setObject:@(interval) forKey:name];
        [registerNameMutArr addObject:name];
        [registerBlockMutArr addObject:block];
        [registerTimeMutArr addObject:@(0)];
        pause = 0;
        
        [self initTimer];
    }
}

- (void)cc_unRegisterT:(NSString *)name{
    if (!name) {
        CCLOGAssert(@"no name");
    }
    pause = 1;
    //写保护
    [registerMutDic removeObjectForKey:name];
    int index = -1;
    for (int i = 0; i < registerNameMutArr.count; i++) {
        if ([registerNameMutArr[i]isEqualToString:name]) {
            index = i;
        }
    }
    if (index >= 0) {
        [registerNameMutArr removeObjectAtIndex:index];
        [registerBlockMutArr removeObjectAtIndex:index];
        [registerTimeMutArr removeObjectAtIndex:index];
    }
    pause = 0;
    if (registerNameMutArr.count == 0) {
        [_timer invalidate];
        _timer = nil;
    }
}


- (NSString *)cc_uniqueNowTimestamp{
    NSString *timestamp = [self cc_nowTimeTimestamp];
    if (currentUniqueTimeStamp) {
        if ([currentUniqueTimeStamp isEqualToString:timestamp]) {
            //如果相等 即是出现并发
            currentUniqueTimeStampCount++;

            return [NSString stringWithFormat:@"%@_%d",currentUniqueTimeStamp,currentUniqueTimeStampCount];
        }else{
            
            currentUniqueTimeStampCount = 0;
            currentUniqueTimeStamp = timestamp;
            return timestamp;
        }
    }
    currentUniqueTimeStampCount = 0;
    currentUniqueTimeStamp = timestamp;
    return timestamp;
}

- (NSString *)cc_nowTimeTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

@end
