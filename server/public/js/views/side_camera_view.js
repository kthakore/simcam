            var side_camera_view = Backbone.View.extend({ 
                initialize: function() {
                    var that = this;
                    $(window).on('resize', function() { that.on_resize(); } )
                    that.on_resize();
                    
                },
                events : {
                },
                on_resize : function( ) {
                    var width = $(this.el).innerWidth();
                     $('#camera_view').attr('style', 'height: '+width+'px; background-color:salmon');
                },
                animate : function() {
                    var that = this; 
	    			requestAnimationFrame( function() { that.animate() } );
		    		this.render();

                },
                render : function() {

	    			this.renderer.render( this.scene, this.camera );


                },
                update : function(model ) {

                }
            });
