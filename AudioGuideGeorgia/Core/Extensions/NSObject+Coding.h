//
//  NSObject+Coding.h
//  SABAReader
//
//  Created by vaxo sherazadishvili on 1/11/13.
//  Copyright (c) 2012 Lemondo Business. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Coding)
-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;
@end
