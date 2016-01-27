//
//  SPNetWorking.m
//  NetWorking
//
//  Created by gs on 16/1/27.
//  Copyright © 2016年 KH. All rights reserved.
//

#import "SPNetWorking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPRequestOperation.h"

// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define SPAppLog(s, ... ) NSLog( @"[%@：in line: %d]-->[message: %@]", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define SPAppLog(s, ... )
#endif

static NSString *sg_privateNetworkBaseUrl = nil;
static BOOL sg_isEnableInterfaceDebug = NO;
static BOOL sg_shouldAutoEncode = NO;
static NSDictionary *sg_httpHeaders = nil;
static SPResponseType sg_responseType = SPResponseTypeJSON;
static SPRequestType  sg_requestType  = SPRequestTypeJSON;

@implementation SPNetWorking

+ (void)updateBaseUrl:(NSString *)baseUrl {
    sg_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl {
    return sg_privateNetworkBaseUrl;
}

+ (void)enableInterfaceDebug:(BOOL)isDebug {
    sg_isEnableInterfaceDebug = isDebug;
}

+ (BOOL)isDebug {
    return sg_isEnableInterfaceDebug;
}

+ (void)configResponseType:(SPResponseType)responseType {
    sg_responseType = responseType;
}

+ (void)configRequestType:(SPRequestType)requestType {
    sg_requestType = requestType;
}

+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode {
    sg_shouldAutoEncode = shouldAutoEncode;
}

+ (BOOL)shouldEncode {
    return sg_shouldAutoEncode;
}

+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders {
    sg_httpHeaders = httpHeaders;
}

+ (SPRequestOperation *)getWithUrl:(NSString *)url
                            success:(SPResponseSuccess)success
                               fail:(SPResponseFail)fail {
    return [self getWithUrl:url params:nil success:success fail:fail];
}

+ (SPRequestOperation *)getWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                            success:(SPResponseSuccess)success
                               fail:(SPResponseFail)fail {
    AFHTTPRequestOperationManager *manager = [self manager];
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPRequestOperation *op = [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject url:operation.response.URL.absoluteString params:params];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail(error);
        }
        
        if ([self isDebug]) {
            [self logWithFailError:error url:operation.response.URL.absoluteString params:params];
        }
    }];
    
    return op;
}

+ (SPRequestOperation *)postWithUrl:(NSString *)url
                              params:(NSDictionary *)params
                             success:(SPResponseSuccess)success
                                fail:(SPResponseFail)fail {
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPRequestOperationManager *manager = [self manager];
    AFHTTPRequestOperation *op = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject url:operation.response.URL.absoluteString params:params];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail(error);
        }
        
        if ([self isDebug]) {
            [self logWithFailError:error url:operation.response.URL.absoluteString params:params];
        }
    }];
    
    return op;
}

+ (SPRequestOperation *)uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail {
    return [self uploadWithImage:image
                             url:url
                        filename:filename
                            name:name
                        progress:nil
                         success:success
                            fail:fail];
}

+ (SPRequestOperation *)uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                              parameters:(NSDictionary *)parameters
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail {
    return [self uploadWithImage:image
                             url:url
                        filename:filename
                            name:name
                      parameters:parameters
                        progress:nil
                         success:success
                            fail:fail];
}

+ (SPRequestOperation *)uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                                progress:(SPUploadProgress)progress
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail {
    return [self uploadWithImage:image
                             url:url
                        filename:filename
                            name:name
                      parameters:nil
                        progress:progress
                         success:success
                            fail:fail];
}

+ (SPRequestOperation *)uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                              parameters:(NSDictionary *)parameters
                                progress:(SPUploadProgress)progress
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail {
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPRequestOperationManager *manager = [self manager];
    AFHTTPRequestOperation *op = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject url:operation.response.URL.absoluteString params:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail(error);
        }
        
        if ([self isDebug]) {
            [self logWithFailError:error url:operation.response.URL.absoluteString params:nil];
        }
    }];
    
    if (progress) {
        [op setUploadProgressBlock:progress];
    }
    
    return op;
}

+ (SPRequestOperation *)downloadWithUrl:(NSString *)url
                              saveToPath:(NSString *)saveToPath
                                progress:(SPDownloadProgress)progressBlock
                                 success:(SPResponseSuccess)success
                                 failure:(SPResponseFail)failure {
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    SPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:saveToPath append:NO];
    [op setDownloadProgressBlock:progressBlock];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            // 将下载后的文件路径返回
            success(saveToPath);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [op start];
    
    return op;
}

#pragma mark - Private
+ (AFHTTPRequestOperationManager *)manager {
    // 开启转圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPRequestOperationManager *manager = nil;;
    if ([self baseUrl] != nil) {
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    } else {
        manager = [AFHTTPRequestOperationManager manager];
    }
    
    switch (sg_requestType) {
        case SPRequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        }
        case SPRequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    switch (sg_responseType) {
        case SPResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case SPResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case SPResponseTypeData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    
    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [manager.requestSerializer setValue:sg_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 3;
    return manager;
}

+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    SPAppLog(@"\nabsoluteUrl: %@\n params:%@\n response:%@\n\n",
              url,
              params,
              [self tryToParseData:response]);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(NSDictionary *)params {
    SPAppLog(@"\nabsoluteUrl: %@\n params:%@\n errorInfos:%@\n\n",
              url,
              params,
              [error localizedDescription]);
}

+ (NSString *)encodeUrl:(NSString *)url {
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

+ (void)successResponse:(id)responseData callback:(SPResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}


@end
