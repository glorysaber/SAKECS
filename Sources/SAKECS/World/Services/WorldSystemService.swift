//
//  WorldSystemService.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol WorldSystemService {

	/// The count of systems
	var systemCount: Int { get }

	/// Updates all systems with no increase in system time
	func tick()

	/// Updates all systems with an increase of 1 in system time
	func tock()

	/// Updates all systems and increases the system time
	func increaseSystemTime(by time: Double)

	/// Adds a system to the ECS to be ran at every system time increase
	func add(system: EntityComponentSystem)

	/// removes a system
	func remove(system: EntityComponentSystem.Type)

	/// gets a system of a type
	func getSystems<SystemType: EntityComponentSystem>(ofType: SystemType.Type) -> [SystemType]

}
