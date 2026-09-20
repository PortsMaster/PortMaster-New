#ifndef JUMP_POINT_SEARCH_H
#define JUMP_POINT_SEARCH_H

// Public domain Jump Point Search implementation by False.Genesis
// Very fast pathfinding for uniform cost grids.
// Supports incremental pathfinding.

// Please keep the following source information intact when you use this file in your own projects:
// This file originates from: https://github.com/fgenesis/jps
// Based on the paper http://users.cecs.anu.edu.au/~dharabor/data/papers/harabor-grastien-aaai11.pdf
// by Daniel Harabor & Alban Grastien.
// Jumper (https://github.com/Yonaba/Jumper) and PathFinding.js (https://github.com/qiao/PathFinding.js)
// served as reference for this implementation.
// If you use this, attribution would be nice, but is not necessary.

// ====== COMPILE CONFIG ======

// If this is defined, compare all jumps against recursive reference implementation (only if _DEBUG is defined)
//#define JPS_VERIFY

// ============================

// Usage:
/*
// Define a class that overloads `operator()(x, y) const`, returning a value that can be treated as boolean.
// You are responsible for bounds checking!
// You want your operator() to be as fast as possible, as it will be called a LOT.

struct MyGrid
{
	inline bool operator()(unsigned x, unsigned y) const
	{
		if(x < width && y < height) // Unsigned will wrap if < 0
			... return true if terrain at (x, y) is walkable.
	}
	unsigned width, height;
};

// Then you can retrieve a path:

MyGrid grid;
// ... set grid width, height, and whatever
unsigned step = 0; // set this to 1 if you want a detailed single-step path
                   // (e.g. if you plan to further mangle the path yourself),
                   // or any other higher value to output every Nth position.
JPS::PathVector path; // The resulting path will go here.


// Single-call interface:
bool found = JPS::findPath(path, grid, startx, starty, endx, endy, step);


// Alternatively, if you want more control:

JPS::Searcher<MyGrid> search(grid);
while(true)
{
	// ..stuff happening ...

	// build path incrementally from waypoints
	JPS::Position a, b, c, d; // some waypoints
	search.findPath(path, a, b);
	search.findPath(path, b, c);
	search.findPath(path, c, d);

	if(!search.findPath(path2, JPS::Pos(startx, starty), JPS::Pos(endx, endy), step))
	{
		// ...handle failure...
	}
	// ... more stuff happening ...

	// At convenient times, you can clean up accumulated nodes to reclaim memory.
	// This is never necessary, but performance will drop if too many cached nodes exist.
	if(mapWasReloaded)
		search.freeMemory();
}

// Further remarks about the super lazy single-call function can be found at the bottom of this file.

// -------------------------------
// --- Incremental pathfinding ---
// -------------------------------

First, call findPathInit(Position start, Position end). Don't forget to check the return value,
as it may return NO_PATH if one or both of the points are obstructed,
or FOUND_PATH if the points are equal and not obstructed.
If it returns NEED_MORE_STEPS then the next part can start.

Repeatedly call findPathStep(int limit) until it returns NO_PATH or FOUND_PATH.
For consistency, you will want to ensure that the grid does not change between subsequent calls;
if the grid changes, parts of the path may go through a now obstructed area.
If limit is 0, it will perform the pathfinding in one go. Values > 0 abort the search
as soon as possible after the number of steps was exceeded, returning NEED_MORE_STEPS.
Use getStepsDone() after some test runs to find a good value for the limit.

Lastly, generate the actual path points from a successful run via findPathFinish(PathVector& path, unsigned step = 0).
Like described above, path points are appended, and granularity can be adjusted with the step parameter.
Returns false if the pathfinding did not finish or generating the path failed.

*/


#include <stdlib.h>
#include <algorithm>
#include <vector>
#include <map>
#include <cmath>

#ifdef _DEBUG
#include <cassert>
#define JPS_ASSERT(cond) assert(cond)
#else
#define JPS_ASSERT(cond)
#endif


