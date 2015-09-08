//
//  Link.h
//  CarinthianEvents
//
//  Created by Raphael Seher on 10.07.15.
//  Copyright (c) 2015 Raphael Seher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface Links : NSObject

@property NSString* first;
@property NSString* next;
@property NSString* last;

+ (RKResponseDescriptor*)contentDescriptor;

@end
