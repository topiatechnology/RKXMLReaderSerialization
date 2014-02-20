//
//  RKXMLReaderSerialization.m
//  RestKit
//
//  Created by Christopher Swasey on 1/24/12.
//  Copyright (c) 2009-2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RKXMLReaderSerialization.h"

@implementation RKXMLReaderSerialization

+ (id)objectFromData:(NSData *)data error:(NSError **)error
{
    return [XMLReader dictionaryForXMLData:data error:error];
}

//	This method is implemented to create an XML document from and object.
//  It accomplishes this by creating an XML element tag for every object in the
//	object dictionary.  It does NOT support attributes at all.
+ (NSData *)dataFromObject:(id)object error:(NSError **)error
{
    NSDictionary *dataDict = (NSDictionary *)object ;
    NSString *rootElement = [[ object keyEnumerator ] nextObject ] ;
    
    NSLog ( @"[ RKXMLReaderSerialization dataFromObject:error: -- %@", object ) ;
    NSString *xmlString = [ NSString stringWithFormat:@"<%@>%@</%@>", rootElement, [ self contentOfDict:[ dataDict objectForKey:rootElement ] ], rootElement ] ;
    return [ xmlString dataUsingEncoding:NSUTF8StringEncoding ] ;
}

+ (NSString *)contentOfDict:(NSDictionary *)dict
{
    NSMutableString *xmlString = [ NSMutableString string ]  ;
    
    NSEnumerator *keyEnum = [ dict keyEnumerator ] ;
    
    for ( NSString * subKey in keyEnum )
    {
        if ( [ subKey isEqualToString:@"text" ] )
        {
            NSObject *value = [ dict objectForKey:subKey ] ;
            if ( [ value isKindOfClass:[ NSString class ] ] )
            {
                [ xmlString  appendString:(NSString *)value  ] ;
            }
            if ( [ value isKindOfClass:[ NSNumber class ] ] )
            {
                [ xmlString appendString:[ (NSNumber *)value stringValue ] ] ;
            }
        }
        else
        {
            NSObject *subObj = [ dict objectForKey:subKey ] ;
            if ( [ subObj isKindOfClass:[ NSDictionary class ] ] )
            {
                NSDictionary *subDict = (NSDictionary *)subObj ;
                if ( [ subDict count ] > 0 )
                    [ xmlString  appendString:[ NSString stringWithFormat:@"<%@>%@</%@>", subKey, [ self contentOfDict:subDict ], subKey ] ] ;
            }
            if ( [ subObj isKindOfClass:[ NSArray class ] ] )
            {
                NSArray *subArray = (NSArray *)subObj ;
                [ xmlString appendString:[ NSString stringWithFormat:@"%@", [ self contentOfArray:subArray withKey:subKey] ] ];
            }
        }
    }
    
    return xmlString ;
}

+ (NSString *)contentOfArray:(NSArray *)array withKey:(NSString *)key
{
    NSMutableString *xmlString = [ NSMutableString string ]  ;
    
    for ( NSObject *obj in array )
    {
        if ( [ obj isKindOfClass:[ NSDictionary class ] ] )
        {
            NSDictionary *subDict = (NSDictionary *)obj ;
            [ xmlString appendString:[ NSString stringWithFormat:@"<%@>%@</%@>", key, [ self contentOfDict:subDict ], key ] ] ;
        }
        if ( [obj isKindOfClass:[ NSArray class ] ] )
        {
            NSArray *subArray = (NSArray *)obj ;
            [ xmlString appendString:[ NSString stringWithFormat:@"<%@>%@</%@>", key, [ self contentOfArray:subArray withKey:key ], key ] ];
        }
    }

    return xmlString ;
}

@end
