
function cleanup( image ){

   var cleanup_model = Backbone.Model.extend({ url: '/cleanup' });

   var clean_up = new cleanup_model({ to_del : image });

    clean_up.url = '/cleanup';
    clean_up.save( );

}


function cleanup_model ( model, key ){

   var value = model.get(key);

   if( value )
   {
        cleanup( value );
   }   
   

}


