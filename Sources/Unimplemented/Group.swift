
/**
Each EntityGroup is a group of entities matching a query that is kept up to date.
**/
class EntityGroup {
  /// The query to match against
  let entityQuery: EntityQuery
  
  /// The entities matching the query
  var entities: Set<Entity>
  
  /// The parent group from which this group is querying, the entities must exist in all parents
  let parent: EntityGroup?
  
  /// All the children based on this group
  var children = [EntityGroup]()
  
  internal init(query: EntityQuery, ecs: ECSManager) {
    entityQuery = query
    parent = nil
    entities = Set<Entity>()
  }
  
  internal init(query: EntityQuery, parent: EntityGroup) {
    entityQuery = query
    self.parent = parent
    
    entities = parent.query(with: query)
    // TODO: ADD OPTIMIZATION TO CHECK IF ANY CHILDREN MATCH THE QUERY
  }
    
  /// Gets all the entities matching a query from this groups entity pool.
  func query(with: EntityQuery) -> Set<Entity> {
    
  }
  
  /// Returns a new EntityGroup with the parent being this EntityGroup or a child group which more closly mathes a query
  func group(with: EntityQuery) -> EntityGroup {
  
  }

}
