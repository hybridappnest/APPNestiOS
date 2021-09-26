//
//  NSString+Category.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Category)
-(CGSize) textSizeWithFont:(CGFloat) fontSize{
   return  [self sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:fontSize] }];
}

-(CGSize) textBoldSizeWithFont:(CGFloat) fontSize{
   return  [self sizeWithAttributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:fontSize] }];
}

-(CGRect) textBoundingRectWithSize:(CGSize) aSize font:(CGFloat) fontSize{
    return [self boundingRectWithSize:aSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
}

-(CGRect) textBoldBoundingRectWithSize:(CGSize) aSize font:(CGFloat) fontSize{
    return [self boundingRectWithSize:aSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]} context:nil];
}

+(BOOL)isNull:(id)object
{
    if ([object isEqual:[NSNull null]]) {
        return YES;
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else if (object==nil){
        return YES;
    }
    else if ([object isEqualToString:@""]){
        return YES;
    }
    
    if ([object isKindOfClass:[NSString class]] && [[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+(NSString*)convertNull:(id)object
{
    if ([object isEqual:[NSNull null]]) {
        return @"";
    }
    else if ([object isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    else if (object==nil){
        return @"";
    }
    else if ([object isKindOfClass:[NSString class]] && [object isEqualToString:@"null"]){
        return @"";
    }
    if ([object isKindOfClass:[NSString class]] && [[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return @"";
    }
    return object;
}

-(NSString *) md5
{
    const char *input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);

    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }

    return digest;
}

- (NSArray*) getLinks {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *match in matches) {
      if ([match resultType] == NSTextCheckingTypeLink) {
          NSURL *url = [match URL];
          if (url) {
              [array addObject:match];
          }
          NSLog(@"found URL: %@", url);
      }
    }
    return array;
}

@end
