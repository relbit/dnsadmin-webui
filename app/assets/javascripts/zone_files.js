var newId = 1;
var reorderQ;
var syncingOrder = false;
var NEW_ROW_COUNT = 3;

$(document).ready(function() {
    
    $("#NewZone").button({
        icons: {
            primary: 'ui-icon-plusthick'
        }
    });
    
    $("#EditBack").button({
        icons: {
            primary: "ui-icon-arrowreturnthick-1-w"
        }
    });
    
    $(".save-all-records").button({
        icons: {
            primary: "ui-icon-check"
        }
    }).click(function() {        
        $("#EditZone .f-record.modified")
            .not('.inactive').find(".save-record").click();
        
    });
    
    $('.commit, .precommit').button({
        icons: {
            primary: "ui-icon-transferthick-e-w"
        }
    });
    
    $('.abort-commit').button({
        icons: {
            primary: "ui-icon-closethick"
        }
    }).hide().click(function() {
        $('.normal-element').show();
        $('.precommit-element').hide();
    });
    
    $('.normal-element').show();
    $('.precommit-element').hide();
    
    $('.precommit').click(function() {
        $('.normal-element').hide();
        $('.precommit-element').show();
        
        var zoneId = $("#EditZone form input#zone_file_id").val();
        
        loadCommitChanges(zoneId);
    });
    
    $("#AddRecord").button({
        icons: {
            primary: "ui-icon-plusthick"
        }
    }).click(function() {
        addNewRecordForm();
    });
    
    $('.record-form')
        .live('ajax:beforeSend', function(e, jqXHR, settings) {
            $('.loading-bar', this).show();
            
        }).live('ajax:success', function(e, data, textStatus, jqXHR) {
            $('.loading-bar', this).hide();

            var target = $(e.target);
            if (target.hasClass('delete-record')) {
                // deleting record
                target.parent().parent().addClass("inactive").fadeOut("fast", function() {
                    $(this).remove();
                });
            }
            else if (target.is("form")) {
                var li = target.parent();
                
                if (li.is(".correct.new")) {
                    li.remove();
                   
                    while ($('#EditZone ul.records li.f-record.new').length <= NEW_ROW_COUNT) {
                        addNewRecordForm();
                    }
                    
                    $("ul.records li.f-record.new.commit-element .f-r-name input").first().focus();
                }                
            }
        });

    $("#EditZone .f-record").find('input[type="text"], select').live("change", function() {
        $(this).parents(".f-record").addClass("modified");
    });
    
    $('#EditZone input[type="text"]')
        .live("focus", function() {
            $(this).removeClass("grayed");
        })
        .live("blur", function() {
            if ($(this).val() == "") {
                $(this).addClass("grayed");
            }
        });
    
    $('li.f-record.new').hide();
    
    for (var i = 0; i < NEW_ROW_COUNT; ++i) {
        addNewRecordForm();
    }

    $("#RecordAdmins, #SlaveAddresses")
        // don't navigate away from the field on tab when selecting an item
        .bind( "keydown", function( event ) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                    $( this ).data( "autocomplete" ).menu.active ) {
                event.preventDefault();
            }
            else if (event.keyCode === $.ui.keyCode.RIGHT) {
                if (!$(this).autocomplete("widget").is(":visible")) {
                    
                    $(this).autocomplete("option", "minLength", 0).autocomplete("search", "").autocomplete("option", "minLength", 1);
                }
            }
        });
    
    $("#RecordAdmins")
        .autocomplete({
            source: function( request, response ) {
                //var zoneId = $("#EditZone form input#zone_file_id").val();
                
                $.getJSON(url.out('record_admins'), {
                    term: extractLast(request.term)
                }, response );
            },
            focus: function() {
                // prevent value inserted on focus
                return false;
            },
            select: function( event, ui ) {
                var terms = split( this.value );
                // remove the current input
                terms.pop();
                // add the selected item
                terms.push( ui.item.value );
                // add placeholder to get the comma-and-space at the end
                terms.push( "" );
                this.value = terms.join( ", " );
                return false;
            }
        });
    
    $("#SlaveAddresses")
    .autocomplete({
        source: function( request, response ) {
            $.getJSON(url.out('slave_addresses'), {
                term: extractLast(request.term)
            }, response );
        },
        focus: function() {
            // prevent value inserted on focus
            return false;
        },
        select: function( event, ui ) {
            var terms = split( this.value );
            // remove the current input
            terms.pop();
            // add the selected item
            terms.push( ui.item.value );
            // add placeholder to get the comma-and-space at the end
            terms.push( "" );
            this.value = terms.join( ", " );
            return false;
        }
    });
    
    loadDynamicUi();
    
    setupQ();
});

function split(val) {
    return val.split(/,\s*/);
}
function extractLast(term) {
    return split(term).pop();
}

function loadDynamicUi() {
    $(".save-record, .save-zone").button();
    
    $(".delete-record").button({
        icons: {
            primary: "ui-icon-trash"
        }
    });
    
    $('ul.records').sortable({
        placeholder: "ui-state-highlight",
        items: 'li.f-record:not(.new)',
        update: function(event, ui) { pushOrder(); }
    }).disableSelection();
    
    $('#EditZone input[type="text"]').filter('[value=""]').addClass("grayed");
}

function addNewRecordForm() {
    var id = newId;
    newId++;
    var record = $("li.f-record.new").first().clone().show().addClass("commit-element new-" + id);
    $('form.record-form', record).append($("<input />").attr({"name": "fieldId", "type": "hidden"}).val(id));
    $(".f-r-name input, .f-r-ttl input, .f-r-data input", record).val('');
    $(".f-r-rtype select", record).val("Select record type");
    $("#EditZone ul.records").append(record);
}

function markRecordErrors(row, errors) {
    $(".incorrect", row).removeClass("incorrect");
    
    for (var error in errors) {
        $("#record_" + error, row).addClass("incorrect");
    }
}

function loadRecords(html, old_li, new_li) {
    if (old_li && new_li) {
        var old_li_obj = $("#EditZone ul.records li.f-record." + old_li);
        var new_li_obj = $("li.f-record." + new_li, $("<ul></ul>").html(html));
        
        new_li_obj.insertAfter(old_li_obj);
        old_li_obj.remove();
    }
    else {
        $("#EditZone ul.records li.f-record").not(".new").remove();
        $("#EditZone ul.records").prepend(html);
    }
    loadDynamicUi();
}

function markAsCorrect(item) {
    item.addClass('correct');
}

function setupQ() {
    reorderQ = new dsQ("ReorderQ");
}

function pushOrder() {
    var ids = new Array();
    
    $("ul.records li.f-record:not(.new)").each(function() {
        var classes = $(this).attr('class').split(' ');
        for (var c in classes) {
            var cls = $.trim(classes[c]);
            if (cls.substr(0, 5) == "item-") {
                ids.push(cls.slice(5));
            }
        }
    });
    
    reorderQ.push({"records" : ids});
    
    syncOrder();
}

function syncOrder() {
    if (!syncingOrder && !reorderQ.empty()) {
        syncingOrder = true;
        
        var zoneId = $("#EditZone form input#zone_file_id").val();
        var data = reorderQ.pop();
        
        $.post(url.out('zone_files/' + zoneId + '/records/reorder'), data, function(response) {
            syncingOrder = false;
            syncOrder();
        });
    }
}