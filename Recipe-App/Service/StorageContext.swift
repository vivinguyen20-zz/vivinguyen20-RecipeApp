//
//  StorageContext.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//
typealias CompletionHandler = ((Error?) -> Void)
import RealmSwift

/*
 Operations on context
 */

protocol StorageContext {
    
    /*
     Return a list of objects that are conformed to the `Storable` protocol
     */
    
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?) -> Results<T>?
    
    /*
     Create a new object with default values
     return an object that is conformed to the `Storable` protocol
     */
    func create<T: Object>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws
    
    /*
     Save an object that is conformed to the `Storable` protocol
     */
    func save(object: Object, update: Realm.UpdatePolicy, completion: @escaping ((Error?) -> Void))
    
    /*s
     Save objects that is conformed to the `Storable` protocol
     */
    func save(objects: [Object], update: Realm.UpdatePolicy, completion: @escaping CompletionHandler)
    
    /*
     Update an object that is conformed to the `Storable` protocol
     */
    func update(block: @escaping () -> Void) throws
    
    /*
     Delete an object that is conformed to the `Storable` protocol
     */
    @discardableResult func delete(object: Object, cascading: Bool) -> Bool
    
    /*
     Deletes multiple objects that is conformed to the `Storable` protocol
     */
    @discardableResult func delete(objects: [Object], cascading: Bool) -> Bool
    
    /*
     Delete all objects that are conformed to the `Storable` protocol
     */
    func deleteAll<T: Object>(_ model: T.Type) throws
}
