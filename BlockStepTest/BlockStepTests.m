#import "BlockStepTests.h"
#import "blockStep.h"

@implementation BlockStepTests

- (void)testOneStep_doesntCallNextStep {
    __block BOOL step_1_called = NO;
    [BlockStep run:
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNil(blockStep.previousStepResult, nil);
         
         step_1_called = YES;
         [blockStep complete];
     },
     nil
     ];
    GHAssertTrue(step_1_called, nil);
}

- (void)testOneStep_callsNextStep {
    __block BOOL step_1_called = NO;
    [BlockStep run:
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNil(blockStep.previousStepResult, nil);
         
         step_1_called = YES;
         [blockStep callNextStepWithError:nil result:nil];
     },
     nil
     ];
    GHAssertTrue(step_1_called, nil);
}

- (void)testTwoSteps_firstStepDoesntCallNextStep {
    __block BOOL step_1_called = NO;
    __block BOOL step_2_called = NO;
    [BlockStep run:
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNil(blockStep.previousStepResult, nil);
         
         step_1_called = YES;
         [blockStep complete];
     },
     ^(BlockStep *blockStep){
         assert(0); // shouldn't be called
     },
     nil
     ];
    GHAssertTrue(step_1_called, nil);
    GHAssertFalse(step_2_called, nil);
}

- (void)testTwoSteps_firstStepCallsNextStep_lastStepDoesntCallNextStep {
    __block BOOL step_1_called = NO;
    __block BOOL step_2_called = NO;
    [BlockStep run:
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNil(blockStep.previousStepResult, nil);
         
         step_1_called = YES;
         [blockStep callNextStepWithError:nil result:@"uno"];
     },
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNotNil(blockStep.previousStepResult, nil);
         GHAssertEqualStrings(blockStep.previousStepResult, @"uno", nil);
         
         step_2_called = YES;
     },
     nil
     ];
    GHAssertTrue(step_1_called, nil);
    GHAssertTrue(step_2_called, nil);
}

- (void)testTwoSteps_firstStepCallsNextStep_lastStepCallsNextStep {
    __block BOOL step_1_called = NO;
    __block BOOL step_2_called = NO;
    [BlockStep run:
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNil(blockStep.previousStepResult, nil);
         
         step_1_called = YES;
         [blockStep callNextStepWithError:nil result:@"dos"];
     },
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNotNil(blockStep.previousStepResult, nil);
         GHAssertEqualStrings(blockStep.previousStepResult, @"dos", nil);
         
         step_2_called = YES;
         [blockStep callNextStepWithError:nil result:@"tres"];
     },
     nil
     ];
    GHAssertTrue(step_1_called, nil);
    GHAssertTrue(step_2_called, nil);
}

- (void)testTwoAsyncSteps_firstStepCallsNextStep_lastStepCallsNextStep {
    [self prepare];
    
    __block typeof(self) blockSelf = self;
    
    __block BOOL step_1_called = NO;
    __block BOOL step_2_called = NO;
    [BlockStep run:
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNil(blockStep.previousStepResult, nil);
         
         step_1_called = YES;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/100ULL), dispatch_get_main_queue(), ^{
             [blockStep callNextStepWithError:nil result:@"dos"];
         });
     },
     ^(BlockStep *blockStep){
         GHAssertNotNil(blockStep, nil);
         GHAssertNil(blockStep.error, nil);
         GHAssertNotNil(blockStep.previousStepResult, nil);
         GHAssertEqualStrings(blockStep.previousStepResult, @"dos", nil);
         
         step_2_called = YES;
         [blockStep callNextStepWithError:nil result:@"tres"];
         [blockSelf notify:kGHUnitWaitStatusSuccess forSelector:@selector(testTwoAsyncSteps_firstStepCallsNextStep_lastStepCallsNextStep)];
     },
     nil
     ];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5];
    GHAssertTrue(step_1_called, nil);
    GHAssertTrue(step_2_called, nil);
}

@end
