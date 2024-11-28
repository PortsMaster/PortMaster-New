allPools = {}
numPools = 0
function createPool(numInPool, createFcn)
    local pool = {}
    pool.objects = {}
    pool.numInPool = numInPool
    pool.forceIndex = 1
    for k = 1,numInPool do
        pool.objects[k] = createFcn()
    end

    function pool:getFromPool()
        for k = 1,pool.numInPool do
            if not pool.objects[k].active then
                return pool.objects[k]
            end
        end
        -- by default return the next thing in the pool if no inactive is found
        pool.forceIndex = pool.forceIndex + 1
        if pool.forceIndex > pool.numInPool then
            pool.forceIndex = 1
        end
        return pool.objects[pool.forceIndex]
    end
    
    function pool:clear()
        pool.objects = nil
        pool.numInPool = 0
    end
    numPools = numPools + 1
    allPools[numPools] = pool
    return pool
end

function resetAllPools()
    for k = 1,numPools do
        allPools[k]:clear()
    end
    numPools = 0
    allPools = {}
end