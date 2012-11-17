// BlockStep.h semver:1.0.0
//   Copyright (c) 2011-2012 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/mit
//   https://github.com/rentzsch/BlockStep

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
@property(retain) NSMutableArray *steps;
@property(assign) NSUInteger nextStepIndex;
@property(retain) NSError *error;
@property(retain) id previousStepResult;

+ (id)run:(BlockStepBlock)firstStep, ... NS_REQUIRES_NIL_TERMINATION;

- (void)callNextStepWithError:(NSError*)error_ result:(id)result_;
- (void)complete;
@end
