//
//  WorldEntityService.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol WorldEntityService {

	/// Gets the total component count of all componentTypes
	var componentCount: Int { get }

	/// removes an entity from all systems
	func destroy(entity: Entity)

	/// Removes a group of entities from all entities
	func destroy(entities: [Entity])

	/// Creates an entity, returns nil if unsuccessfully created
	func createEntity() -> Entity?

	/// Returns a gauranteed amound of entities, else nil and removes the entities from the system if any were created
	func createEntities(_ amount: Int) -> [Entity]

}
