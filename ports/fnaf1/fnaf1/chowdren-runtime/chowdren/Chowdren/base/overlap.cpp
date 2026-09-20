#include "frameobject.h"
#include "bitarray.h"

// XXX move this into gencol.py

// FrameObject vs FrameObject

template <bool save>
inline bool overlap_impl(FrameObject * obj1, FrameObject * obj2)
{
    if (!obj1->overlaps(obj2))
        return false;
    if (!save)
        return true;
    if (obj1->movement != NULL)
        obj1->movement->add_collision(obj2);
    if (obj2->movement != NULL)
        obj2->movement->add_collision(obj1);
    return true;
}

// ObjectList vs ObjectList

template <bool save>
inline bool overlap_impl(ObjectList & list1, ObjectList & list2)
{
    int size = list2.size();
    if (size <= 0)
        return false;

    StackBitArray temp = CREATE_BITARRAY_ZERO(size);

    bool ret = false;
    for (ObjectIterator it1(list1); !it1.end(); ++it1) {
        FrameObject * instance = *it1;
        InstanceCollision * col = instance->collision;
        if (col == NULL) {
            it1.deselect();
            continue;
        }
        bool added = false;
        for (ObjectIterator it2(list2); !it2.end(); ++it2) {
            FrameObject * other = *it2;
            if (other->collision == NULL) {
                it2.deselect();
                continue;
            }
            if (!overlap_impl<save>(instance, other))
                continue;
            temp.set(it2.index-1);
            added = ret = true;
        }
        if (!added)
            it1.deselect();
    }

    if (!ret)
        return false;

    for (ObjectIterator it(list2); !it.end(); ++it) {
        if (!temp.get(it.index-1))
            it.deselect();
    }

    return true;
}

// FrameObject vs ObjectList

template <bool save>
inline bool overlap_impl(FrameObject * obj, ObjectList & list)
{
    int size = list.size();
    if (size <= 0)
        return false;

    CollisionBase * col = obj->collision;
    if (col == NULL)
        return false;

    bool ret = false;
    for (ObjectIterator it(list); !it.end(); ++it) {
        FrameObject * other = *it;
        if (other->collision == NULL) {
            it.deselect();
            continue;
        }
        if (!overlap_impl<save>(obj, other)) {
            it.deselect();
            continue;
        }
        ret = true;
    }

    return ret;
}

template <bool save>
inline bool overlap_impl(ObjectList & list, FrameObject * obj)
{
    int size = list.size();
    if (size <= 0)
        return false;

    CollisionBase * col = obj->collision;
    if (col == NULL)
        return false;

    bool ret = false;
    for (ObjectIterator it(list); !it.end(); ++it) {
        FrameObject * other = *it;
        if (other->collision == NULL) {
            it.deselect();
            continue;
        }
        if (!overlap_impl<save>(other, obj)) {
            it.deselect();
            continue;
        }
        ret = true;
    }

    return ret;
}

// QualifierList vs ObjectList

template <bool save>
inline bool overlap_impl(QualifierList & list1, ObjectList & list2)
{
    int size = list1.size();
    if (size <= 0)
        return false;
    StackBitArray temp = CREATE_BITARRAY_ZERO(size);

    bool ret = false;
    for (ObjectIterator it1(list2); !it1.end(); ++it1) {
        FrameObject * instance = *it1;
        if (instance->collision == NULL) {
            it1.deselect();
            continue;
        }
        bool added = false;
        int temp_offset = 0;
        for (int i = 0; i < list1.count; i++) {
            ObjectList & list = *list1.items[i];
            for (ObjectIterator it2(list); !it2.end(); ++it2) {
                FrameObject * other = *it2;
                if (other->collision == NULL) {
                    it2.deselect();
                    continue;
                }
                if (!overlap_impl<save>(other, instance))
                    continue;
                added = ret = true;
                temp.set(temp_offset + it2.index - 1);
            }
            temp_offset += list.size();
        }
        if (!added)
            it1.deselect();
    }

    if (!ret)
        return false;

    int total_index = 0;
    for (int i = 0; i < list1.count; i++) {
        ObjectList & list = *list1.items[i];
        for (ObjectIterator it(list); !it.end(); ++it) {
            if (!temp.get(total_index + it.index - 1))
                it.deselect();
        }
        total_index += list.size();
    }

    return true;
}

