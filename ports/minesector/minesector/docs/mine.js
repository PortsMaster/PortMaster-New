mergeInto(LibraryManager.library, {
    openSaveReader: function(_path) {
        let contents = localStorage.getItem("save");
        if (contents) {
            _reader = {index: 0, str: contents};
            return true
        }
        return false
    },
    readByte: function() {
        if (typeof _reader != "undefined") {
            return _reader.str.charCodeAt(_reader.index++);
        }
        else {
            return 0;
        }
    },
    openSaveWriter: function() {
        _writer = {str: ""};
        return true;
    },
    writeByte: function(value) {
        _writer.str += String.fromCharCode(value);
        localStorage.setItem("save", _writer.str);
        return 1;
    },
    closeSaveFile: function() {
        _reader = null;
        _writer = null;
    },
    frontend_init: function() {
        
    },
});
