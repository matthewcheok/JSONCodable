/*:
## Decode Operators
- `A? ~~ B, A is an optional type value, and B is default value`
- `A ?<< B, if B can be cast as type A, set A = B`
*/

public typealias jsonDType = [String: AnyObject]

infix operator ~~  { associativity left precedence 140 }


public func mustLet <T:JSONDecodable>(js:jsonDType, _ key:String) throws -> T{
    
    let f = T()
    var res:T?
    js.restore(&res, key: key)
    if let r = res{
        return r;
    }else{
        throw JSONDecodableError.MissingLetValueError(label: key, elementType: f.dynamicType);
        
    }
}

public func mustLet <T>(js:jsonDType, _ key:String) throws -> T{
    
    let optional = js[key];
    if let x = optional where ((x as? T) != nil){
        return (x as? T)!
    }else{
        throw JSONDecodableError.MissingLetValueError(label: key, elementType: T.self)
    }
}



public func mustLet <T:JSONDecodable>(js:jsonDType, _ key:String) throws -> T?{
    
    let f = T()
    var res:T?
    js.restore(&res, key: key)
    if let r = res{
        return r;
    }else{
        throw JSONDecodableError.MissingLetValueError(label: key, elementType: f.dynamicType);
        
    }
}


public func mustLet <T>(js:jsonDType, _ key:String) throws -> T?{
    
    let optional = js[key];
    if let x = optional where ((x as? T) != nil){
        return (x as? T)!
    }else{
        throw JSONDecodableError.MissingLetValueError(label: key, elementType: T.self)
    }
}

public func ~~ <T>(d:(jsonDType, String), f:T) -> T{
    let js = d.0
    let key = d.1
    let optional = js[key];
    if let x = optional where ((x as? T) != nil){
        return (x as? T)!
    }else{
        return f;
    }
}

public func ~~ <T:JSONDecodable>(d:(jsonDType, String), f:T) -> T{
    let js = d.0
    let key = d.1
    
    var res:T?
    js.restore(&res, key: key)
    if let r = res{
        return r;
    }else{
        return f;
    }
}

public func ~~ <T:JSONDecodable>(d:(jsonDType, String), f:T?) -> T?{
    let js = d.0
    let key = d.1
    
    var res:T?
    js.restore(&res, key: key)
    if let r = res{
        return r;
    }else{
        return nil;
    }
}

public func ~~ <T:JSONDecodable>(d:(jsonDType, String), f:[T]) -> [T]{
    let js = d.0
    let key = d.1
    
    
    var res:[T]?
    js.restore(&res, key: key)
    if let r = res{
        return r;
    }else{
        return f;
    }
}

public func ~~ <T:JSONDecodable>(d:(jsonDType, String), f:[T]?) -> [T]?{
    let js = d.0
    let key = d.1
    var res:[T]?
    js.restore(&res, key: key)
    if let r = res{
        return r;
    }else{
        return f;
    }
}



infix operator ?<<  { associativity left precedence 140 }



public func ?<< <T:JSONDecodable>(inout f:T,d:(jsonDType, String)){
    
    let js = d.0
    let key = d.1
    var res:T? = T()
    js.restore(&res, key: key)
    if let r = res{
        f = r;
    }
}

public func ?<< <T:JSONDecodable>(inout f:T?,d:(jsonDType, String)){
    
    let js = d.0
    let key = d.1
    var res:T? = T()
    js.restore(&res, key: key)
    f = res;
    
}



public func ?<< <T:JSONDecodable>(inout f:[T],d:(jsonDType, String)){
    
    let js = d.0
    let key = d.1
    var res:[T] = []
    js.restore(&res, key: key)
    f = res
}


public func ?<< <T:JSONDecodable>(inout f:[T]?,d:(jsonDType, String)){
    
    let js = d.0
    let key = d.1
    var res:[T]? = []
    js.restore(&res, key: key)
    f = res
}


public func ?<< <T>(inout f:T,d:(jsonDType, String)){
    
    let js = d.0
    let key = d.1
    let optional = js[key];
    if let x = optional where ((x as? T) != nil){
        f = (x as? T)!;
    }
}

public func ?<< <T>(inout f:T?,d:(jsonDType, String)){
    
    let js = d.0
    let key = d.1
    let optional = js[key];
    if let x = optional where ((x as? T) != nil){
        f = (x as? T);
    }
}






