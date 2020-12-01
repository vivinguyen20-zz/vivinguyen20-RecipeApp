//
//  DatabaseManager.swift
//  RecipeApp
//
//  Created by Selina on 30/11/2020.
//

import Foundation
import RealmSwift

struct Sorted {
    var key: String
    var ascending: Bool = true
}

class DatabaseManager {
    static let shared = DatabaseManager()
    var realm: Realm?
    var realmError: NSError {
        return NSError(domain: "RealmError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Realm databases is not initiliazed."])
    }
    
    var isActive = false
    
    private init() {
        
        // Initilize realm with default configurations
        do {
            let configuration = Realm.Configuration.defaultConfiguration
            realm = try Realm(configuration: configuration)
            isActive = true
            debugPrint("Realm path is \(String(describing: configuration.fileURL))")
        } catch {
            debugPrint("database manager init error = \(error)")
        }
        
    }
    
    func reset() throws {
        guard let realm = self.realm else { throw realmError}
        
        try self.safeWrite {
            realm.deleteAll()
        }
    }
    
    private func safeWrite(_ block: (() throws -> Void)) throws {
        guard let realm = self.realm else { throw realmError}
        
        if realm.isInWriteTransaction {
            try block()
        } else {
            do {
                try realm.write(block)
            } catch {
            }
        }
    }
}

extension DatabaseManager: StorageContext {
    
    @discardableResult
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate? = nil, sorted: Sorted? = nil) -> Results<T>? {
        guard isActive else {
            return nil
        }
        
        var objects = self.realm?.objects(T.self)
        
        if let predicate = predicate { objects = objects?.filter(predicate)}
        
        if let sorted = sorted { objects = objects?.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)}
        
        return objects
    }
    
    func create<T: Object>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws {
        
        guard let realm = realm else { throw realmError}
        
        try safeWrite {
            let newObject = realm.create(T.self, value: [], update: .all)
            completion(newObject)
        }
    }
    
    func write(block: (() throws -> Void), completion: @escaping CompletionHandler) {
        guard isActive else {
            completion(realmError)
            return
        }
        
        do {
            try safeWrite(block)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func save(object: Object, update: Realm.UpdatePolicy = .all, completion: @escaping CompletionHandler) {
        guard isActive else {
            completion(realmError)
            return
        }
        
        threadSafeSave(object: object, completion: completion)
    }
    
    func save(objects: [Object], update: Realm.UpdatePolicy = .all, completion: @escaping CompletionHandler) {
        DispatchQueue.main.async { [weak self] in
            do {
                try self?.safeWrite {
                    self?.realm?.add(objects, update: update)
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func update(block: @escaping () -> Void) throws {
        try safeWrite {
            block()
        }
    }
    
    @discardableResult func delete(object: Object, cascading: Bool = false) -> Bool {
        guard isActive else { return false }
        
        do {
            try safeWrite { realm?.delete(object) }
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult func delete(objects: [Object], cascading: Bool = false) -> Bool {
        
        guard isActive else {
            return false
        }
        
        do {
            try safeWrite {
                for object in objects {
                    realm?.delete(object)
                    
                }
            }
            return true
        } catch {
            return false
        }
    }
    
    func deleteAll<T: Object>(_ model: T.Type) throws {
        
        guard let realm = realm else { throw realmError}
        
        try safeWrite {
            let objects = realm.objects(T.self)
            
            for object in objects {
                realm.delete(object)
            }
            
        }
    }
    
    private func threadSafeSave(object: Object, completion: @escaping CompletionHandler, update: Realm.UpdatePolicy = .all) {
        let realmObjectRef = ThreadSafeReference(to: object)
        let backgroundQueue = DispatchQueue(label: ".realm", qos: .background)
        backgroundQueue.async {[weak self] in
            guard let realmObject = self?.realm?.resolve(realmObjectRef) else {
                completion(nil)
                return // although proper error handling should happen
            }
            
            do {
                try self?.safeWrite {
                    self?.realm?.add(realmObject, update: update)
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
