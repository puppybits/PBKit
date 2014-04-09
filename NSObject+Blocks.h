//
//  NSObject+Blocks.h
//  Level
//
//  Created by Bobby Schultz on 12/1/11.
//

#import <Foundation/Foundation.h>
#pragma mark - data binding

@interface NSObject (KVO)
- (void) bindKeyPath:(NSString*)key change:(void(^)(id newObject))changed;
@end

#pragma mark - filter, sort collections
@interface NSArray (PBUtils)
- (NSArray*) filterBy:(NSString*)criteria, ...;
- (id) firstObjectIsClass:(Class)cls;
@end
