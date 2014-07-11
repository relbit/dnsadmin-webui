function triggerClick(comp) {
    try { //in firefox
        comp.click();
        return;
    } catch(ex) {}
    try { // in chrome
        if(document.createEvent) {
            var e = document.createEvent('MouseEvents');
            e.initEvent( 'click', true, true );
            comp.dispatchEvent(e);
            return;
        }
    } catch(ex) {}
    try { // in IE
        if(document.createEventObject) {
            var evObj = document.createEventObject();
            comp.fireEvent("onclick", evObj);
            return;
        }
    } catch(ex) {}
}

function in_array(needle, haystack) {
    for (var i = 0; i < haystack.length; ++i) {
        if (haystack[i] == needle) {
            return true;
        }
    }

    return false;
}

String.prototype.replaceAll = function(substr, newstring){
    var temp = this;
    var index = temp.indexOf(substr);
    
    while(index != -1){
        temp = temp.replace(substr, newstring);
        index = temp.indexOf(substr);
    }
    
    return temp;
}