template <bool save>
inline bool overlap_impl(ObjectList & list1, QualifierList & list2)
{
    int size = list2.size();
    if (size <= 0)
        return false;
    StackBitArray temp = CREATE_BITARRAY_ZERO(size);

    bool ret = false;
    for (ObjectIterator it1(list1); !it1.end(); ++it1) {
        FrameObject * instance = *it1;
        if (instance->collision == NULL) {
            it1.deselect();
            continue;
        }
        bool added = false;
        int temp_offset = 0;
        for (int i = 0; i < list2.count; i++) {
            ObjectList & list = *list2.items[i];
            for (ObjectIterator it2(list); !it2.end(); ++it2) {
                FrameObject * other = *it2;
                if (other->collision == NULL) {
                    it2.deselect();
                    continue;
                }
                if (!overlap_impl<save>(instance, other))
                    continue;
                added = ret = true;
                temp.set(temp_offset + it2.index - 1);
            }
            temp_offset += list.size();
        }
        if (!added)
            it1.deselect();
    }

    if (!ret)
        return false;

    int total_index = 0;
    for (int i = 0; i < list2.count; i++) {
        ObjectList & list = *list2.items[i];
        for (ObjectIterator it(list); !it.end(); ++it) {
            if (!temp.get(total_index + it.index - 1))
                it.deselect();
        }
        total_index += list.size();
    }

    return true;
}

// FrameObject vs QualifierList

template <bool save>
inline bool overlap_impl(FrameObject * obj, QualifierList & list)
{
    int size = list.size();
    if (size <= 0)
        return false;

    if (obj->collision == NULL)
        return false;

    bool ret = false;
    int temp_offset = 0;
    for (int i = 0; i < list.count; i++) {
        ObjectList & list2 = *list.items[i];
        for (ObjectIterator it(list2); !it.end(); ++it) {
            FrameObject * other = *it;
            if (other->collision == NULL) {
                it.deselect();
                continue;
            }
            if (!overlap_impl<save>(obj, other)) {
                it.deselect();
                continue;
            }
            ret = true;
        }
    }

    return ret;
}

template <bool save>
inline bool overlap_impl(QualifierList & list, FrameObject * obj)
{
    int size = list.size();
    if (size <= 0)
        return false;

    if (obj->collision == NULL)
        return false;

    bool ret = false;
    int temp_offset = 0;
    for (int i = 0; i < list.count; i++) {
        ObjectList & list2 = *list.items[i];
        for (ObjectIterator it(list2); !it.end(); ++it) {
            FrameObject * other = *it;
            if (other->collision == NULL) {
                it.deselect();
                continue;
            }
            if (!overlap_impl<save>(other, obj)) {
                it.deselect();
                continue;
            }
            ret = true;
        }
    }

    return ret;
}

// QualifierList vs QualifierList

template <bool save>
inline bool overlap_impl(QualifierList & list1, QualifierList & list2)
{
    int size = list1.size();
    if (size <= 0)
        return false;
    StackBitArray temp = CREATE_BITARRAY_ZERO(size);

    bool ret = false;
    for (QualifierIterator it1(list2); !it1.end(); ++it1) {
        FrameObject * instance = *it1;
        if (instance->collision == NULL) {
            it1.deselect();
            continue;
        }
        bool added = false;

        int temp_offset = 0;
        for (int i = 0; i < list1.count; i++) {
            ObjectList & list = *list1.items[i];
            for (ObjectIterator it2(list); !it2.end(); ++it2) {
                FrameObject * other = *it2;
                if (other->collision == NULL) {
                    it2.deselect();
                    continue;
                }
                if (!overlap_impl<save>(other, instance))
                    continue;
                added = ret = true;
                temp.set(temp_offset + it2.index - 1);
            }
            temp_offset += list.size();
        }
        if (!added)
            it1.deselect();
    }

    if (!ret)
        return false;

    int total_index = 0;
    for (int i = 0; i < list1.count; i++) {
        ObjectList & list = *list1.items[i];
        for (ObjectIterator it(list); !it.end(); ++it) {
            if (!temp.get(total_index + it.index - 1))
                it.deselect();
        }
        total_index += list.size();
    }

    return true;
}

// with save

bool check_overlap_save(FrameObject * obj1, FrameObject * obj2)
{
    return overlap_impl<true>(obj1, obj2);
}

bool check_overlap_save(ObjectList & list1, ObjectList & list2)
{
    return overlap_impl<true>(list1, list2);
}

bool check_overlap_save(FrameObject * obj, ObjectList & list)
{
    return overlap_impl<true>(obj, list);
}

bool check_overlap_save(ObjectList & list, FrameObject * obj)
{
    return overlap_impl<true>(list, obj);
}

bool check_overlap_save(QualifierList & list1, ObjectList & list2)
{
    return overlap_impl<true>(list1, list2);
}

