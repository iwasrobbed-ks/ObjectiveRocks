//
//  RocksDBWriteBatchTests.m
//  BCRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]

@interface RocksDBWriteBatchTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBWriteBatchTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] resourcePath];
	_path = [_path stringByAppendingPathComponent:@"BCRocks"];
}

- (void)tearDown
{
	[_rocks close];

	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:_path error:&error];
	if (error) {
		NSLog(@"Error test teardown: %@", [error debugDescription]);
	}
	[super tearDown];
}

- (void)testWriteBatch_Perform
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch setData:Data(@"Value 1") forKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Perform_DeleteOps
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Perform_ClearOps
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
		[batch clear];
		[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], Data(@"Value 4"));
}

- (void)testWriteBatch_Apply
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBWriteBatch *batch = [RocksDBWriteBatch new];

	[batch setData:Data(@"Value 1") forKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Apply_DeleteOps
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [RocksDBWriteBatch new];

	[batch deleteDataForKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Apply_ClearOps
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [RocksDBWriteBatch new];

	[batch deleteDataForKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	[batch clear];
	[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], Data(@"Value 4"));
}

- (void)testWriteBatch_Count
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [RocksDBWriteBatch new];

	[batch deleteDataForKey:Data(@"Key 1")];

	XCTAssertEqual(batch.count, 1);

	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	XCTAssertEqual(batch.count, 3);

	[batch clear];

	XCTAssertEqual(batch.count, 0);

	[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];
	[batch setData:Data(@"Value 5") forKey:Data(@"Key 4")];

	XCTAssertEqual(batch.count, 2);

	[batch deleteDataForKey:Data(@"Key 4")];

	XCTAssertEqual(batch.count, 3);
}

@end
