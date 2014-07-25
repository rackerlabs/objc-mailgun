//
//  MailGun.h
//  MailGunExample
//
//  Created by Jay Baird on 1/11/13.
//  Copyright (c) 2013 Rackspace Hosting. All rights reserved.
//

#import "Mailgun.h"

NSString * const kMailgunURL = @"https://api.mailgun.net/v2";

@interface Mailgun()

@property (nonatomic) AFJSONRequestSerializer *serializer;
@property (nonatomic) NSOperationQueue *operationQueue;

@end

@implementation Mailgun

+ (instancetype)client {
    static dispatch_once_t onceToken;
    static Mailgun *client;
    dispatch_once(&onceToken, ^{
        client = [[Mailgun alloc] initWithBaseURL:[NSURL URLWithString:kMailgunURL]];
    });
	
    return client;
}

+ (instancetype)clientWithDomain:(NSString *)domain apiKey:(NSString *)apiKey {
    NSParameterAssert(domain);
    NSParameterAssert(apiKey);
    Mailgun *client = [self client];
    client.domain = domain;
    client.apiKey = apiKey;
    return client;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
		self.serializer = [[AFJSONRequestSerializer alloc] init];
		[self.serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
		self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)setApiKey:(NSString *)apiKey {
    NSParameterAssert(apiKey);
	[self.serializer clearAuthorizationHeader];
	[self.serializer setAuthorizationHeaderFieldWithUsername:@"api" password:apiKey];
    _apiKey = apiKey;
}

- (void)buildFormData:(id<AFMultipartFormData>)formData withAttachments:(NSDictionary *)attachments {
    NSUInteger idx = 1;
    [attachments enumerateKeysAndObjectsUsingBlock:^(NSString *filename, NSArray *attachment, BOOL *stop) {
        NSString *name = [NSString stringWithFormat:@"attachment[%d]", (unsigned int)idx];
        [formData appendPartWithFileData:attachment[1]
                                    name:name
                                fileName:filename
                                mimeType:attachment[0]];
    }];
}

- (NSURLRequest *)createSendRequest:(MGMessage *)message {
    NSString *messagePath = [NSString stringWithFormat:@"%@%@/%@", self.baseURL, self.domain, @"messages"];
    NSDictionary *params = [message dictionary];
	NSURLRequest *request = [self.serializer multipartFormRequestWithMethod:@"POST"
										  URLString:messagePath
										 parameters:params
						  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
							  
							  [self buildFormData:formData withAttachments:message.attachments];
							  [self buildFormData:formData withAttachments:message.inlineAttachments];
						  }
											  error:nil];
	
    return request;
}

- (void)sendMessage:(MGMessage *)message {
    [self sendMessage:message success:nil failure:nil];
}

- (void)sendMessage:(MGMessage *)message
            success:(void (^)(NSString *messageId))success
            failure:(void (^)(NSError *error))failure {
    NSParameterAssert(message);
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:[self createSendRequest:message]
                                                                      success:^(AFHTTPRequestOperation *_operation, id responseObject) {
                                                                          if (success) {
                                                                              success(responseObject[@"id"]);
                                                                          }
                                                                      }
                                                                      failure:^(AFHTTPRequestOperation *_operation, NSError *error) {
                                                                          NSLog(@"%@", error);
                                                                          if (failure) {
                                                                              failure(error);
                                                                          }
                                                                      }];
	
	[self.operationQueue addOperation:operation];
}

- (void)sendMessageTo:(NSString *)to
                 from:(NSString *)from
              subject:(NSString *)subject
                 body:(NSString *)body
              success:(void (^)(NSString *))success
              failure:(void (^)(NSError *))failure {
    NSParameterAssert(to);
    NSParameterAssert(from);
    NSParameterAssert(subject);
    MGMessage *message = [MGMessage messageFrom:from to:to subject:subject body:body];
    [self sendMessage:message success:success failure:failure];
}

- (void)sendMessageTo:(NSString *)to
                 from:(NSString *)from
              subject:(NSString *)subject
                 body:(NSString *)body {
    [self sendMessageTo:to from:from subject:subject body:body success:nil failure:nil];
}

- (void)checkSubscriptionToList:(NSString *)list
                        email:(NSString *)emailAddress
                        success:(void (^)(NSDictionary *member))success
                        failure:(void (^)(NSError *error))failure {
    NSParameterAssert(list);
    NSParameterAssert(emailAddress);
    NSString *messagePath = [NSString stringWithFormat:@"lists/%@/%@/%@", list, @"members", emailAddress];
	
	NSURLRequest *request = [self.serializer requestWithMethod:@"GET"
											   URLString:messagePath
											  parameters:nil
												   error:nil];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *_operation, id responseObject) {
                                                                          if (success) {
                                                                              success(responseObject);
                                                                          }
                                                                      }
                                                                      failure:^(AFHTTPRequestOperation *_operation, NSError *error) {
                                                                          NSLog(@"%@", error);
                                                                          if (failure) {
                                                                              failure(error);
                                                                          }
                                                                      }];
    [self.operationQueue addOperation:operation];
}

- (void)unsubscribeToList:(NSString *)list
                  email:(NSString *)emailAddress
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure {
    NSParameterAssert(list);
    NSParameterAssert(emailAddress);
    NSString *messagePath = [NSString stringWithFormat:@"lists/%@/%@/%@", list, @"members", emailAddress];
    NSURLRequest *request = [self.serializer requestWithMethod:@"DELETE"
													 URLString:messagePath
													parameters:nil
														 error:nil];
	
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *_operation, id responseObject) {
                                                                          if (success) {
                                                                              success();
                                                                          }
                                                                      }
                                                                      failure:^(AFHTTPRequestOperation *_operation, NSError *error) {
                                                                          NSLog(@"%@", error);
                                                                          if (failure) {
                                                                              failure(error);
                                                                          }
                                                                      }];
    [self.operationQueue addOperation:operation];
}

- (void)subscribeToList:(NSString *)list 
                email:(NSString *)emailAddress
                success:(void (^)())success
                failure:(void (^)(NSError *error))failure {
    NSParameterAssert(list);
    NSParameterAssert(emailAddress);
    NSString *messagePath = [NSString stringWithFormat:@"lists/%@/%@", list, @"members"];
    NSDictionary *params = @{@"address": emailAddress,
                             @"subscribed": @"yes",
                             @"upsert": @"yes"};
    NSURLRequest *request = [self.serializer requestWithMethod:@"POST"
													 URLString:messagePath
													parameters:params
														 error:nil];
	
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *_operation, id responseObject) {
                                                                          if (success) {
                                                                              success();
                                                                          }
                                                                      }
                                                                      failure:^(AFHTTPRequestOperation *_operation, NSError *error) {
                                                                          NSLog(@"%@", error);
                                                                          if (failure) {
                                                                              failure(error);
                                                                          }
                                                                      }];
    [self.operationQueue addOperation:operation];
}

@end
