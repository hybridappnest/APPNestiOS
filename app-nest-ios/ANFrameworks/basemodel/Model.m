//
//  Model.m
//  app-nest-ios
//
//  Created by brent on 2021/9/15.

#import "Model.h"

@implementation Model

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

+(id)parseData:(NSDictionary*) result{
    NSDictionary *temp = [NSDictionary convertNull:result];
    if (temp.count <= 0) {
        return nil;
    }
    id class = [[[self class] alloc] init];
    [class parseData:result];
    return class;
}

-(void) parseData:(NSDictionary*) result{
    NSArray *keys = [result allKeys];
    for(int i = 0; i < keys.count; i++){
        NSString *key = [keys objectAtIndex:i];
        id value = [result valueForKey:key];
        if([value isKindOfClass:[NSNull class]] || [value isEqual:[NSNull null]] || value == nil){
            if (![self isNumerical:key]) {
                id temp = [self getPropertyType:key];
                value = temp;
            } else {
                value = @0;
            }
        }
        if([value isEqual:[NSString class]] && [value isEqualToString:@"null"]){
            if (![self isNumerical:key]) {
                id temp = [self getPropertyType:key];
                value = temp;
            } else {
                value = @0;
            }
        }
        [self setValue:value forKey:key];
    }
}

@end
