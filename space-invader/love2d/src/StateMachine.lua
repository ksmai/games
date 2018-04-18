StateMachine = Class{}

function StateMachine:init(stateFactories)
  self.stateFactories = stateFactories
  self.current = nil
end

function StateMachine:change(state, params)
  assert(self.stateFactories[state])
  if self.current then
    self.current:exit()
  end
  self.current = self.stateFactories[state]()
  self.current:enter(params)
end

function StateMachine:update(dt)
  if self.current then
    self.current:update(dt)
  end
end

function StateMachine:render()
  if self.current then
    self.current:render()
  end
end