namespace JPS {

enum Result
{
	NO_PATH = 0,
	FOUND_PATH = 1,
	NEED_MORE_STEPS = 2
};

struct Position
{
	unsigned x, y;

	inline bool operator==(const Position& p) const
	{
		return x == p.x && y == p.y;
	}
	inline bool operator!=(const Position& p) const
	{
		return x != p.x || y != p.y;
	}

	// for sorting
	inline bool operator<(const Position& p) const
	{
		return y < p.y || (y == p.y && x < p.x);
	}

	inline bool isValid() const { return x != unsigned(-1); }
};

typedef std::vector<Position> PathVector;

// ctor function to keep Position a real POD struct.
inline static Position Pos(unsigned x, unsigned y)
{
	Position p;
	p.x = x;
	p.y = y;
	return p;
}

namespace Internal {

static const Position npos = Pos(-1, -1);

class Node
{
public:
	Node(const Position& p) : f(0), g(0), pos(p), parent(0), flags(0) {}
	unsigned f, g;
	const Position pos;
	const Node *parent;

	inline void setOpen() { flags |= 1; }
	inline void setClosed() { flags |= 2; }
	inline unsigned char isOpen() const { return flags & 1; }
	inline unsigned char isClosed() const { return flags & 2; }
	inline void clearState() { f = 0; g = 0, parent = 0; flags = 0; }

private:
	unsigned char flags;

	bool operator==(const Node& o); // not implemented, nodes should not be compared
};
} // end namespace Internal

namespace Heuristic
{
	inline unsigned Manhattan(const Internal::Node *a, const Internal::Node *b)
	{
		return abs(int(a->pos.x - b->pos.x)) + abs(int(a->pos.y - b->pos.y));
	}

