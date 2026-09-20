ids = {}

def get_id(value):
    try:
        return ids[id(value)]
    except KeyError:
        pass
    new_id = len(ids)
    ids[id(value)] = new_id
    return new_id
