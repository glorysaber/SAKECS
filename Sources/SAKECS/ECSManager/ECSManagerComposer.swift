//
//  ECSManagerComposer.swift
//  SAKECS
//
//  Created by Stephen Kac on 5/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public struct ECSManagerComposer {

	public init() {}

	public func compose_v0_0_1() -> ECSManager {
		ECSManager(componentSystem: ECSManagerComponentSystem())
	}

	public func compose_v0_0_2() -> ECSManager {
		ECSManager(componentSystem: EntityComponentTree(
			branchConstructor: {
				ArchetypeBranch {
					EntityComponentChunk(numberOfComponentsPerType: 100)
				}
			}
		))
	}
}