bool check_overlap_save(ObjectList & list1, QualifierList & list2)
{
    return overlap_impl<true>(list1, list2);
}

bool check_overlap_save(FrameObject * obj, QualifierList & list)
{
    return overlap_impl<true>(obj, list);
}

bool check_overlap_save(QualifierList & list, FrameObject * obj)
{
    return overlap_impl<true>(list, obj);
}

bool check_overlap_save(QualifierList & list1, QualifierList & list2)
{
    return overlap_impl<true>(list1, list2);
}

// without save

bool check_overlap(FrameObject * obj1, FrameObject * obj2)
{
    return overlap_impl<false>(obj1, obj2);
}

bool check_overlap(ObjectList & list1, ObjectList & list2)
{
    return overlap_impl<false>(list1, list2);
}

bool check_overlap(FrameObject * obj, ObjectList & list)
{
    return overlap_impl<false>(obj, list);
}

bool check_overlap(ObjectList & list, FrameObject * obj)
{
    return overlap_impl<false>(list, obj);
}

bool check_overlap(QualifierList & list1, ObjectList & list2)
{
    return overlap_impl<false>(list1, list2);
}

bool check_overlap(ObjectList & list1, QualifierList & list2)
{
    return overlap_impl<false>(list1, list2);
}

bool check_overlap(FrameObject * obj, QualifierList & list)
{
    return overlap_impl<false>(obj, list);
}

bool check_overlap(QualifierList & list, FrameObject * obj)
{
    return overlap_impl<false>(list, obj);
}

bool check_overlap(QualifierList & list1, QualifierList & list2)
{
    return overlap_impl<false>(list1, list2);
}

// ObjectList vs ObjectList

bool check_not_overlap_impl(ObjectList & list1, ObjectList & list2,
                            bool & checked)
{
    for (ObjectIterator it1(list1); !it1.end(); ++it1) {
        FrameObject * instance = *it1;
        if (instance->collision == NULL)
            continue;
        ObjectList::iterator it2;
        for (it2 = list2.begin(); it2 != list2.end(); ++it2) {
            checked = true;
            FrameObject * other = it2->obj;
            if (!instance->overlaps(other))
                continue;
            return false;
        }
    }
    return true;
}

bool check_not_overlap(ObjectList & list1, ObjectList & list2)
{
    bool checked = false;
    if (!check_not_overlap_impl(list1, list2, checked))
        return false;
    return checked;
}

// QualifierList vs ObjectList

bool check_not_overlap(QualifierList & list1, ObjectList & list2)
{
    bool checked = false;
    for (int i = 0; i < list1.count; i++) {
        if (!check_not_overlap_impl(*list1.items[i], list2, checked))
            return false;
    }
    return checked;
}

bool check_not_overlap(ObjectList & list1, QualifierList & list2)
{
    bool checked = false;
    for (int i = 0; i < list2.count; i++) {
        if (!check_not_overlap_impl(list1, *list2.items[i], checked))
            return false;
    }
    return checked;
}

// QualifierList vs QualifierList

bool check_not_overlap(QualifierList & list1, QualifierList & list2)
{
    bool checked = false;
    for (int i = 0; i < list1.count; i++) {
        for (int ii = 0; ii < list2.count; ii++) {
            if (!check_not_overlap_impl(*list1.items[i], *list2.items[ii],
                                        checked))
                return false;
        }
    }
    return checked;
}

// FrameObject vs ObjectList

bool check_not_overlap(FrameObject * obj, ObjectList & list)
{
    CollisionBase * col = obj->collision;
    if (col == NULL)
        return true;
    ObjectList::iterator it;
    bool checked = false;
    for (it = list.begin(); it != list.end(); ++it) {
        checked = true;
        FrameObject * other = it->obj;
        if (!obj->overlaps(other))
            continue;
        return false;
    }
    return checked;
}

// FrameObject vs QualifierList

bool check_not_overlap(FrameObject * obj, QualifierList & list)
{
    CollisionBase * col = obj->collision;
    if (col == NULL)
        return true;
    bool checked = false;
    for (int i = 0; i < list.count; i++) {
        ObjectList & list2 = *list.items[i];
        ObjectList::iterator it;
        for (it = list2.begin(); it != list2.end(); ++it) {
            checked = true;
            FrameObject * other = it->obj;
            if (!obj->overlaps(other))
                continue;
            return false;
        }
    }
    return checked;
}

// on collision

class ObjectPairs
{
public:
    int size;
    FrameObject ** buffer;

    ObjectPairs()
    : size(0), buffer(&SavedSelection::buffer[SavedSelection::offset])
    {
    }

