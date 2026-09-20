#include <string>
#include <vector>
#include <sstream>
#include <iomanip>
#include <iostream>

#ifdef COXSDK
#include <windows.h>
#include <fstream>
#else
#include "platform.h"
#include "fileio.h"
#endif

class ProfilerEntry
{
public:
    std::string name;
    double start, dt;
};

class Profiler
{
public:
    std::vector<ProfilerEntry> entries;
    std::vector<ProfilerEntry> stack;
    ProfilerEntry current;

#ifdef COXSDK
    double qpc_freq;
    __int64 qpc_start;
#endif

    Profiler()
    {
        init_timer();
    }

    void start(const std::string & name)
    {
        stack.push_back(current);
        current.name = name;
        current.dt = 0.0;
        current.start = get_timer();
    }

    void start_additive(const std::string & name)
    {
        if (name == current.name)
            return;
        std::vector<ProfilerEntry>::iterator it;
        for (it = entries.begin(); it != entries.end(); it++) {
            if (it->name != name)
                continue;
            current = *it;
            entries.erase(it);
            current.start = get_timer();
            return;
        }

        start(name);
    }

    void stop()
    {
        current.dt += get_timer() - current.start;
        entries.push_back(current);
        current = stack.back();
        stack.pop_back();
    }

    void save(const std::string & path)
    {
        std::stringstream ss;
        ss << std::fixed << std::setprecision(15);
        ss << "Profiler results:\n\n";

        std::vector<ProfilerEntry>::iterator it;
        for (it = entries.begin(); it != entries.end(); it++) {
            ss << it->name << ": " << it->dt << " seconds\n\n";
        }
#ifdef COXSDK
        std::ofstream fp(path.c_str());
#else
        FSFile fp(path.c_str(), "w");
#endif
        std::string str = ss.str();

        fp.write(&str[0], str.size());
        fp.close();
    }

#ifdef COXSDK
    void init_timer()
    {
        // just expect that QPC is working
        LARGE_INTEGER li;
        QueryPerformanceFrequency(&li);
        qpc_freq = double(li.QuadPart);
        QueryPerformanceCounter(&li);
        qpc_start = li.QuadPart;
    }

    double get_timer()
    {
        LARGE_INTEGER li;
        QueryPerformanceCounter(&li);
        return double(li.QuadPart - qpc_start) / qpc_freq;
    }
#else
    static void init_timer()
    {
    }

    static double get_timer()
    {
        return platform_get_time();
    }
#endif
};