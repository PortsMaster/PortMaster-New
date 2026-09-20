#include "http.h"
#include <iostream>

// HTTPObject

#ifdef CHOWDREN_IS_DESKTOP

#include "staticlibs/happyhttp/happyhttp.cpp"
static happyhttp::Connection conn;

HTTPObject::HTTPObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), done(false)
{
}

HTTPObject::~HTTPObject()
{
    conn.close();
}

void HTTPObject::add_post(const std::string & name, const std::string & value)
{
    if (args.empty())
        args += name + "=" + value;
    else
        args += "&" + name + "=" + value;
}

#define HTTP_PREFIX "http://"

static void on_data(const happyhttp::Response * r, void * userdata,
                    const unsigned char * data, int n)
{
    ((HTTPObject*)userdata)->value.append((const char *)data, n);
}

static void on_done(const happyhttp::Response * r, void * userdata)
{
    ((HTTPObject*)userdata)->done = true;
}


void HTTPObject::get(const std::string & url)
{
    value.clear();

    const char* headers[] = 
    {
        "Connection", "close",
        "Content-type", "application/x-www-form-urlencoded",
        "Accept", "text/plain",
        0
    };

    int start = 0;
	if (url.compare(0, sizeof(HTTP_PREFIX) - 1,
                    HTTP_PREFIX, sizeof(HTTP_PREFIX) - 1) == 0)
        start += sizeof(HTTP_PREFIX)-1;

    size_t end = url.find_first_of('/', start);
    if (end == std::string::npos)
        end = url.size();

    std::string host = url.substr(start, end-start);
    std::string path = url.substr(end);
    if (path.empty())
        path = "/";

    conn.close();
    conn.set_host(host, 80);
    conn.setcallbacks(NULL, on_data, on_done, (void*)this);
    conn.request("POST", path.c_str(), headers, (const unsigned char*)&args[0],
                 args.size());

    args.clear();
}

void HTTPObject::update()
{
    done = false;

    if (conn.outstanding())
        conn.pump();
}

#else

HTTPObject::HTTPObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), done(false)
{
}

HTTPObject::~HTTPObject()
{
}

void HTTPObject::add_post(const std::string & name, const std::string & value)
{
}


void HTTPObject::get(const std::string & url)
{
}

void HTTPObject::update()
{
}

#endif
