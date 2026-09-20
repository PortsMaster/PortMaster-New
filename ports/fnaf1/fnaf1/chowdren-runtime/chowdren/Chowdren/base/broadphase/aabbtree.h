/*
* Copyright (c) 2009 Erin Catto http://www.box2d.org
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

/*
This is a fork from Box2D, changed for use in Chowdren
*/

#ifndef CHOW_DYNAMIC_TREE_H
#define CHOW_DYNAMIC_TREE_H

#include "broadphase/growablestack.h"
#include "broadphase/common.h"

#define chow_nullNode (-1)

struct TreeNode
{
    bool IsLeaf() const
    {
        return child1 == chow_nullNode;
    }

    /// Enlarged AABB
    AABB aabb;

    void* userData;

    union
    {
        int32 parent;
        int32 next;
    };

    int32 child1;
    int32 child2;

    // leaf = 0, free node = -1
    int32 height;
};

class AABBTree
{
public:
    AABBTree();
    ~AABBTree();
    int32 CreateProxy(const AABB& aabb, void* userData);
    void remove(int32 proxyId);
    void clear();
    bool MoveProxy(int32 proxyId, const AABB& aabb1,
                   const chowVec2& displacement);
    void* GetUserData(int32 proxyId) const;
    const AABB& GetFatAABB(int32 proxyId) const;

    int32 add(void * data, int v[4]);
    bool move(int32 proxy, int v[4]);

    template <typename T>
    bool query(int v[4], T & callback) const;

    template <typename T>
    bool query(int proxy, T & callback) const;

    template <typename T>
    bool query(const AABB & aabb, T & callback) const;

    template <typename T>
    bool query_ids(int v[4], T & callback) const;

    template <typename T>
    bool query_ids(int proxy, T & callback) const;

    template <typename T>
    bool query_ids(const AABB & aabb, T & callback) const;

    /// Validate this tree. For testing.
    void Validate() const;

    /// Compute the height of the binary tree in O(N) time. Should not be
    /// called often.
    int32 GetHeight() const;

    /// Get the maximum balance of an node in the tree. The balance is the difference
    /// in height of the two children of a node.
    int32 GetMaxBalance() const;

    /// Get the ratio of the sum of the node areas to the root area.
    int32 GetAreaRatio() const;

    /// Build an optimal tree. Very expensive. For testing.
    void RebuildBottomUp();

    /// Shift the world origin. Useful for large worlds.
    /// The shift formula is: position -= newOrigin
    /// @param newOrigin the new origin with respect to the old origin
    void shift(const chowVec2& newOrigin);
    void shift(int x, int y);

private:
    int32 AllocateNode();
    void FreeNode(int32 node);
    void InsertLeaf(int32 node);
    void RemoveLeaf(int32 node);
    int32 Balance(int32 index);
    int32 ComputeHeight() const;
    int32 ComputeHeight(int32 nodeId) const;
    void ValidateStructure(int32 index) const;
    void ValidateMetrics(int32 index) const;

    int32 m_root;

    TreeNode* m_nodes;
    int32 m_nodeCount;
    int32 m_nodeCapacity;

    int32 m_freeList;

    /// This is used to incrementally traverse the tree for re-balancing.
    uint32 m_path;

    int32 m_insertionCount;
};

inline void* AABBTree::GetUserData(int32 proxyId) const
{
    chowAssert(0 <= proxyId && proxyId < m_nodeCapacity);
    return m_nodes[proxyId].userData;
}

inline const AABB& AABBTree::GetFatAABB(int32 proxyId) const
{
    chowAssert(0 <= proxyId && proxyId < m_nodeCapacity);
    return m_nodes[proxyId].aabb;
}

template <typename T>
inline bool AABBTree::query(const AABB& aabb, T & callback) const
{
    GrowableStack<int32, 256> stack;
    stack.Push(m_root);

    while (stack.GetCount() > 0) {
        int32 nodeId = stack.Pop();
        if (nodeId == chow_nullNode) {
            continue;
        }

        const TreeNode* node = m_nodes + nodeId;

        if (chowTestOverlap(node->aabb, aabb)) {
            if (node->IsLeaf()) {
                bool proceed = callback.on_callback(m_nodes[nodeId].userData);
                if (proceed == false) {
                    return false;
                }
            } else {
                stack.Push(node->child1);
                stack.Push(node->child2);
            }
        }
    }
    return true;
}

template <typename T>
inline bool AABBTree::query(int v[4], T & callback) const
{
    AABB aabb = {chowVec2(v[0], v[1]), chowVec2(v[2], v[3])};
    return query(aabb, callback);
}

template <typename T>
inline bool AABBTree::query(int proxy, T & callback) const
{
    const AABB & aabb = GetFatAABB(proxy);
    return query(aabb, callback);
}

template <typename T>
inline bool AABBTree::query_ids(const AABB& aabb, T & callback) const
{
    GrowableStack<int32, 256> stack;
    stack.Push(m_root);

    while (stack.GetCount() > 0) {
        int32 nodeId = stack.Pop();
        if (nodeId == chow_nullNode) {
            continue;
        }

        const TreeNode* node = m_nodes + nodeId;

        if (chowTestOverlap(node->aabb, aabb)) {
            if (node->IsLeaf()) {
                bool proceed = callback.on_callback(nodeId);
                if (proceed == false) {
                    return false;
                }
            } else {
                stack.Push(node->child1);
                stack.Push(node->child2);
            }
        }
    }
    return true;
}

template <typename T>
inline bool AABBTree::query_ids(int v[4], T & callback) const
{
    AABB aabb = {chowVec2(v[0], v[1]), chowVec2(v[2], v[3])};
    return query_ids(aabb, callback);
}

template <typename T>
inline bool AABBTree::query_ids(int proxy, T & callback) const
{
    const AABB & aabb = GetFatAABB(proxy);
    return query_ids(aabb, callback);
}

#endif
