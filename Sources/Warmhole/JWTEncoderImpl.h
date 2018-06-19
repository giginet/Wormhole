#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTEncoderImpl : NSObject

- (NSString *)encodeWithPrivateKey:(NSString *)privateKey
                          issuerID:(NSInteger)issuerID
                             keyID:(NSUUID *)keyID NS_SWIFT_NAME(encode(with:issuerID:keyID:));

@end

NS_ASSUME_NONNULL_END
