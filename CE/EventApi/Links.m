//
//  Link.m
//  CarinthianEvents
//
//  Created by Raphael Seher on 10.07.15.
//  Copyright (c) 2015 Raphael Seher. All rights reserved.
//

#import "Links.h"

@implementation Links

+ (RKResponseDescriptor*)contentDescriptor {
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx

  RKObjectMapping *linkMapping = [RKObjectMapping mappingForClass:[Links class]];
  [linkMapping addAttributeMappingsFromArray:@[@"first", @"next", @"last"]];
  
  RKResponseDescriptor *contentDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:linkMapping
                                                                                         method:RKRequestMethodGET
                                                                                    pathPattern:nil
                                                                                        keyPath:@"links"
                                                                                    statusCodes:statusCodes];
  return contentDescriptor;
}

@end
