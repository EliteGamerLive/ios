// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "FBSDKCoreKitTests-Swift.h"

@interface FBSDKBridgeAPIOpenBridgeRequestTests : XCTestCase

@property FBSDKBridgeAPI *api;
@property id partialMock;
@property (readonly) NSURL *sampleUrl;

@end

@implementation FBSDKBridgeAPIOpenBridgeRequestTests

- (void)setUp
{
  [super setUp];

  _api = [[FBSDKBridgeAPI alloc] initWithProcessInfo:[TestProcessInfo new]];
  _partialMock = OCMPartialMock(self.api);

  OCMStub(
    [_partialMock _bridgeAPIRequestCompletionBlockWithRequest:OCMArg.any
                                                   completion:OCMArg.any]
  );
  OCMStub(
    [_partialMock openURLWithSafariViewController:OCMArg.any
                                           sender:OCMArg.any
                               fromViewController:OCMArg.any
                                          handler:OCMArg.any]
  );
  OCMStub([_partialMock openURL:OCMArg.any sender:OCMArg.any handler:OCMArg.any]);
}

- (void)tearDown
{
  _api = nil;

  [_partialMock stopMocking];
  _partialMock = nil;

  [super tearDown];
}

// MARK: - Url Opening

- (void)testOpeningBridgeRequestWithRequestUrlUsingSafariVcWithFromVc
{
  ViewControllerSpy *spy = [ViewControllerSpy makeDefaultSpy];
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:self.sampleUrl];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:YES
              fromViewController:spy
                 completionBlock:self.uninvokedCompletionHandler];

  XCTAssertEqualObjects(self.api.pendingRequest, request);
  XCTAssertEqualObjects(self.api.pendingRequestCompletionBlock, self.uninvokedCompletionHandler);
  OCMVerify(
    [_partialMock _bridgeAPIRequestCompletionBlockWithRequest:request
                                                   completion:self.uninvokedCompletionHandler]
  );
  OCMVerify(
    [_partialMock openURLWithSafariViewController:self.sampleUrl
                                           sender:nil
                               fromViewController:spy
                                          handler:OCMArg.any]
  );
}

- (void)testOpeningBridgeRequestWithRequestUrlUsingSafariVcWithoutFromVc
{
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:self.sampleUrl];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:YES
              fromViewController:nil
                 completionBlock:self.uninvokedCompletionHandler];

  XCTAssertEqualObjects(self.api.pendingRequest, request);
  XCTAssertEqualObjects(self.api.pendingRequestCompletionBlock, self.uninvokedCompletionHandler);
  OCMVerify(
    [_partialMock _bridgeAPIRequestCompletionBlockWithRequest:request
                                                   completion:self.uninvokedCompletionHandler]
  );
  OCMVerify(
    [_partialMock openURLWithSafariViewController:self.sampleUrl
                                           sender:nil
                               fromViewController:nil
                                          handler:OCMArg.any]
  );
}

- (void)testOpeningBridgeRequestWithRequestUrlNotUsingSafariVcWithFromVc
{
  ViewControllerSpy *spy = [ViewControllerSpy makeDefaultSpy];
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:self.sampleUrl];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:NO
              fromViewController:spy
                 completionBlock:self.uninvokedCompletionHandler];

  XCTAssertEqualObjects(self.api.pendingRequest, request);
  XCTAssertEqualObjects(self.api.pendingRequestCompletionBlock, self.uninvokedCompletionHandler);
  OCMVerify(
    [_partialMock _bridgeAPIRequestCompletionBlockWithRequest:request
                                                   completion:self.uninvokedCompletionHandler]
  );
  OCMVerify([_partialMock openURL:self.sampleUrl sender:nil handler:OCMArg.any]);
}

- (void)testOpeningBridgeRequestWithRequestUrlNotUsingSafariVcWithoutFromVc
{
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:self.sampleUrl];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:NO
              fromViewController:nil
                 completionBlock:self.uninvokedCompletionHandler];

  XCTAssertEqualObjects(self.api.pendingRequest, request);
  XCTAssertEqualObjects(self.api.pendingRequestCompletionBlock, self.uninvokedCompletionHandler);
  OCMVerify(
    [_partialMock _bridgeAPIRequestCompletionBlockWithRequest:request
                                                   completion:self.uninvokedCompletionHandler]
  );
  OCMVerify([_partialMock openURL:self.sampleUrl sender:nil handler:OCMArg.any]);
}

