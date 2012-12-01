//Depends on jquery 
 
var evnts = {
        mousemove : [],
        mousedown : [],
        mouseup : []
        };

function generate_heatmaps () {
    return JSON.stringify( evnts );
}

$(function() {
       
    var to_capture = ['mousemove', 'mousedown', 'mouseup'];
    
    $.each( to_capture, function(i, tc ) {

        $(window).on(tc, function(e) {
            console.log( tc );
            evnts[tc].push( [ e.offsetX, e.offsetY ] );                   
        });
    
    });
    
    
   //   $(window).on('keypress', function(e) {
   //       evnts.push( { type: e.type, key: e.key, keyCode: e.keyCode, char: e.char, charCode: e.charCode, shiftkey: e.shiftkey, metaKey: e.metaKey, timeStamp: e.timeStamp });             
   //     });

    console.log('Loaded event capture handlers');

});


