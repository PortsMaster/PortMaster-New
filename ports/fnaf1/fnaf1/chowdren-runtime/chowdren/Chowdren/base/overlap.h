#ifndef CHOWDREN_OVERLAP_H
#define CHOWDREN_OVERLAP_H

bool check_overlap(FrameObject * obj1, FrameObject * obj2);
bool check_overlap(ObjectList & list1, ObjectList & list2);
bool check_overlap(FrameObject * obj, ObjectList & list);
bool check_overlap(ObjectList & list, FrameObject * obj);
bool check_overlap(QualifierList & list1, ObjectList & list2);
bool check_overlap(ObjectList & list1, QualifierList & list2);
bool check_overlap(FrameObject * obj, QualifierList & list);
bool check_overlap(QualifierList & list, FrameObject * instance);
bool check_overlap(QualifierList & list1, QualifierList & list2);

bool check_overlap_save(FrameObject * obj1, FrameObject * obj2);
bool check_overlap_save(ObjectList & list1, ObjectList & list2);
bool check_overlap_save(FrameObject * obj, ObjectList & list);
bool check_overlap_save(ObjectList & list, FrameObject * obj);
bool check_overlap_save(QualifierList & list1, ObjectList & list2);
bool check_overlap_save(ObjectList & list1, QualifierList & list2);
bool check_overlap_save(FrameObject * obj, QualifierList & list);
bool check_overlap_save(QualifierList & list, FrameObject * instance);
bool check_overlap_save(QualifierList & list1, QualifierList & list2);

bool check_not_overlap(ObjectList & list1, ObjectList & list2);
bool check_not_overlap(QualifierList & list1, ObjectList & list2);
bool check_not_overlap(ObjectList & list1, QualifierList & list2);
bool check_not_overlap(QualifierList & list1, QualifierList & list2);
bool check_not_overlap(FrameObject * obj, ObjectList & list);
bool check_not_overlap(FrameObject * obj, QualifierList & list);

#endif // CHOWDREN_OVERLAP_H
