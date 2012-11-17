// BlockStep.m semver:1.0.0
//   Copyright (c) 2011-2012 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/BlockStep

#import "BlockStep.h"
#include <unistd.h>

@implementation BlockStep
@synthesize steps;
@synthesize nextStepIndex;
@synthesize error;
@synthesize previousStepResult;

+ (id)run:(BlockStepBlock)firstStep, ... {
    NSParameterAssert(firstStep);
    
    BlockStep *result = [[BlockStep alloc] init];
    firstStep = [firstStep copy];
    [result.steps addObject:firstStep];
    [firstStep release];
    
    BlockStepBlock stepArg;
    va_list args;
    va_start(args, firstStep);
    do {
        stepArg = va_arg(args, BlockStepBlock);
        if (stepArg) {
            stepArg = [stepArg copy];
            [result.steps addObject:stepArg];
            [stepArg release];
        }
    } while (stepArg);
    va_end(args);
    
    [result callNextStepWithError:nil result:nil];
    
    return result;
}

- (id)init {
    self = [super init];
    if (self) {
        steps = [[NSMutableArray alloc] init];
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
    if (self.nextStepIndex == [self.steps count]) {
        [self complete];
    } else {
        BlockStepBlock step = [self.steps objectAtIndex:self.nextStepIndex++];
        @try {
            [self retain];
            
            self.error = error_;
            self.previousStepResult = result_;
            step(self);
        } @finally {
            [self release];
        }
    }
}

- (void)complete {
    [self release];
}

@end
