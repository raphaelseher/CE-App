//
//  EventApi.m
//  CarinthianEvents
//
//  Created by Raphael Seher on 08.07.15.
//  Copyright (c) 2015 Raphael Seher. All rights reserved.
//

#import "EventApi.h"

@implementation EventApi

static NSString* API_BASE_URL = @"http://veranstaltungen.kaernten.at/api/";
static NSString* API_END_POINT = @"endpoints/557ea81f6d6564769e010000";

static EventApi *sharedInstance;

/**
 *
 */
+ (EventApi *)sharedInstance {
  if (!sharedInstance) {
    sharedInstance = [[EventApi alloc] init];
  }
  
  return sharedInstance;
}

/**
 *
 */
-(id)init {
  //create RKObjectManager
  RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
  [RKObjectManager setSharedManager:objectManager];
  [RKObjectManager sharedManager].requestSerializationMIMEType = RKMIMETypeJSON;
  
  //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
  RKLogConfigureByName("*", RKLogLevelOff);
  
  return self;
}

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
            completion:(void (^)(NSArray *eventArray, Links *links))completionHandler {
  
  NSString *path = [NSString stringWithFormat:@"%@?page=%d&pagesize=%d", API_END_POINT, page, pageSize];
  
  if (category != nil) {
    path = [path stringByAppendingString:[NSString stringWithFormat:@"&filter[category]=%@", category]];
  }
  if (startDate != nil && endDate != nil) {
    path = [path stringByAppendingString:[NSString stringWithFormat:@"&filter[from]=%@&filter[to]=%@", startDate, endDate]];
  }
  if (lat != 0 && lon != 0 && distance != 0) {
    path = [path stringByAppendingString:[NSString stringWithFormat:@"&filter[lat]=%f&filter[lng]=%f&filter[distance]=%d", lat, lon, distance]];
  }
  
  [self getEventsFromPath:path withCompletionHandler:completionHandler];
}

- (void)eventsFromPage:(int)page andPageSize:(int)pageSize completion:(void (^)(NSArray *eventArray, Links *links))completionHandler {
  
  NSString *path = [NSString stringWithFormat:@"%@?page=%d&pagesize=%d", API_END_POINT, page, pageSize];
  
  [self getEventsFromPath:path withCompletionHandler:completionHandler];
}

- (void)eventsFromPage:(int)page andPageSize:(int)pageSize withCategorie:(NSString *)category completion:(void (^)(NSArray *, Links *))completionHandler {
  NSString *path = [NSString stringWithFormat:@"%@?page=%d&pagesize=%d&filter[category]=%@", API_END_POINT, page, pageSize, category];
  
  [self getEventsFromPath:path withCompletionHandler:completionHandler];
}

- (void)eventsFromPage:(int)page andPageSize:(int)pageSize fromDate:(NSString *)startDate toDate:(NSString *)endDate completion:(void (^)(NSArray *, Links *))completionHandler {
  NSString *path = [NSString stringWithFormat:@"%@?page=%d&pagesize=%d&filter[from]=%@&filter[to]=%@", API_END_POINT, page, pageSize, startDate, endDate];
  
  [self getEventsFromPath:path withCompletionHandler:completionHandler];
}

- (void)eventsFromPage:(int)page andPageSize:(int)pageSize withLat:(double)lat andLon:(double)lon andDistance:(int)distance completion:(void (^)(NSArray *, Links *))completionHandler {
  NSString *path = [NSString stringWithFormat:@"%@?page=%d&pagesize=%d&filter[lat]=%f&filter[lng]=%f&filter[distance]=%d", API_END_POINT, page, pageSize, lat, lon, distance];
  
  [self getEventsFromPath:path withCompletionHandler:completionHandler];
}

- (void)categories:(void (^)(NSArray *))completionHandler {
  NSString *path = @"http://veranstaltungen.kaernten.at/api/categories";
  
  [[RKObjectManager sharedManager] addResponseDescriptor:[Categories contentDescriptor]];
  [[RKObjectManager sharedManager] getObject:nil path:path parameters:nil
                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                       NSArray* categories = mappingResult.array;
                                       completionHandler(categories);
                                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                       NSLog(@"Error: %@", error);
                                     }
   ];
}

/**
 *
 */
- (void)getEventsFromPath:(NSString*)path withCompletionHandler:(void (^)(NSArray *eventArray, Links *links))completionHandler {
  [[RKObjectManager sharedManager] addResponseDescriptor:[Event contentDescriptor]];
  [[RKObjectManager sharedManager] addResponseDescriptor:[Links contentDescriptor]];
  [[RKObjectManager sharedManager] getObject:nil path:path parameters:nil
                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                       NSArray *events = mappingResult.dictionary[@"events"];
                                       Links *links = mappingResult.dictionary[@"links"];
                                       completionHandler(events, links);
                                     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                       NSLog(@"Error: %@", error);
                                     }
   ];
}



@end
