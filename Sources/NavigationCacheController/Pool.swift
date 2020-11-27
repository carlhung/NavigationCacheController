//
//  Pool.swift
//  Centaline
//
//  Created by Carl Hung on 17/11/2020.
//

protocol TypeName: AnyObject {
    static var typeName: String { get } // use class instead of static. otherwise, it won't use vtable to dynamically get the proper value.
}

//extension TypeName { // don't use it. it requests using `static` that inferring to not allow using vtable to look up dynamically.
//    // class var typeName: String { // error
//    static var typeName: String {
//        String(describing: Self.self)
//    }
//}

@propertyWrapper
struct Pool<T: TypeName> {
    /// Every time the projectedValue is added, there is always a copy in pool and create a strong reference.
    var pool: [String: T] = [:]
    
    private(set) var projectedValue: [String] = []
    var wrappedValue: [T] {
//        get {  projectedValue.map({ pool[$0]! }) }
        get {  projectedValue.compactMap({ pool[$0]}) }
        set { self.set(elmArr: newValue) }
    }
    
    mutating private func set(elmArr: [T]) {
        var buffer: [String] = []
        for elm in elmArr where !(buffer.contains(type(of: elm).typeName)) {
            buffer.append(type(of: elm).typeName)
            pool[type(of: elm).typeName] = elm
        }
        projectedValue = buffer
    }
    
    /// the wrappedValue array has to be unique elements.
    /// so, no duplicate values. the front in the array will be saved, the last duplciated won't be.
    init(wrappedValue: [T]) {
        self.set(elmArr: wrappedValue)
    }
    
    /// get the element from the pool.
//    func getElmentFromPool<U: TypeName>(targetType: U.Type) -> U? {
//        return pool[targetType.typeName] as? U
//    }
    
    /// get the element from the pool.
    func getElmentFromPool(targetType: T.Type) -> T? {
        return pool[targetType.typeName]
    }
    
    /// Add a new element.
    /// It will find the same type of element and update to this new element from the pool.
    mutating func add(_ elm: T) {
        let typeName = type(of: elm).typeName
        let indexArr = self.projectedValue.indices(of: typeName)
        indexArr.reversed().forEach({ self.projectedValue.remove(at: $0) })
        self.projectedValue.append(typeName)
        pool[typeName] = elm
    }
    
    mutating func reset() {
        pool = [:]
        projectedValue = []
    }
    
    /// never remove from the pool, only remove from the face value(the `projectedValue`).
    mutating func remove(at index: Int) {
        self.projectedValue.remove(at: index)
    }
}

fileprivate extension Array where Element: Equatable {
    func indices(of element: Element) -> [Int] {
//        return self.enumerated().filter({ element == $0.element }).map(\.offset)
        return self.indices.filter { self[$0] == element }
    }
}