    ~ObjectPairs()
    {
        SavedSelection::offset -= size;
        assert(SavedSelection::offset >= 0);
    }

    void add(FrameObject * a, FrameObject * b)
    {
        SavedSelection::buffer[SavedSelection::offset++] = a;
        SavedSelection::buffer[SavedSelection::offset++] = b;
        size += 2;
    }
};

#define FIRE_CALLBACK(pairs, e) \
    for (int i = 0; i < pairs.size; i += 2) {\
        col_instance_1 = pairs.buffer[i];\
        col_instance_2 = pairs.buffer[i+1];\
        (this->*e)();\
    }

void Frame::test_collisions(ObjectList & a, ObjectList & b,
                            int flag1, int flag2, EventFunction e)
{
    StackBitArray temp = CREATE_BITARRAY_ZERO(b.size());
    ObjectPairs pairs;

    ObjectList::iterator it1, it2;
    int index;
    for (it1 = a.begin(); it1 != a.end(); ++it1) {
        FrameObject * col_instance_1 = it1->obj;
#ifndef CHOWDREN_REPEATED_COLLISIONS
        bool has_col = false;
        index = 0;
#endif
        for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
            FrameObject * col_instance_2 = it2->obj;
            if (col_instance_1 == col_instance_2)
                continue;
            if (!check_overlap(col_instance_1, col_instance_2))
                continue;
#ifndef CHOWDREN_REPEATED_COLLISIONS
            has_col = true;
            temp.set(index);
            if ((col_instance_1->collision_flags & flag1) &&
                (col_instance_2->collision_flags & flag2))
                continue;
            col_instance_1->collision_flags |= flag1;
            col_instance_2->collision_flags |= flag2;
#endif
            pairs.add(col_instance_1, col_instance_2);
        }

#ifndef CHOWDREN_REPEATED_COLLISIONS
        if (!has_col)
            col_instance_1->collision_flags &= ~flag1;
#endif
    }

#ifndef CHOWDREN_REPEATED_COLLISIONS
    index = 0;
    for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
        if (temp.get(index))
            continue;
        it2->obj->collision_flags &= ~flag2;
    }
#endif

    FIRE_CALLBACK(pairs, e);
}

void Frame::test_collisions_save(ObjectList & a, ObjectList & b,
                                 int flag1, int flag2, EventFunction e)
{
    StackBitArray temp = CREATE_BITARRAY_ZERO(b.size());
    ObjectPairs pairs;

    ObjectList::iterator it1, it2;
    int index;
    for (it1 = a.begin(); it1 != a.end(); ++it1) {
        FrameObject * col_instance_1 = it1->obj;
#ifndef CHOWDREN_REPEATED_COLLISIONS
        bool has_col = false;
        index = 0;
#endif
        for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
            FrameObject * col_instance_2 = it2->obj;
            if (col_instance_1 == col_instance_2)
                continue;
            if (!check_overlap_save(col_instance_1, col_instance_2))
                continue;
#ifndef CHOWDREN_REPEATED_COLLISIONS
            has_col = true;
            temp.set(index);
            if ((col_instance_1->collision_flags & flag1) &&
                (col_instance_2->collision_flags & flag2))
                continue;
            col_instance_1->collision_flags |= flag1;
            col_instance_2->collision_flags |= flag2;
#endif
            pairs.add(col_instance_1, col_instance_2);
        }

#ifndef CHOWDREN_REPEATED_COLLISIONS
        if (!has_col)
            col_instance_1->collision_flags &= ~flag1;
#endif
    }

#ifndef CHOWDREN_REPEATED_COLLISIONS
    index = 0;
    for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
        if (temp.get(index))
            continue;
        it2->obj->collision_flags &= ~flag2;
    }
#endif

    FIRE_CALLBACK(pairs, e);
}

void Frame::test_collisions(QualifierList & a, ObjectList & b,
                            int flag1, int flag2, EventFunction e)
{
    StackBitArray temp = CREATE_BITARRAY_ZERO(b.size());
    ObjectPairs pairs;

    ObjectList::iterator it1, it2;
    int index;
    for (int i = 0; i < a.count; ++i)
    for (it1 = a.items[i]->begin(); it1 != a.items[i]->end(); ++it1) {
        FrameObject * col_instance_1 = it1->obj;
#ifndef CHOWDREN_REPEATED_COLLISIONS
        bool has_col = false;
        index = 0;
#endif
        for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
            FrameObject * col_instance_2 = it2->obj;
            if (col_instance_1 == col_instance_2)
                continue;
            if (!check_overlap(col_instance_1, col_instance_2))
                continue;
#ifndef CHOWDREN_REPEATED_COLLISIONS
            has_col = true;
            temp.set(index);
            if ((col_instance_1->collision_flags & flag1) &&
                (col_instance_2->collision_flags & flag2))
                continue;
            col_instance_1->collision_flags |= flag1;
            col_instance_2->collision_flags |= flag2;
#endif
            pairs.add(col_instance_1, col_instance_2);
        }

#ifndef CHOWDREN_REPEATED_COLLISIONS
        if (!has_col)
            col_instance_1->collision_flags &= ~flag1;
#endif
    }

