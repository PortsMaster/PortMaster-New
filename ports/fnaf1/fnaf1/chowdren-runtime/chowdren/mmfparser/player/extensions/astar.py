# Copyright (c) 2008 Mikael Lind
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from heapq import heappush, heappop
from sys import maxint
F, H, NUM, G, POS, OPEN, VALID, PARENT = xrange(8)

def astar(start_pos, neighbors, goal, cost, heuristic, give_cost = False):
    start_g = 0
    limit=maxint
    nums = iter(xrange(maxint))
    start_h = heuristic(start_pos)
    start = [start_g + start_h, start_h, nums.next(), start_g, start_pos, True,
             True, None]
    nodes = {start_pos: start}
    heap = [start]
    best = start
    while heap:
        current = heappop(heap)
        current[OPEN] = False
        if goal(current[POS]):
            best = current
            break
        for neighbor_pos in neighbors(current[POS]):
            neighbor_g = current[G] + cost(current[POS], neighbor_pos)
            neighbor = nodes.get(neighbor_pos)
            if neighbor is None:
                if len(nodes) >= limit:
                    continue
                neighbor_h = heuristic(neighbor_pos)
                neighbor = [neighbor_g + neighbor_h, neighbor_h, nums.next(),
                            neighbor_g, neighbor_pos, True, True, current[POS]]
                nodes[neighbor_pos] = neighbor
                heappush(heap, neighbor)
                if neighbor_h < best[H]:
                    best = neighbor
            elif neighbor_g < neighbor[G]:
                if neighbor[OPEN]:
                    neighbor[VALID] = False
                    nodes[neighbor_pos] = neighbor = neighbor[:]
                    neighbor[F] = neighbor_g + neighbor[H]
                    neighbor[NUM] = nums.next()
                    neighbor[G] = neighbor_g
                    neighbor[VALID] = True
                    neighbor[PARENT] = current[POS]
                    heappush(heap, neighbor)
                else:
                    neighbor[F] = neighbor_g + neighbor[H]
                    neighbor[G] = neighbor_g
                    neighbor[PARENT] = current[POS]
                    neighbor[OPEN] = True
                    heappush(heap, neighbor)
        while heap and not heap[0][VALID]:
            heappop(heap)
    if give_cost:
        path = []
        costs = []
        current = best
        while current[PARENT] is not None:
            path.append(current[POS])
            costs.append(current[G])
            current = nodes[current[PARENT]]
        path.reverse()
        costs.reverse()
        return path, costs
    else:
        path = []
        current = best
        while current[PARENT] is not None:
            path.append(current[POS])
            current = nodes[current[PARENT]]
        path.reverse()
        return path