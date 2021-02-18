//
//  WolrdTagService.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol WorldTagService {

	/// Adds an entity to a Tag
	func add<Raw: RawRepresentable>(tag: Raw, to entity: Entity) where Raw.RawValue == String

	/// Removes a tag from an entity.
	func remove<Raw: RawRepresentable>(tag: Raw, from entity: Entity) where Raw.RawValue == String

	/// Adds an entity to a Tag. Throws if the entity doesnt exist.
	func add(tag: EntityTag, to entity: Entity)

	/// Removes a tag from an entity. Throws if the entity doesnt exist.
	func remove(tag: EntityTag, from entity: Entity)
}
