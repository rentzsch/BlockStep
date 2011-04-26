#import <Foundation/Foundation.h>
#import "blockStep.h"

// TODO: Add async tests.
// TODO: Add error-passing tests.

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // No steps.
    {
        STEP();
    }
    
    // One step: doesn't call next step.
    {
        __block BOOL step_1_1_called = NO;
        STEP(
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(!blockStep.previousStepResult);
                 
                 step_1_1_called = YES;
                 NSLog(@"1.1");
             }
        );
        assert(step_1_1_called);
    }
    
    // One step: calls next step.
    {
        __block BOOL step_2_1_called = NO;
        STEP(
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(!blockStep.previousStepResult);
                 
                 step_2_1_called = YES;
                 NSLog(@"2.1");
                 [blockStep callNextStepWithError:nil result:nil];
             }
             );
        assert(step_2_1_called);
    }
    
    // Two steps: first step doesn't call next step.
    {
        __block BOOL step_3_1_called = NO;
        __block BOOL step_3_2_called = NO;
        STEP(
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(!blockStep.previousStepResult);
                 
                 step_3_1_called = YES;
                 NSLog(@"3.1");
             },
             ^(BlockStep *blockStep){
                 assert(0); // shouldn't be called
             }
        );
        assert(step_3_1_called);
        assert(!step_3_2_called);
    }
    
    // Two steps: first step calls next step, last step doesn't call next step.
    {
        __block BOOL step_4_1_called = NO;
        __block BOOL step_4_2_called = NO;
        STEP(
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(!blockStep.previousStepResult);
                 
                 step_4_1_called = YES;
                 NSLog(@"4.1");
                 [blockStep callNextStepWithError:nil result:@"4.2"];
             },
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(blockStep.previousStepResult);
                 assert([blockStep.previousStepResult isEqualToString:@"4.2"]);
                 
                 step_4_2_called = YES;
                 NSLog(@"%@", blockStep.previousStepResult);
             }
        );
        assert(step_4_1_called);
        assert(step_4_2_called);
    }
    
    // Two steps: first step calls next step, last step calls next step.
    {
        __block BOOL step_5_1_called = NO;
        __block BOOL step_5_2_called = NO;
        STEP(
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(!blockStep.previousStepResult);
                 
                 step_5_1_called = YES;
                 NSLog(@"5.1");
                 [blockStep callNextStepWithError:nil result:@"5.2"];
             },
             ^(BlockStep *blockStep){
                 assert(blockStep);
                 assert(!blockStep.error);
                 assert(blockStep.previousStepResult);
                 assert([blockStep.previousStepResult isEqualToString:@"5.2"]);
                 
                 step_5_2_called = YES;
                 NSLog(@"%@", blockStep.previousStepResult);
                 [blockStep callNextStepWithError:nil result:@"5.3"];
             }
        );
        assert(step_5_1_called);
        assert(step_5_2_called);
    }
        
    [pool drain];
    printf("success\n");
    return 0;
}
