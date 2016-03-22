//
//  MailGun.h
//  MailGunExample
//
//  Created by Jay Baird on 1/11/13.
//  Copyright (c) 2013 Rackspace Hosting. All rights reserved.
//

#import "Mailgun.h"

NSString * const kMailgunURL = @"https://api.mailgun.net/v2";

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
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)setApiKey:(NSString *)apiKey {
    NSParameterAssert(apiKey);
    [self.requestSerializer clearAuthorizationHeader];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:@"api" password:apiKey];
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

- (void)sendMessage:(MGMessage *)message {
    [self sendMessage:message success:nil failure:nil];
}

- (void)sendMessage:(MGMessage *)message
            success:(void (^)(NSString *messageId))success
            failure:(void (^)(NSError *error))failure {
    
    NSParameterAssert(message);
    NSString *messagePath = [NSString stringWithFormat:@"%@/%@", self.domain, @"messages"];
    NSDictionary *params = [message dictionary];
    __block id weakSelf = self;
    
    [self POST:messagePath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [weakSelf buildFormData:formData withAttachments:message.attachments];
        [weakSelf buildFormData:formData withAttachments:message.inlineAttachments];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success) {
            success(responseObject[@"id"]);
        }
        
    }  failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
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
    [self GET:messagePath parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)unsubscribeToList:(NSString *)list
                  email:(NSString *)emailAddress
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure {
    NSParameterAssert(list);
    NSParameterAssert(emailAddress);
    NSString *messagePath = [NSString stringWithFormat:@"lists/%@/%@/%@", list, @"members", emailAddress];
    
    [self DELETE:messagePath parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
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
    
    [self POST:messagePath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
}

@end