- (void)testOpeningBridgeRequestWithoutRequestUrlUsingSafariVcWithFromVc
{
  ViewControllerSpy *spy = [ViewControllerSpy makeDefaultSpy];
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:nil];
  FBSDKBridgeAPIResponseBlock completionHandler = ^(FBSDKBridgeAPIResponse *_Nonnull response) {
    XCTAssertEqualObjects(
      response.request,
      request,
      "Should call the completion with a response that includes the original request"
    );
    XCTAssertTrue(
      [response.error isKindOfClass:FakeBridgeApiRequestError.class],
      "Should call the completion with an error if the request cannot provide a url"
    );
  };
  [self rejectApiOpeningBridgeRequest];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:YES
              fromViewController:spy
                 completionBlock:completionHandler];
  [self assertPendingPropertiesNotSet];
}

- (void)testOpeningBridgeRequestWithoutRequestUrlUsingSafariVcWithoutFromVc
{
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:nil];
  FBSDKBridgeAPIResponseBlock completionHandler = ^(FBSDKBridgeAPIResponse *_Nonnull response) {
    XCTAssertEqualObjects(
      response.request,
      request,
      "Should call the completion with a response that includes the original request"
    );
    XCTAssertTrue(
      [response.error isKindOfClass:FakeBridgeApiRequestError.class],
      "Should call the completion with an error if the request cannot provide a url"
    );
  };
  [self rejectApiOpeningBridgeRequest];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:YES
              fromViewController:nil
                 completionBlock:completionHandler];
  [self assertPendingPropertiesNotSet];
}

- (void)testOpeningBridgeRequestWithoutRequestUrlNotUsingSafariVcWithFromVc
{
  ViewControllerSpy *spy = [ViewControllerSpy makeDefaultSpy];
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:nil];
  FBSDKBridgeAPIResponseBlock completionHandler = ^(FBSDKBridgeAPIResponse *_Nonnull response) {
    XCTAssertEqualObjects(
      response.request,
      request,
      "Should call the completion with a response that includes the original request"
    );
    XCTAssertTrue(
      [response.error isKindOfClass:FakeBridgeApiRequestError.class],
      "Should call the completion with an error if the request cannot provide a url"
    );
  };
  [self rejectApiOpeningBridgeRequest];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:NO
              fromViewController:spy
                 completionBlock:completionHandler];
  [self assertPendingPropertiesNotSet];
}

- (void)testOpeningBridgeRequestWithoutRequestUrlNotUsingSafariVcWithoutFromVc
{
  TestBridgeApiRequest *request = [TestBridgeApiRequest requestWithURL:nil];
  FBSDKBridgeAPIResponseBlock completionHandler = ^(FBSDKBridgeAPIResponse *_Nonnull response) {
    XCTAssertEqualObjects(
      response.request,
      request,
      "Should call the completion with a response that includes the original request"
    );
    XCTAssertTrue(
      [response.error isKindOfClass:FakeBridgeApiRequestError.class],
      "Should call the completion with an error if the request cannot provide a url"
    );
  };
  [self rejectApiOpeningBridgeRequest];
  [self.api openBridgeAPIRequest:request
         useSafariViewController:NO
              fromViewController:nil
                 completionBlock:completionHandler];
  [self assertPendingPropertiesNotSet];
}

// MARK: - Helpers

- (void)rejectApiOpeningBridgeRequest
{
  OCMReject([_partialMock _bridgeAPIRequestCompletionBlockWithRequest:OCMArg.any completion:OCMArg.any]);
  OCMReject([_partialMock openURL:OCMArg.any sender:OCMArg.any handler:OCMArg.any]);
  OCMReject(
    [_partialMock openURLWithSafariViewController:OCMArg.any
                                           sender:OCMArg.any
                               fromViewController:OCMArg.any
                                          handler:OCMArg.any]
  );
}

- (void)assertPendingPropertiesNotSet
{
  XCTAssertNil(
    self.api.pendingRequest,
    "Should not set a pending request if the bridge request does not have a request url"
  );
  XCTAssertNil(
    self.api.pendingRequestCompletionBlock,
    "Should not set a pending request completion block if the bridge request does not have a request url"
  );
}

- (FBSDKBridgeAPIResponseBlock)uninvokedCompletionHandler
{
  return ^(FBSDKBridgeAPIResponse *_Nonnull response) {
    XCTFail("Should not invoke the completion handler");
  };
}

- (NSURL *)sampleUrl
{
  return [NSURL URLWithString:@"http://example.com"];
}

@end
