#import "JWTEncoderImpl.h"
#include <iostream>
#include <jwt/jwt.hpp>

@implementation JWTEncoderImpl

- (NSString *)encodeWithPrivateKey:(NSString *)privateKey issuerID:(NSUUID *)issuerID keyID:(NSString *)keyID
{
    using namespace jwt::params;
    
    auto key = [privateKey cStringUsingEncoding:NSASCIIStringEncoding];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:60 * 24];
    jwt::jwt_object obj{
        algorithm("ES256"),
        headers({{"kid", keyID.UTF8String}}),
        secret(key)};
    obj
    .add_claim(jwt::registered_claims::issuer, issuerID.UUIDString.lowercaseString.UTF8String)
    .add_claim(jwt::registered_claims::expiration, expirationDate.timeIntervalSince1970)
    .add_claim(jwt::registered_claims::audience, "appstoreconnect-v1");
    
    auto enc_str = obj.signature();
    return [NSString stringWithUTF8String:enc_str.c_str()];
}

@end
