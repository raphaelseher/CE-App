//
//  EventApi.h
//  CarinthianEvents
//
//  Created by Raphael Seher on 08.07.15.
//  Copyright (c) 2015 Raphael Seher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restkit/RestKit.h>
#import "Event.h"
#import "Links.h"

@interface EventApi : NSObject

/**
 *
 */
+ (EventApi *)sharedInstance;

/**
 *
 */
- (void)eventsFromPage:(int)page
           andPageSize:(int)pageSize
         withCategorie:(NSString *)category
              fromDate:(NSString *)startDate
                toDate:(NSString *)endDate
               withLat:(double)lat
                andLon:(double)lon
           andDistance:(int)distance
            completion:(void (^)(NSArray *eventArray, Links *links))completionHandler;

/**
 *
 */
- (void)eventsFromPage:(int)page andPageSize:(int)pageSize completion:(void (^)(NSArray *eventArray, Links *links))completionHandler;

/**
 *
 */
- (void)eventsFromPage:(int)page andPageSize:(int)pageSize withCategorie:(NSString *)category completion:(void (^)(NSArray *, Links *))completionHandler;

/**
 *
 */
- (void)eventsFromPage:(int)page andPageSize:(int)pageSize fromDate:(NSString *)startDate toDate:(NSString *)endDate completion:(void (^)(NSArray *, Links *))completionHandler;

/**
 *
 */
- (void)eventsFromPage:(int)page andPageSize:(int)pageSize withLat:(double)lat andLon:(double)lon andDistance:(int)distance completion:(void (^)(NSArray *, Links *))completionHandler;

/**
 *
 */
- (void)categories:(void (^)(NSArray*))completionHandler;

@end