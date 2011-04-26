// blockStep 0.1: https://github.com/rentzsch/blockStep
//   Copyright (c) 2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit-license.php

#import <Foundation/Foundation.h>

@class BlockStep;

typedef void (^BlockStepBlock)(BlockStep *blockStep);

@interface BlockStep : NSObject {
#ifndef NOIVARS
  @protected
    NSMutableArray *steps;
    NSUInteger nextStepIndex;
    NSError *error;
    id previousStepResult;
#endif
}
@property(retain) NSError *error;
@property(retain) id previousStepResult;

- (id)initAndExecuteSteps:(BlockStepBlock[])steps_ count:(NSUInteger)stepCount_;

- (void)callNextStepWithError:(NSError*)error_ result:(id)result_;
@end

#ifndef sizeofA
    #define sizeofA(array) (sizeof(array)/sizeof(array[0]))
#endif

#define STEP(...)                                                                       \
    {                                                                                   \
        BlockStepBlock steps[] = {__VA_ARGS__};                                         \
        NSUInteger stepCount = sizeofA(steps);                                          \
        [[[BlockStep alloc] initAndExecuteSteps:steps                                   \
                                          count:stepCount] callNextStepWithError:nil    \
                                                                          result:nil];  \
    }
