//
//  MRGLocaleTests.m
//  MRGLocaleTests
//
//  Created by Vincent Roy Chevalier on 2014-03-06.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MRGLocale.h"
#import "MRGRemoteStringResourceMock.h"

static NSString *const RemoteStringFileUserDefaultKey = @"MRGLocale:RemoteStringFileUserDefaultKey";

@interface MRGLocaleTests : XCTestCase

@property (nonatomic) MRGLocale *mrgLocale;

@end

@implementation MRGLocaleTests

- (void)setUp
{
    [super setUp];
    self.mrgLocale = [[MRGLocale alloc] init];
}

- (void)tearDown
{
    self.mrgLocale = nil;
    [super tearDown];
}

- (void)testReadMessageFromRemoteResource {
    MRGRemoteStringResourceMock *mockResource = [[MRGRemoteStringResourceMock alloc] init];
    [self.mrgLocale setRemoteStringResourceList:@[mockResource]];

    XCTestExpectation *receiveMockResource = [self expectationWithDescription:@"receiveMockResource"];

    [self.mrgLocale refreshRemoteStringResourcesWithCompletion:^(NSError *error) {
        [receiveMockResource fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError *error) {
        NSString* message = [self.mrgLocale localizedStringForKey:@"message"];
        XCTAssert([message isEqualToString:@"It's working"]);
    }];
}

@end
