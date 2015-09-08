//
//  Event.m
//  CarinthianEvents
//
//  Created by Raphael Seher on 08.07.15.
//  Copyright (c) 2015 Raphael Seher. All rights reserved.
//

#import "Event.h"

@implementation Event

+ (RKResponseDescriptor*)contentDescriptor {
  RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[Event class]];
  [eventMapping addAttributeMappingsFromDictionary:
   @{@"name":@"name",
     @"description":@"eventDescription",
     @"startDate":@"startDate",
     @"endDate":@"endDate",
     @"url":@"url",
     }];
  
  RKObjectMapping *categoriesMapping = [RKObjectMapping mappingForClass:[Categories class]];
  [categoriesMapping addAttributeMappingsFromArray:@[@"id", @"name"]];
  
  RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
  [locationMapping addAttributeMappingsFromArray:@[@"name"]];
  
  RKObjectMapping *geoMapping = [RKObjectMapping mappingForClass:[Geo class]];
  [geoMapping addAttributeMappingsFromArray:@[@"latitude", @"longitude"]];
  
  RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[Address class]];
  [addressMapping addAttributeMappingsFromArray:@[@"streetAddress",@"postalCode",@"addressCountry",@"addressLocality"]];
  
  RKObjectMapping *imageMapping = [RKObjectMapping mappingForClass:[Image class]];
  [imageMapping addAttributeMappingsFromArray:@[@"caption", @"width", @"height", @"contentUrl"]];
  
  RKObjectMapping *subEventMapping = [RKObjectMapping mappingForClass:[SubEvent class]];
  [subEventMapping addAttributeMappingsFromDictionary:@{@"start_date":@"startDate",
                                                        @"end_date":@"endDate",
                                                        @"location":@"location",}];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"categories"
                                                                               toKeyPath:@"categories"
                                                                             withMapping:categoriesMapping]];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location"
                                                                               toKeyPath:@"location"
                                                                             withMapping:locationMapping]];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location.geo"
                                                                               toKeyPath:@"location.geo"
                                                                             withMapping:geoMapping]];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location.address"
                                                                               toKeyPath:@"location.address"
                                                                             withMapping:addressMapping]];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"image"
                                                                               toKeyPath:@"image"
                                                                             withMapping:imageMapping]];
  
  //subEvents
  [eventMapping addRelationshipMappingWithSourceKeyPath:@"subEvents" mapping:subEventMapping];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location"
                                                                               toKeyPath:@"subEvents.location"
                                                                             withMapping:locationMapping]];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location.geo"
                                                                               toKeyPath:@"subEvents.location.geo"
                                                                             withMapping:geoMapping]];
  
  [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location.address"
                                                                               toKeyPath:@"subEvents.location.address"
                                                                             withMapping:addressMapping]];
  
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
  // Create ResponseDescriptor with objectMapping
  RKResponseDescriptor *contentDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventMapping
                                                                                         method:RKRequestMethodGET
                                                                                    pathPattern:nil
                                                                                        keyPath:@"events"
                                                                                    statusCodes:statusCodes];
  return contentDescriptor;
}

@end

@implementation Categories

+ (RKResponseDescriptor*)contentDescriptor {
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
  
  RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[Categories class]];
  //[categoryMapping addAttributeMappingsFromDictionary:@{@"id":@"categoryId",
                                                        //@"name":@"categoryName"}];
  [categoryMapping addAttributeMappingsFromArray:@[@"id", @"name"]];
  
  RKResponseDescriptor *contentDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:categoryMapping
                                                                                         method:RKRequestMethodGET
                                                                                    pathPattern:nil
                                                                                        keyPath:@"categories"
                                                                                    statusCodes:statusCodes];
  return contentDescriptor;
}

@end

@implementation Location

@end

@implementation Geo

@end

@implementation Address

@end

@implementation Image

@end

@implementation SubEvent

@end
