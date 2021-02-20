//
//  World.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public class World {

	public internal(set) var systems: WorldSystemService
	public internal(set) var tags: WorldTagService
	public internal(set) var entities: WorldEntityService
	public internal(set) var entityComponents: WorldEntityComponentService

	internal init(
		systems: WorldSystemService,
		tags: WorldTagService,
		entities: WorldEntityService,
		entityComponents: WorldEntityComponentService
	) {
		self.systems = systems
		self.tags = tags
		self.entities = entities
		self.entityComponents = entityComponents
	}

}
