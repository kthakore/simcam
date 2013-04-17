//Depends on jquery 
 
var evnts = {
        mousemove : [],
        mousedown : [],
        mouseup : [],
        keypress : []
        };

function generate_heatmaps () {
    return JSON.stringify( evnts );
}

$(function() {
       
    var to_capture = ['mousemove', 'mousedown', 'mouseup'];
    
    $.each( to_capture, function(i, tc ) {

        $(window).on(tc, function(e) {
            evnts[tc].push( { "x" : e.offsetX, "y" : e.offsetY, "timestamp" : e.timeStamp} );                   
        });
    
    });
    
    
   $(window).on('keypress', function(e) {
          evnts['keypress'].push( { type: e.type, key: e.key, keyCode: e.keyCode, char: e.char, charCode: e.charCode, shiftkey: e.shiftkey, metaKey: e.metaKey, timeStamp: e.timeStamp });             
        });

    console.log('Loaded event capture handlers');

});


