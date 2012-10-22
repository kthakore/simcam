            var side_camera_view = Backbone.View.extend({ 
                initialize: function() {
                    var that = this;
                    $(window).on('resize', function() { that.on_resize(); } )
                    that.on_resize();
                    console.log(this.options.models.camera.toJSON()); 

                    var cc = this.options.models.camera.toJSON(); 
      				this.camera = new THREE.PerspectiveCamera( cc.fov, cc.ar , cc.near, cc.far );
                    this.camera.position.set(cc.p_x,cc.p_y,cc.p_z);

                    this.scene = new THREE.Scene();
                    this.scene.add( new THREE.AmbientLight( 0x505050 ) );

                    var light = new THREE.SpotLight( 0xffffff, 1.5 );
                    light.position.set( 0, 500, 2000 );
                    light.castShadow = true;

                    light.shadowCameraNear = 200;
                    light.shadowCameraFar = this.camera.far;
                    light.shadowCameraFov = 50;

                    light.shadowBias = -0.00022;
                    light.shadowDarkness = 0.5;

                    light.shadowMapWidth = 2048;
                    light.shadowMapHeight = 2048;
                    this.scene.add( light);

               var material = new THREE.MeshLambertMaterial({
                map: THREE.ImageUtils.loadTexture("img/grid.gif")
                });

                material.map.needsUpdate = true;

                var cube = new THREE.Mesh(
                        new THREE.CubeGeometry( 8, 5, 0.1 ),
                        material
                        );
                cube.overdraw = true;
               that.scene.add( cube ); 
           
                var cv = $(this.el).find('#camera_view');
             
                this.renderer = new THREE.WebGLRenderer( { antialias: true } );
				this.renderer.sortObjects = false;
				this.renderer.setSize( cv.innerHeight(), cv.innerWidth());

				$(this.el).find('#camera_view').html(this.renderer.domElement );

                    this.animate();
                   
                },
                events : {
                },
                on_resize : function( ) {
                    var width = $(this.el).innerWidth();
                     $('#camera_view').attr('style', 'height: '+width+'px;');
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
