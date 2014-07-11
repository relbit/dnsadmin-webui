$(document).ready(function() {

    loadTableUi();
    
//    window.setTimeout(function() {
//        $('.notice').fadeOut();
//    }, 5000);
    
    

});

function loadTableUi(obj) {
    if (!obj) {
        obj = document;
    }
    
    $('table.ui-list td.ui-show a', obj).button({
        icons: {
            primary: "ui-icon-contact"
        }
    });
    
    $('table.ui-list td.ui-edit a', obj).button({
        icons: {
            primary: "ui-icon-wrench"
        }
    });
    
    $('table.ui-list td.ui-delete a', obj).button({
        icons: {
            primary: "ui-icon-trash"
        }
    });
    
    $('.ui-action a', obj).hide();
    
    $('table.ui-list tr', obj).mouseover(function() {
        $(this).siblings().removeClass('over');
        $(this).parent().find(".ui-action a").hide();
        $(this).addClass('over').find('.ui-action a').show();
    }).click(function(e) {
        if (!$(e.target).is("span") && !$(e.target).is("a")) {
            var editAction = $("td.ui-edit a", this).get(0);
            var showAction = $("td.ui-show a", this).get(0);
            
            if (editAction) {
                triggerClick(editAction);
            }
            else {
                triggerClick(showAction);
            }
        }
    });
}

String.prototype.getLabel = function (labels) {
    var temp = this;
    
    if (temp == "") {
        return "";
    }
    
    if (labels[temp]) {
        return labels[temp]
    }
    
    temp = temp.replaceAll("_", " ");
    temp = temp[0].toUpperCase() + temp.substr(1);
    
    return temp;
}

function loadCommitChanges(zoneId, url_string) {
    
    if (!url_string) {
        url_string = url.out('zone_files/' + zoneId + '/changes');
    }
    
    $.get(url_string, {}, function(response) {
        var data;
        
        if (response == null) {
            data = {"soa" : {"current" : {}, "previous" : {}}, "records" : []};
        }
        else {
            if (typeof(response) == "string") {
                data = $.parseJSON(response);
            }
            else {
                data = response;
            }
        }
        
        var fields = ['label', 'origin', 'ttl', 'address', 'nameserver', 'email', 'serial_number', 'slave_refresh', 'slave_retry', 'slave_expiration', 'max_cache'];
        var labels = {'ttl' : 'TTL', 'address' : 'Zone', 'nameserver' : 'NS', 'max_cache' : 'Max cache time'};
        var current = data['soa']['current'];
        var previous = data['soa']['previous'];
        var records = data['records'];
        var box = $('#CommitChanges');
        var loadingBar = $('#CommitChangesLoadingBar');
        
        loadingBar.hide();
        box.empty().append('<h3 class="soa">SOA changes:</h3>');
        
        var list = $('<ul></ul>').addClass('soa');
        var listEmpty = true;

        function addSOA(CSSClass, label, item, user) {
            list.append($('<li></li>')
                .addClass(CSSClass)
                .append("<img src=\"/assets/status_" + CSSClass + ".png\" />")
                .append('<span class="label">' + label + ":</span>")
                .append('<span class="data">' + item + '</b></span>')
                .append('<span class="user">' + user + '</b></span>')
                .append('<div class="cb"></div>'));
        }
        
        function userInfo(user) {
            return "<b>" + user.username + "</b> (ID: " + user.id + ")";
        }
        
        for (var i in current) {
            if (in_array(i, fields) && (current.previous_id == 0 || current[i] != previous[i])) {
                listEmpty = false;
                
                if (current.previous_id > 0) {
                    addSOA('deleted', i.getLabel(labels), previous[i], userInfo(current.user));                    
                }
                
                addSOA('added', i.getLabel(labels), current[i], userInfo(current.user)); 
            }        
        }
        
        if (listEmpty) {
            $('h3.soa', box).append(' <i>None</i>');
        }
        else {
            box.append(list);
        }
        
        box.append('<h3 class="records">Record changes:</h3>');
        
        listEmpty = true;
        
        var recordList = $('<table></table>')
            .addClass('records ui-list ui-round ui-shadow')
            .append($('<tbody></tbody>')
                .append($('<tr></tr>')
                    .addClass('ui-header')
                    .append('<th>&nbsp;</th>')
                    .append('<th>Name</th>')
                    .append('<th>TTL</th>')
                    .append('<th>Type</th>')
                    .append('<th>Data</th>')
                    .append('<th>Edited by</th>')));
        
        function addRecord(CSSClass, name, ttl, rtype, itemData, user) {
            recordList.append($('<tr></tr>')
                    .addClass(CSSClass)
                    .append("<td><img src=\"/assets/status_" + CSSClass + ".png\" /></td>")
                    .append("<td>" + name + "</td>")
                    .append("<td>" + ttl + "</td>")
                    .append("<td>" + rtype + "</td>")
                    .append("<td>" + itemData + "</td>")
                    .append("<td>" + user + "</td>"));
        }
        
        for (var i in records) {
            var item = records[i];
            
            if (item.is_dirty == 1) {
                listEmpty = false;
                
                if (item.status == 1) {
                    // deleted
                    addRecord("deleted", item.name, item.ttl, item.rtype, item.data, userInfo(item.user));
                }
                else if (item.previous_id == 0) {
                    // added
                    addRecord("added", item.name, item.ttl, item.rtype, item.data, userInfo(item.user));
                }
                else {
                    // modified: first deleted, then added
                    addRecord("deleted", item.previous.name, item.previous.ttl, item.previous.rtype, item.previous.data, userInfo(item.user));
                    addRecord("added", item.name, item.ttl, item.rtype, item.data, userInfo(item.user));
                }
            }
        }
        
        if (listEmpty) {
            $('h3.records', box).append(' <i>None</i>');
        }
        else {
            box.append(recordList);       
            loadTableUi(box);
        }
    });
}