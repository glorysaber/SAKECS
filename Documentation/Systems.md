# Systems
Allow you to create a job to schedule with other systems jobs that have yours as a dependant. Also can allow you to edit entities directly or with a commandBUffer.

## ComponentSystemBase

Enabled?

EntityQueries

static GlobalSystemVersion

static LastSystemVersion

ECS belonged too

OnCreateManager()

OnDestroyManager()

OnCreate()

OnStartRunning()

OnStopRunning()

OnDestroy()

Update()

ShouldRunSystem() -> True

## JobComponentSystem: COmponentSystemBase

OnUpdate()

```csharp
public EntityCommandBuffer PostUpdateCommands { get; }
```

##ComponentSystem: ComponentSystemBase

```csharp
protected abstract JobHandle OnUpdate(JobHandle inputDeps)
```
