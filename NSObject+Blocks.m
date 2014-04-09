//
//  NSObject+Blocks.m
//  Level
//
//  Created by Bobby Schultz on 12/1/11.
//

#import "NSObject+Blocks.h"
#import <objc/runtime.h>

static char genericKVOBlockKey;
// Generic Block Delegate
@interface KVOBlock:NSObject
@property (nonatomic, copy) void(^callbackIdBlock)(id);
@property (nonatomic, assign) NSObject * owner;
@property (nonatomic, assign) NSString * keyPath;
- (void) setBlock:(id)callback keyPath:(NSString*)key owner:(NSObject*)blockOwner;
@end

@implementation KVOBlock
@synthesize owner, callbackIdBlock, keyPath;
- (void) setBlock:(id)callback keyPath:(NSString*)key owner:(NSObject*)blockOwner
{
    if (!callback || !blockOwner) return;
    
    [self setCallbackIdBlock:callback];
    [self setOwner:blockOwner];
    [self setKeyPath:key];
    
    // Hold onto KVO Block listener only as long at the listener is alive (currently only allow for 1 listener)
    objc_setAssociatedObject(blockOwner, genericKVOBlockKey, self, OBJC_ASSOCIATION_RETAIN);
    
    [owner addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)key ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id updatedProperty = [object valueForKey:key];
    if (self.callbackIdBlock) callbackIdBlock(updatedProperty);
}
- (void) dealloc
{
    @try { [owner removeObserver:self forKeyPath:keyPath]; } @catch (NSException * __unused exception) {}
    
    keyPath = nil;
    callbackIdBlock = nil;
    owner = nil; 
}
@end



@implementation NSObject (KVO)
- (void) bindKeyPath:(NSString*)key change:(void(^)(id newObject))changed
{
    KVOBlock *delegatee;
    @autoreleasepool {
        delegatee = [KVOBlock new];
    }
    [delegatee setBlock:changed keyPath:key owner:self];
}
@end

@implementation NSArray (PBUtils)

- (NSArray*) filterBy:(NSString*)criteria, ...
{
    va_list variadicArguments;
    va_start(variadicArguments, criteria);
    NSPredicate* predicate = [NSPredicate predicateWithFormat:criteria arguments:variadicArguments];
    va_end(variadicArguments);
    
    NSArray * filtered = nil;
    @try {
        filtered = [self filteredArrayUsingPredicate:predicate];
    }
    @catch (NSException *exception) {
        
    }
    return filtered.mutableCopy;
}

- (id) firstObjectIsClass:(Class)cls
{
    __block id found = nil;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:cls])
        {
            found = obj;
            stop = YES;
        }
    }];
            
    return found;
}

@end
