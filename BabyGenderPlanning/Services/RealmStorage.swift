//
//  RealmStorage.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

import RealmSwift

class RealmStorage {

    var realm: Realm {
        guard let realm = try? Realm(configuration: _realmConfiguration)
            else { fatalError(Realm.Error(.fail).localizedDescription) }

        return realm
    }

    private static let _queue = DispatchQueue(label: "RealmStorage.queue", attributes: .concurrent)
    private static var _storages = [String: RealmStorage]()

    private let _realmConfiguration: Realm.Configuration

    init (_ configuration: Realm.Configuration) {
        _realmConfiguration = configuration
    }

    static func storage(key: String, orCreate: @escaping ((String) -> RealmStorage)) -> RealmStorage {
        var storage: RealmStorage?
        _queue.sync {
            if let value = _storages[key] {
                storage = value
            } else {
                let value = orCreate(key)
                _storages[key] = value
                storage = value
            }
        }

        guard let _storage = storage
            else { fatalError(Realm.Error(.fileNotFound).localizedDescription) }
        return _storage
    }

    static func removeStorage(key: String) {
        _queue.async {
            _storages.removeValue(forKey: key)
        }
    }
}

// MARK: - Storage & Migration

extension RealmStorage {
    static var `default`: RealmStorage {
        return RealmStorage.storage(key: "default") { key in
            var configuration = Realm.Configuration.defaultConfiguration
            
            configuration.fileURL = try? FileManager.default.urlForPrivateFile(key + ".realm")
            configuration.schemaVersion = 1
            configuration.migrationBlock = commonDbMigration

            return RealmStorage(configuration)
        }
    }

    private static func commonDbMigration(_ migration: Migration, _ oldSchemaVersion: UInt64) {

    }
}

// MARK: - Find

extension RealmStorage {
    func object<T: Object, KeyType>(_ type: T.Type, forPrimaryKey primaryKey: KeyType) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: primaryKey)
    }

    func objects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type.self)
    }
}

// MARK: - Save

extension RealmStorage {
    func save<T: Object>(_ objects: T..., updatePolicy: Realm.UpdatePolicy, onFailure: ((Error) -> Void)? = nil) {
        write({ realm.add(objects, update: updatePolicy) }, onFailure: onFailure)
    }

    func save<T: Sequence>(_ objects: T, updatePolicy: Realm.UpdatePolicy, onFailure: ((Error) -> Void)? = nil) where T.Iterator.Element: Object {
        write({ realm.add(objects, update: updatePolicy) }, onFailure: onFailure)
    }
}

// MARK: - Delete

extension RealmStorage {
    func delete<T: Object>(_ objects: T..., onFailure: ((Error) -> Void)? = nil) {
        write({ realm.delete(objects) }, onFailure: onFailure)
    }

    func delete<T: Sequence>(_ objects: T, onFailure: ((Error) -> Void)? = nil) where T.Iterator.Element: Object {
        write({ realm.delete(objects) }, onFailure: onFailure)
    }
}

// MARK: - Write

extension RealmStorage {
    func write(_ block: (() throws -> Void), onFailure: ((Error) -> Void)? = nil) {
        do {
            try realm.safeWrite {
                try block()
            }
        } catch {
            onFailure?(error)
        }
    }
}

extension Realm {
    func safeWrite(_ block: (() throws -> Void)) throws {
        isInWriteTransaction ?
            try block() :
            try write(block)
    }
}
