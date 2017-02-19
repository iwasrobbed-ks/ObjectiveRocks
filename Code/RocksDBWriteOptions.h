//
//  RocksDBWriteOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Options that control write operations. */
@interface RocksDBWriteOptions : NSObject <NSCopying> 

/** @brief If true, the write will be flushed from the operating system
 buffer cache before the write is considered complete.
 Default: false
 */
@property (nonatomic, assign) BOOL syncWrites;

/** @brief If true, writes will not first go to the write ahead log, and 
 the write may got lost after a crash.
*/
@property (nonatomic, assign) BOOL disableWriteAheadLog;

/** @brief If true and if user is trying to write to column families that don't
 exist then the write will be ignored.
 Default: false
*/
@property (nonatomic, assign) BOOL ignoreMissingColumnFamilies;

@end

NS_ASSUME_NONNULL_END