	inline unsigned Euclidean(const Internal::Node *a, const Internal::Node *b)
	{
		float fx = float(int(a->pos.x - b->pos.x));
		float fy = float(int(a->pos.y - b->pos.y));
		return unsigned(int(sqrtf(fx*fx + fy*fy)));
	}
} // end namespace heuristic

namespace Internal {

typedef std::vector<Node*> NodeVector;

class OpenList
{
public:
	inline void push(Node *node)
	{
		JPS_ASSERT(node);
		nodes.push_back(node);
		std::push_heap(nodes.begin(), nodes.end(), _compare);
	}
	inline Node *pop()
	{
		std::pop_heap(nodes.begin(), nodes.end(), _compare);
		Node *node = nodes.back();
		nodes.pop_back();
		return node;
	}
	inline bool empty() const
	{
		return nodes.empty();
	}
	inline void clear()
	{
		nodes.clear();
	}
	inline void fixup(const Node *item)
	{
		std::make_heap(nodes.begin(), nodes.end(), _compare);
	}

protected:
	static inline bool _compare(const Node *a, const Node *b)
	{
		return a->f > b->f;
	}
	NodeVector nodes;
};

template <typename GRID> class Searcher
{
public:
	Searcher(const GRID& g)
		: grid(g), endNode(NULL), skip(1), stepsRemain(0), stepsDone(0)
	{}

	// single-call
	bool findPath(PathVector& path, Position start, Position end, unsigned step = 0);

	// incremental pathfinding
	Result findPathInit(Position start, Position end);
	Result findPathStep(int limit);
	bool findPathFinish(PathVector& path, unsigned step = 0);

	// misc
	void freeMemory();
	inline void setSkip(int s) { skip = std::max(1, s); }
	inline size_t getStepsDone() const { return stepsDone; }
	inline size_t getNodesExpanded() const { return nodegrid.size(); }

private:

	typedef std::map<Position, Node> NodeGrid;

	const GRID& grid;
	Node *endNode;
	int skip;
	int stepsRemain;
	size_t stepsDone;
	OpenList open;

	NodeGrid nodegrid;

	Node *getNode(const Position& pos);
	void identifySuccessors(const Node *n);
	unsigned findNeighbors(const Node *n, Position *wptr) const;
	Position jumpP(const Position& p, const Position& src);
	Position jumpD(Position p, int dx, int dy);
	Position jumpX(Position p, int dx);
	Position jumpY(Position p, int dy);
	bool generatePath(PathVector& path, unsigned step) const;
#ifdef JPS_VERIFY
	Position jumpPRec(const Position& p, const Position& src) const;
#endif
};

template <typename GRID> inline Node *Searcher<GRID>::getNode(const Position& pos)
{
	JPS_ASSERT(grid(pos.x, pos.y));
	return &nodegrid.insert(std::make_pair(pos, Node(pos))).first->second;
}

template <typename GRID> Position Searcher<GRID>::jumpP(const Position &p, const Position& src)
{
	JPS_ASSERT(grid(p.x, p.y));

	int dx = int(p.x - src.x);
	int dy = int(p.y - src.y);
	JPS_ASSERT(dx || dy);

	if(dx && dy)
		return jumpD(p, dx, dy);
	else if(dx)
		return jumpX(p, dx);
	else if(dy)
		return jumpY(p, dy);

	// not reached
	JPS_ASSERT(false);
	return npos;
}

template <typename GRID> Position Searcher<GRID>::jumpD(Position p, int dx, int dy)
{
	JPS_ASSERT(grid(p.x, p.y));
	JPS_ASSERT(dx && dy);

	const Position& endpos = endNode->pos;
	int steps = 0;

	while(true)
	{
		if(p == endpos)
			break;

		++steps;
		const unsigned x = p.x;
		const unsigned y = p.y;

		if( (grid(x-dx, y+dy) && !grid(x-dx, y)) || (grid(x+dx, y-dy) && !grid(x, y-dy)) )
			break;

		const bool gdx = grid(x+dx, y);
		const bool gdy = grid(x, y+dy);

		if(gdx && jumpX(Pos(x+dx, y), dx).isValid())
			break;

		if(gdy && jumpY(Pos(x, y+dy), dy).isValid())
			break;

		if((gdx || gdy) && grid(x+dx, y+dy))
		{
			p.x += dx;
			p.y += dy;
		}
		else
		{
			p = npos;
			break;
		}
	}
	stepsDone += (unsigned)steps;
	stepsRemain -= steps;
	return p;
}

template <typename GRID> inline Position Searcher<GRID>::jumpX(Position p, int dx)
{
	JPS_ASSERT(dx);
	JPS_ASSERT(grid(p.x, p.y));

	const unsigned y = p.y;
	const Position& endpos = endNode->pos;
	const int skip = this->skip;
	int steps = 0;

	unsigned a = ~((!!grid(p.x, y+skip)) | ((!!grid(p.x, y-skip)) << 1));

	while(true)
	{
		const unsigned xx = p.x + dx;
		const unsigned b = (!!grid(xx, y+skip)) | ((!!grid(xx, y-skip)) << 1);

		if((b & a) || p == endpos)
			break;
		if(!grid(xx, y))
		{
			p = npos;
			break;
		}

		p.x += dx;
		a = ~b;
		++steps;
	}

	stepsDone += (unsigned)steps;
	stepsRemain -= steps;
	return p;
}

template <typename GRID> inline Position Searcher<GRID>::jumpY(Position p, int dy)
{
	JPS_ASSERT(dy);
	JPS_ASSERT(grid(p.x, p.y));

	const unsigned x = p.x;
	const Position& endpos = endNode->pos;
	const int skip = this->skip;
	int steps = 0;

	unsigned a = ~((!!grid(x+skip, p.y)) | ((!!grid(x-skip, p.y)) << 1));

	while(true)
	{
		const unsigned yy = p.y + dy;
		const unsigned b = (!!grid(x+skip, yy)) | ((!!grid(x-skip, yy)) << 1);

		if((a & b) || p == endpos)
			break;
		if(!grid(x, yy))
		{
			p = npos;
			break;
		}

		p.y += dy;
		a = ~b;
	}

	stepsDone += (unsigned)steps;
	stepsRemain -= steps;
	return p;
}

#ifdef JPS_VERIFY
// Recursive reference implementation -- for comparison only
template <typename GRID> Position Searcher<GRID>::jumpPRec(const Position& p, const Position& src) const
{
	unsigned x = p.x;
	unsigned y = p.y;
	if(!grid(x, y))
		return npos;
	if(p == endNode->pos)
		return p;

	int dx = int(x - src.x);
	int dy = int(y - src.y);
	JPS_ASSERT(dx || dy);

	if(dx && dy)
	{
		if( (grid(x-dx, y+dy) && !grid(x-dx, y)) || (grid(x+dx, y-dy) && !grid(x, y-dy)) )
			return p;
	}
	else if(dx)
	{
		if( (grid(x+dx, y+skip) && !grid(x, y+skip)) || (grid(x+dx, y-skip) && !grid(x, y-skip)) )
			return p;
	}
	else if(dy)
	{
		if( (grid(x+skip, y+dy) && !grid(x+skip, y)) || (grid(x-skip, y+dy) && !grid(x-skip, y)) )
			return p;
	}

	if(dx && dy)
	{
		if(jumpPRec(Pos(x+dx, y), p).isValid())
			return p;
		if(jumpPRec(Pos(x, y+dy), p).isValid())
			return p;
	}

	if(grid(x+dx, y) || grid(x, y+dy))
		return jumpPRec(Pos(x+dx, y+dy), p);

	return npos;
}
#endif

template <typename GRID> unsigned Searcher<GRID>::findNeighbors(const Node *n, Position *wptr) const
{
	Position *w = wptr;
	const unsigned x = n->pos.x;
	const unsigned y = n->pos.y;

#define JPS_CHECKGRID(dx, dy) (grid(x+(dx), y+(dy)))
#define JPS_ADDPOS(dx, dy) 	do { *w++ = Pos(x+(dx), y+(dy)); } while(0)
#define JPS_ADDPOS_CHECK(dx, dy) do { if(JPS_CHECKGRID(dx, dy)) JPS_ADDPOS(dx, dy); } while(0)
#define JPS_ADDPOS_NO_TUNNEL(dx, dy) do { if(grid(x+(dx),y) || grid(x,y+(dy))) JPS_ADDPOS_CHECK(dx, dy); } while(0)

	if(!n->parent)
	{
		// straight moves
		JPS_ADDPOS_CHECK(-skip, 0);
		JPS_ADDPOS_CHECK(0, -skip);
		JPS_ADDPOS_CHECK(0, skip);
		JPS_ADDPOS_CHECK(skip, 0);

		// diagonal moves + prevent tunneling
		JPS_ADDPOS_NO_TUNNEL(-skip, -skip);
		JPS_ADDPOS_NO_TUNNEL(-skip, skip);
		JPS_ADDPOS_NO_TUNNEL(skip, -skip);
		JPS_ADDPOS_NO_TUNNEL(skip, skip);

		return unsigned(w - wptr);
	}

	// jump directions (both -1, 0, or 1)
	int dx = int(x - n->parent->pos.x);
	dx /= std::max(abs(dx), 1);
	dx *= skip;
	int dy = int(y - n->parent->pos.y);
	dy /= std::max(abs(dy), 1);
	dy *= skip;

	if(dx && dy)
	{
		// diagonal
		// natural neighbors
		bool walkX = false;
		bool walkY = false;
		if((walkX = grid(x+dx, y)))
			*w++ = Pos(x+dx, y);
		if((walkY = grid(x, y+dy)))
			*w++ = Pos(x, y+dy);

		if(walkX || walkY)
			JPS_ADDPOS_CHECK(dx, dy);

		// forced neighbors
		if(walkY && !JPS_CHECKGRID(-dx,0))
			JPS_ADDPOS_CHECK(-dx, dy);

		if(walkX && !JPS_CHECKGRID(0,-dy))
			JPS_ADDPOS_CHECK(dx, -dy);
	}
	else if(dx)
	{
		// along X axis
		if(JPS_CHECKGRID(dx, 0))
		{
			JPS_ADDPOS(dx, 0);

			 // Forced neighbors (+ prevent tunneling)
			if(!JPS_CHECKGRID(0, skip))
				JPS_ADDPOS_CHECK(dx, skip);
			if(!JPS_CHECKGRID(0,-skip))
				JPS_ADDPOS_CHECK(dx,-skip);
		}


	}
	else if(dy)
	{
		// along Y axis
		if(JPS_CHECKGRID(0, dy))
		{
			JPS_ADDPOS(0, dy);

			// Forced neighbors (+ prevent tunneling)
			if(!JPS_CHECKGRID(skip, 0))
				JPS_ADDPOS_CHECK(skip, dy);
			if(!JPS_CHECKGRID(-skip, 0))
				JPS_ADDPOS_CHECK(-skip,dy);
		}
	}
#undef JPS_ADDPOS
#undef JPS_ADDPOS_CHECK
#undef JPS_ADDPOS_NO_TUNNEL
#undef JPS_CHECKGRID

	return unsigned(w - wptr);
}

template <typename GRID> void Searcher<GRID>::identifySuccessors(const Node *n)
{
	Position buf[8];
	const int num = findNeighbors(n, &buf[0]);
	for(int i = num-1; i >= 0; --i)
	{
		// Invariant: A node is only a valid neighbor if the corresponding grid position is walkable (asserted in jumpP)
		Position jp = jumpP(buf[i], n->pos);
#ifdef JPS_VERIFY
		JPS_ASSERT(jp == jumpPRec(buf[i], n->pos));
#endif
		if(!jp.isValid())
			continue;

		// Now that the grid position is definitely a valid jump point, we have to create the actual node.
		Node *jn = getNode(jp);
		JPS_ASSERT(jn && jn != n);
		if(!jn->isClosed())
		{
			unsigned extraG = Heuristic::Euclidean(jn, n);
			unsigned newG = n->g + extraG;
			if(!jn->isOpen() || newG < jn->g)
			{
				jn->g = newG;
				jn->f = jn->g + Heuristic::Manhattan(jn, endNode);
				jn->parent = n;
				if(!jn->isOpen())
				{
					open.push(jn);
					jn->setOpen();
				}
				else
					open.fixup(jn);
			}
		}
	}
}

template <typename GRID> bool Searcher<GRID>::generatePath(PathVector& path, unsigned step) const
{
	if(!endNode)
		return false;
	size_t offset = path.size();
	if(step)
	{
		const Node *next = endNode;
		const Node *prev = endNode->parent;
		if(!prev)
			return false;
		do
		{
			const unsigned x = next->pos.x, y = next->pos.y;
			int dx = int(prev->pos.x - x);
			int dy = int(prev->pos.y - y);
			JPS_ASSERT(!dx || !dy || abs(dx) == abs(dy)); // known to be straight, if diagonal
			const int steps = std::max(abs(dx), abs(dy));
			dx /= std::max(abs(dx), 1);
			dy /= std::max(abs(dy), 1);
			dx *= int(step);
			dy *= int(step);
			int dxa = 0, dya = 0;
			for(int i = 0; i < steps; i += step)
			{
				path.push_back(Pos(x+dxa, y+dya));
				dxa += dx;
				dya += dy;
			}
			next = prev;
			prev = prev->parent;
		}
		while (prev);
	}
	else
	{
		const Node *next = endNode;
		if(!next->parent)
			return false;
		do
		{
			path.push_back(next->pos);
			next = next->parent;
		}
		while (next->parent);
	}
	// std::reverse(path.begin() + offset, path.end());
	return true;
}

template <typename GRID> bool Searcher<GRID>::findPath(PathVector& path, Position start, Position end, unsigned step /* = 0 */)
{
	Result res = findPathInit(start, end);

	// If this is true, the resulting path is empty (findPathFinish() would fail, so this needs to be checked before)
	if(res == FOUND_PATH)
		return true;

	while(true)
	{
		switch(res)
		{
			case NEED_MORE_STEPS:
				res = findPathStep(0);
				break; // the switch

			case FOUND_PATH:
				return findPathFinish(path, step);

			case NO_PATH:
			default:
				return false;
		}
	}
}

template <typename GRID> Result Searcher<GRID>::findPathInit(Position start, Position end)
{
	for(NodeGrid::iterator it = nodegrid.begin(); it != nodegrid.end(); ++it)
		it->second.clearState();
	open.clear();
	endNode = NULL;
	stepsDone = 0;

	// If skip is > 1, make sure the points are aligned so that the search will always hit them
	start.x = (start.x / skip) * skip;
	start.y = (start.y / skip) * skip;
	end.x = (end.x / skip) * skip;
	end.y = (end.y / skip) * skip;

	if(start == end)
	{
		// There is only a path if this single position is walkable.
		// But since the starting position is omitted, there is nothing to do here.
		return grid(end.x, end.y) ? FOUND_PATH : NO_PATH;
	}

	// If start or end point are obstructed, don't even start
	if(!grid(start.x, start.y) || !grid(end.x, end.y))
		return NO_PATH;

	open.push(getNode(start));
	endNode = getNode(end);
	JPS_ASSERT(endNode);

	return NEED_MORE_STEPS;
}

template <typename GRID> Result Searcher<GRID>::findPathStep(int limit)
{
	stepsRemain = limit;
	do
	{
		if(open.empty())
			return NO_PATH;
		Node *n = open.pop();
		n->setClosed();
		if(n == endNode)
			return FOUND_PATH;
		identifySuccessors(n);
	}
	while(stepsRemain >= 0);
	return NEED_MORE_STEPS;
}

template<typename GRID> bool Searcher<GRID>::findPathFinish(PathVector& path, unsigned step /* = 0 */)
{
	return generatePath(path, step);
}

template<typename GRID> void Searcher<GRID>::freeMemory()
{
	NodeGrid v;
	nodegrid.swap(v);
	endNode = NULL;
	open.clear();
	// other containers known to be empty.
}

} // end namespace Internal

using Internal::Searcher;

// Single-call convenience function
//
// path: If the function returns true, the path is stored in this vector.
//       The path does NOT contain the starting position, i.e. if start and end are the same,
//       the resulting path has no elements.
//       The vector does not have to be empty. The function does not clear it;
//       instead, the new path positions are appended at the end.
//       This allows building a path incrementally.
//
// grid: expected to overload operator()(x, y), return true if position is walkable, false if not.
//
// step: If 0, only return waypoints.
//       If 1, create exhaustive step-by-step path.
//       If N, put in one position for N blocks travelled, or when a waypoint is hit.
//       All returned points are guaranteed to be on a straight line (vertically, horizontally, or diagonally),
//       and there is no obstruction between any two consecutive points.
//       Note that this parameter does NOT influence the pathfinding in any way;
//       it only controls the coarseness of the output path.
//
// skip: If you know your map data well enough, this can be set to > 1 to speed up pathfinding even more.
//       Warning: Start and end positions will be rounded down to the nearest <skip>-aligned position,
//       so make sure to give appropriate positions so they do not end up in a wall.
//       This will also skip through walls if they are less than <skip> blocks thick at any reachable position.
template <typename GRID> bool findPath(PathVector& path, const GRID& grid, unsigned startx, unsigned starty, unsigned endx, unsigned endy,
                                       unsigned step = 0, int skip = 0, // optional params
                                       size_t *stepsDone = NULL, size_t *nodesExpanded = NULL // for information
                                       )
{
	Searcher<GRID> search(grid);
	search.setSkip(skip);
	bool found = search.findPath(path, Pos(startx, starty), Pos(endx, endy), step);
	if(stepsDone)
		*stepsDone = search.getStepsDone();
	if(nodesExpanded)
		*nodesExpanded = search.getNodesExpanded();
	return found;
}



} // end namespace JPS


#endif
