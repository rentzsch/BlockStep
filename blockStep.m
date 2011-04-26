// blockStep 0.1: https://github.com/rentzsch/blockStep
//   Copyright (c) 2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit-license.php

#import "blockStep.h"

@interface BlockStep ()
@property(retain) NSMutableArray *steps;
@property(assign) NSUInteger nextStepIndex;
@end

@implementation BlockStep
@synthesize steps;
@synthesize nextStepIndex;
@synthesize error;
@synthesize previousStepResult;

- (id)initAndExecuteSteps:(BlockStepBlock[])steps_ count:(NSUInteger)stepCount_ {
    NSParameterAssert(steps_);
    
    self = [super init];
    if (self) {
        steps = [[NSMutableArray alloc] init];
        for (NSUInteger stepIndex = 0; stepIndex < stepCount_; stepIndex++) {
            BlockStepBlock step = [steps_[stepIndex] copy];
            [steps addObject:step];
            [step release];
        }
    }
    return self;
}

- (void)dealloc {
    [steps release];
    [error release];
    [previousStepResult release];
    [super dealloc];
}

- (void)callNextStepWithError:(NSError*)error_ result:(id)result_ {
    [self retain];
    
    if (self.nextStepIndex == [self.steps count]) {
        self.nextStepIndex++; // Here because we use it as an indicator callNextStepWithError:result: has been called.
        [self release];
    } else {
        NSUInteger oldNextStepIndex = self.nextStepIndex;
        BlockStepBlock step = [self.steps objectAtIndex:self.nextStepIndex++];
        
        @try {
            self.error = error_;
            self.previousStepResult = result_;
            step(self);
        } @finally {
            if (self.nextStepIndex == oldNextStepIndex + 1) {
                // Step didn't callNextStep -- tear things down.
                [self release];
            }
        }
    }
    
    [self release];
}

@end
