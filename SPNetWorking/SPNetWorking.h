//
//  SPNetWorking.h
//  NetWorking
//
//  Created by gs on 16/1/27.
//  Copyright © 2016年 KH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SPResponseType) {
    SPResponseTypeJSON = 1, // 默认
    SPResponseTypeXML  = 2, // XML
                              // 特殊情况下，一转换服务器就无法识别的，默认会尝试转换成JSON，若失败则需要自己去转换
    SPResponseTypeData = 3
};

typedef NS_ENUM(NSUInteger, SPRequestType) {
    SPRequestTypeJSON = 1, // 默认
    SPRequestTypePlainText  = 2 // 普通text/html
};

@class AFHTTPRequestOperation;

// 请勿直接使用AFHTTPRequestOperation,以减少对第三方的依赖
typedef AFHTTPRequestOperation SPRequestOperation;

/**
 *
 *  请求成功的回调
 *
 *  @param response 服务端返回的数据类型，通常是字典
 */
typedef void(^SPResponseSuccess)(id response);

/**
 *  网络响应失败时的回调
 *
 *  @param error 错误信息
 */
typedef void(^SPResponseFail)(NSError *error);


@interface SPNetWorking : NSObject

/**
 *  用于指定网络请求接口的基础url，如：
 *  http://www.baidu.com或者http://192.168.2.110:8080等
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl  网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;


/**
 *
 *  对外公开可获取当前所设置的网络接口基础url
 *
 *  @return 当前基础url
 */
+ (NSString *)baseUrl;

/**
 *
 *  开启或关闭接口打印信息
 *
 *  @param isDebug 开发期，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

/**
 *
 *  配置返回格式，默认为JSON。若为XML或者PLIST请在全局修改一下
 *
 *  @param responseType 响应格式
 */
+ (void)configResponseType:(SPResponseType)responseType;

/**
 *
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestType 请求格式
 */
+ (void)configRequestType:(SPRequestType)requestType;

/**
 *
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/**
 *
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 *
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList?categoryid=1
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (SPRequestOperation *) getWithUrl:(NSString *)url
                            success:(SPResponseSuccess)success
                               fail:(SPResponseFail)fail;
/**
 *
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList
 *  @param params  接口中所需要的拼接参数，如@{"categoryid" : @(12)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (SPRequestOperation *) getWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                            success:(SPResponseSuccess)success
                               fail:(SPResponseFail)fail;

/**
 *
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList
 *  @param params  接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (SPRequestOperation *) postWithUrl:(NSString *)url
                              params:(NSDictionary *)params
                             success:(SPResponseSuccess)success
                                fail:(SPResponseFail)fail;

/**
 *
 *  图片上传接口，若不指定baseurl，可传完整的url
 *
 *  @param image    图片对象
 *  @param url      上传图片的接口路径，如/path/images/
 *  @param filename 给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *  @param name     与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *  @param success  上传成功的回调
 *  @param fail     上传失败的回调
 *
 *  @return 返回类型有取消请求的api
 */
+ (SPRequestOperation *) uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail;
+ (SPRequestOperation *) uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                              parameters:(NSDictionary *)parameters
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail;

/**
 *
 *  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytesWritten         总上传大小
 *  @param totalBytesExpectedToWrite 还有多少需要上传
 */
typedef void (^SPUploadProgress)(NSUInteger bytesWritten,
                                  long long totalBytesWritten,
                                  long long totalBytesExpectedToWrite);

/**
 *
 *  图片上传接口，若不指定baseurl，可传完整的url
 *
 *  @param image    图片对象
 *  @param url      上传图片的接口路径，如/path/images/
 *  @param filename 给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *  @param name     与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *  @param progress 上传进度
 *  @param success  上传成功的回调
 *  @param fail     上传失败的回调
 *
 *  @return 返回类型有取消请求的api
 */
+ (SPRequestOperation *) uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                                progress:(SPUploadProgress)progress
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail;
+ (SPRequestOperation *) uploadWithImage:(UIImage *)image
                                     url:(NSString *)url
                                filename:(NSString *)filename
                                    name:(NSString *)name
                              parameters:(NSDictionary *)parameters
                                progress:(SPUploadProgress)progress
                                 success:(SPResponseSuccess)success
                                    fail:(SPResponseFail)fail;

/**
 *
 *  下载进度
 *
 *  @param bytesRead                 已下载的大小
 *  @param totalBytesRead            文件总大小
 *  @param totalBytesExpectedToRead 还有多少需要下载
 */
typedef void (^SPDownloadProgress)(NSUInteger bytesRead,
                                    long long totalBytesRead,
                                    long long totalBytesExpectedToRead);

/**
 *
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 */
+ (SPRequestOperation *) downloadWithUrl:(NSString *)url
                              saveToPath:(NSString *)saveToPath
                                progress:(SPDownloadProgress)progressBlock
                                 success:(SPResponseSuccess)success
                                 failure:(SPResponseFail)failure;




@end