#ifndef CHOWDREN_REPEATED_COLLISIONS
    index = 0;
    for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
        if (temp.get(index))
            continue;
        it2->obj->collision_flags &= ~flag2;
    }
#endif

    FIRE_CALLBACK(pairs, e);
}

void Frame::test_collisions_save(QualifierList & a, ObjectList & b,
                                 int flag1, int flag2, EventFunction e)
{
    StackBitArray temp = CREATE_BITARRAY_ZERO(b.size());
    ObjectPairs pairs;

    ObjectList::iterator it1, it2;
    int index;
    for (int i = 0; i < a.count; ++i)
    for (it1 = a.items[i]->begin(); it1 != a.items[i]->end(); ++it1) {
        FrameObject * col_instance_1 = it1->obj;
#ifndef CHOWDREN_REPEATED_COLLISIONS
        bool has_col = false;
        index = 0;
#endif
        for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
            FrameObject * col_instance_2 = it2->obj;
            if (col_instance_1 == col_instance_2)
                continue;
            if (!check_overlap_save(col_instance_1, col_instance_2))
                continue;
#ifndef CHOWDREN_REPEATED_COLLISIONS
            has_col = true;
            temp.set(index);
            if ((col_instance_1->collision_flags & flag1) &&
                (col_instance_2->collision_flags & flag2))
                continue;
            col_instance_1->collision_flags |= flag1;
            col_instance_2->collision_flags |= flag2;
#endif
            pairs.add(col_instance_1, col_instance_2);
        }

#ifndef CHOWDREN_REPEATED_COLLISIONS
        if (!has_col)
            col_instance_1->collision_flags &= ~flag1;
#endif
    }

#ifndef CHOWDREN_REPEATED_COLLISIONS
    index = 0;
    for (it2 = b.begin(); it2 != b.end(); ++it2, ++index) {
        if (temp.get(index))
            continue;
        it2->obj->collision_flags &= ~flag2;
    }
#endif

    FIRE_CALLBACK(pairs, e);
}

void Frame::test_collisions(QualifierList & a, QualifierList & b,
                            int flag1, int flag2, EventFunction e)
{
    StackBitArray temp = CREATE_BITARRAY_ZERO(b.size());
    ObjectPairs pairs;

    ObjectList::iterator it1, it2;
    int index;
    for (int i = 0; i < a.count; ++i)
    for (it1 = a.items[i]->begin(); it1 != a.items[i]->end(); ++it1) {
        FrameObject * col_instance_1 = it1->obj;
#ifndef CHOWDREN_REPEATED_COLLISIONS
        bool has_col = false;
        index = 0;
#endif
        for (int ii = 0; ii < b.count; ++ii)
        for (it2 = b.items[ii]->begin(); it2 != b.items[ii]->end(); ++it2,
                                                                    ++index)
        {
            FrameObject * col_instance_2 = it2->obj;
            if (col_instance_1 == col_instance_2)
                continue;
            if (!check_overlap(col_instance_1, col_instance_2))
                continue;
#ifndef CHOWDREN_REPEATED_COLLISIONS
            has_col = true;
            temp.set(index);
            if ((col_instance_1->collision_flags & flag1) &&
                (col_instance_2->collision_flags & flag2))
                continue;
            col_instance_1->collision_flags |= flag1;
            col_instance_2->collision_flags |= flag2;
#endif
            pairs.add(col_instance_1, col_instance_2);
        }

#ifndef CHOWDREN_REPEATED_COLLISIONS
        if (!has_col)
            col_instance_1->collision_flags &= ~flag1;
#endif
    }

#ifndef CHOWDREN_REPEATED_COLLISIONS
    index = 0;
    for (int i = 0; i < b.count; ++i)
    for (it2 = b.items[i]->begin(); it2 != b.items[i]->end(); ++it2, ++index) {
        if (temp.get(index))
            continue;
        it2->obj->collision_flags &= ~flag2;
    }
#endif

    FIRE_CALLBACK(pairs, e);
}
