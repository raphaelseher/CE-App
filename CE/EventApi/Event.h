//
//  Event.h
//  CarinthianEvents
//
//  Created by Raphael Seher on 08.07.15.
//  Copyright (c) 2015 Raphael Seher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restkit/RestKit.h>

/**
 *
 */
@interface Categories : NSObject

@property NSString *id;
@property NSString *name;

+ (RKResponseDescriptor*)contentDescriptor;

@end

/**
 *
 */
@interface Geo : NSObject

@property double latitude;
@property double longitude;

@end

/**
 *
 */
@interface Address : NSObject

@property NSString *streetAddress;
@property NSString *postalCode;
@property NSString *addressCountry;
@property NSString *addressLocality;

@end

/**
 *
 */
@interface Location : NSObject

@property NSString *name;
@property Geo *geo;
@property Address *address;

@end

/**
 *
 */
@interface Image : NSObject

@property NSString *caption;
@property int width;
@property int height;
@property NSString *contentUrl;

@end

/**
 * SubEvent
 */
@interface SubEvent : NSObject

@property NSDate *startDate;
@property NSDate *endDate;
@property Location *location;

@end

/**
 * Event
 */
@interface Event : NSObject

@property NSString *name;
@property NSString *eventDescription;
@property NSDate *startDate;
@property NSDate *endDate;
@property NSString *url;
@property NSArray *categories;
@property Location *location;
@property Image *image;
@property NSArray *subEvents;

+ (RKResponseDescriptor*)contentDescriptor;

@end
