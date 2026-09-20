#include <string>
#include "frameobject.h"

class HTTPObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(HTTPObject)

    bool done;
    std::string value;
    std::string args;

    HTTPObject(int x, int y, int type_id);
    ~HTTPObject();
    void add_post(const std::string & name, const std::string & value);
    void get(const std::string & url);
    void update();

};
