//
//  JsonMapper.swift
//  Eva
//
//  Created by Poomalai on 4/3/17.
//  Copyright © 2017 Eva. All rights reserved.
//

import Foundation

precedencegroup ResponseMapperGroup {
    associativity: left
    assignment: true
    higherThan: DefaultPrecedence
}

public protocol Mappable{
    associatedtype MappableType = Self
    static func Map(_ json: JSONObject) -> Self?
}

infix operator >>> : ResponseMapperGroup
infix operator <- : ResponseMapperGroup
infix operator <-- : ResponseMapperGroup
infix operator <-> : ResponseMapperGroup

public typealias JSONObject = Any
public typealias JSONDictionary = [String: JSONObject]
public typealias JSONArray = [JSONObject]

public func ParseArray<A: Mappable>(_ object: JSONObject) -> A? {
    return A.Map(object)
}

public func Parse<A>(_ object: JSONObject) -> A? {
    return object as? A
}


extension String: Mappable {
    public static func Map(_ json: JSONObject) -> String? {
        return json as? String
    }
}

extension Bool: Mappable {
    public static func Map(_ json: JSONObject) -> Bool? {
        return json as? Bool
    }
}

extension Int: Mappable {
    public static func Map(_ json: JSONObject) -> Int? {
        return json as? Int
    }
}

/// Bind
public func >>><A, B>(a: A?, f: (A) -> B?) -> B? {
    if let x = a {
        return f(x)
    }
    return .none
}

/// Purify the value
public func pure<A>(a: A) -> A? {
    return .some(a)
}

/// Map Individual Values
public func <-<A>(object: JSONDictionary, key: String) -> A? {
    return ((object as NSDictionary).value(forKeyPath: key) as AnyObject) >>> Parse
    //    return ((object as NSDictionary).value(forKeyPath: key)) >>> Parse
}

/// Map Array of Modal object
public func <--<A: Mappable>(object: JSONDictionary, key: String) -> [A]? {
    return ((object <- key) >>> { (array: JSONArray) in
        array.map { $0 >>> ParseArray }
        }) >>> { flatten(array: $0) }
}

/// Map Dictionary to Modal Object
public func <-><A: Mappable>(object: JSONDictionary, key: String) -> A? {
    return (object as NSDictionary).value(forKeyPath: key) >>> ParseArray
}

public func flatten<A>(array: [A?]) -> [A] {
    var list: [A] = []
    for item in array {
        if let i = item {
            list.append(i)
        }
    }
    return list
}
