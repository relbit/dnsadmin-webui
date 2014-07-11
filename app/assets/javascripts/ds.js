function dsQ(id) {
    
    this.qObject = $("<div></div>").attr('id', id).css({'display': 'none'}).appendTo('body');
    
    this.push = function(json) {
        this.qObject.append($("<div></div>").data('item', json));
    }
    
    this.empty = function() {
        return (this.qObject.children().length == 0);
    }
    
    this.pop = function() {
        if (!this.empty()) {
            return this.qObject.children().first().detach().data('item');
        }
    }
}