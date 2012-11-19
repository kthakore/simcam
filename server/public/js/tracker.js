//Depends on jquery 
 
var evnts = $([]);

funtion JSON_events () {
    return JSON.stringify( evnts );
}

$(function() {
       
    var to_capture = ['mousemove', 'mousedown', 'mouseup'];
    
    $.each( to_capture, function(i, tc ) {

        $(window).on(tc, function(e) {
            evnts.push( { type: e.type, client: { x: e.clientX, y: e.clientY}, offset: { x: e.offsetX, y: e.offsetY}, page: { x: e.pageX, y: e.pageY}, timeStamp: e.timeStamp  } );                   
        });
    
    });
    
    
      $(window).on('keypress', function(e) {
          evnts.push( { type: e.type, key: e.key, keyCode: e.keyCode, char: e.char, charCode: e.charCode, shiftkey: e.shiftkey, metaKey: e.metaKey, timeStamp: e.timeStamp });             
        });

});


