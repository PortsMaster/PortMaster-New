local Graph = class('Graph')

local function DefaultTable(value)
    local t = {}
    return setmetatable(t, { __index = function(t, key)
        rawset(t, key, value)
        return value
    end})
end

function Graph:initialize()
  self.nodes = {}
  self.edges = {}
end

function Graph:addNode(data)
  table.insert(self.nodes, data)
  return #self.nodes
end

function Graph:eachNode(func)
  for i, node in ipairs(self.nodes) do
    func(i, node)
  end
end

function Graph:getNodeData(i) return self.nodes[i] end

function Graph:getPath(from, to, cost)
  assert(from ~= nil, "'from' argument must be provided.")
  assert(to ~= nil, "'to' argument must be provided.")
  if cost == nil then
    cost = function(from, to) return 1 end
  end

  local visited = DefaultTable(false)
  local dist = DefaultTable(math.huge)

  local queue = {}
  local prev = {}

  function enqueue(node)
    table.insert(queue, node)
  end

  function dequeue()
    if #queue == 0 then error("Queue is empty.") end

    local min_dist, min_index = math.huge, nil
    for i, node in ipairs(queue) do
      if dist[node] < min_dist then
        min_index = i
        min_dist = dist[node]
      end
    end
    return table.remove(queue, min_index)
  end

  dist[from] = 0
  enqueue(from)

  while #queue > 0 do
    local node = dequeue()
    visited[node] = true
    if node == to then
      break
    end

    for _, neighbor in ipairs(self:getNeighbors(node)) do
      if not visited[neighbor] then
        local alt_dist = dist[node] + cost(node, neighbor)
        if alt_dist < dist[neighbor] then
          dist[neighbor] = alt_dist
          prev[neighbor] = node
          enqueue(neighbor)
        end
      end
    end
  end

  local current = to
  local path = {}
  while current ~= from do
    table.insert(path, 1, current)
    current = prev[current]
    assert(current ~= nil, "Encountered hole when reconstructing path.")
  end
  table.insert(path, 1, from)

  return path
end

function Graph:eachEdge(func)
  for i, neighbors in pairs(self.edges) do
    for j, data in pairs(neighbors) do
      local start, end_p = self:getNodeData(i), self:getNodeData(j)
      func(i, j, start, end_p, data)
    end
  end
end

function Graph:getNeighbors(i)
  local result = {}
  for j, _ in pairs(self.edges[i]) do
    table.insert(result, j)
  end
  return result
end

function Graph:addEdge(i, j, data)
  if data == nil then data = true end
  if self.edges[i] == nil then self.edges[i] = {} end
  if self.edges[j] == nil then self.edges[j] = {} end
  self.edges[i][j] = data
  self.edges[j][i] = data
end

return Graph
