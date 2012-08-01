          var camera_view = Backbone.View.extend({
            initialize: function(options) {
                _.bindAll(this, 'on_keypress');
                $(document).bind('keypress', this.on_keypress);

                this.model = camera_model;
                this.render();
            },
            on_keypress: function(e) {
               if( e.keyCode == 119 )
                {
                   this.camera.position.z = this.camera.position.z + 5;
                   
                }
                else if( e.keyCode == 115 ){
                   this.camera.position.z = this.camera.position.z - 5;

                }
                else if( e.keyCode == 97 ){
                   this.camera.position.y = this.camera.position.y + 5;

                }
                else if( e.keyCode == 100 ){
                   this.camera.position.y = this.camera.position.y - 5;

                }
                else if( e.keyCode == 101 ){
                   this.camera.position.x = this.camera.position.x - 5;

                }
                else if( e.keyCode == 113 ){
                   this.camera.position.x = this.camera.position.x + 5;

                }
        
                  $(this.el).find('[data-camera="p_x"]').val( this.camera.position.x );
                  $(this.el).find('[data-camera="p_y"]').val( this.camera.position.y );
                  $(this.el).find('[data-camera="p_z"]').val( this.camera.position.z );

                 
    
                this.renderer.render(this.scene, this.camera);
                this.obj_moved();

            },
            events : {
                'change input' : 'update', 
            },
            render : function() {
             
            var c = $(this.el).find('#cam_canvas');
            if( this.renderer ) { delete this.renderer; } 
            this.renderer = new THREE.WebGLRenderer({ clearColor: 0xFFFFFF, clearAlpha: 255  });
            this.renderer.setSize( this.model.get('u'), this.model.get('v') );
            c.html( this.renderer.domElement );

            var scene = new THREE.Scene();
            var camera = new THREE.PerspectiveCamera(
                this.model.get('fov'),         // Field of view
                this.model.get('ar'),  // Aspect ratio
                this.model.get('near'),         // Near
                this.model.get('far')      // Far
                );
            camera.position.set( this.model.get('p_x'), this.model.get('p_y'), this.model.get('p_z') );
            camera.lookAt( scene.position );
            scene.add( camera );
            var cube = new THREE.Mesh(
                    new THREE.CubeGeometry( 5, 5, 5 ),
                    new THREE.MeshLambertMaterial( { color: 0xFF0000 } )
                    );
            var sphere = new THREE.Mesh(
                    new THREE.SphereGeometry( 5, 20, 20),
                    new THREE.MeshLambertMaterial( { color: 0x00FF00 } )
                    );

            scene.add( cube );
            scene.add( sphere );
            sphere.position.set(20, 0 , 0 );

            var light = new THREE.PointLight( 0xFFFF00 );
            light.position.set( 10, 0, 10 );
            scene.add( light );

            var light = new THREE.PointLight( 0x222222 );
            light.position.set( -20, -20, -20 );
            scene.add( light );

            this.camera = camera;
            this.scene = scene;
            this.renderer.render(scene, camera);
            this.obj_moved();
    
            },
            obj_moved: function( ) {
                var c = $(this.el).find('#cam_canvas');
                var canvas = c.find('canvas')[0];
                var img = canvas.toDataURL('image/png');
                this.model.set('image', img) ;
                this.model.trigger('obj_moved');
            },
            update : function(e) {
                var input = $(e.currentTarget);
                this.model.set( input.attr('data-camera'), input.val() );
                this.render();
            }
        });

