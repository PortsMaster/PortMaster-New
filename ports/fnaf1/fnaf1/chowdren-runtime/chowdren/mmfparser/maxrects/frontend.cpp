#include <algorithm>
#include <vector>

inline bool comp(int a, int b)
{
    return a > b;
}

inline void sort_indexes(std::vector<int> & idx)
{
    std::sort(idx.begin(), idx.end(), comp);
}
