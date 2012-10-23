          var camera_view = Backbone.View.extend({
            initialize: function(options) {
             
                this.model = camera_model;
                this.render(1);
            },
            events : {
                'change input' : 'update', 
            },
            render : function(init) {
             
            var c = $(this.el).find('#cam_canvas');
            if( this.renderer ) { delete this.renderer; } 
            this.renderer = new THREE.WebGLRenderer({ clearColor: 0x888888, clearAlpha: 255  });
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

            if( init )
            {
                camera.lookAt( scene.position );

                this.model.set('r_x', camera.rotation.x );
                this.model.set('r_y', camera.rotation.y );
                this.model.set('r_z', camera.rotation.z );


            } else
            {
                var DegRad = 0.0174532925;
                camera.rotation.set( this.model.get('r_x') * DegRad, this.model.get('r_y') * DegRad, this.model.get('r_z') * DegRad );
            }
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

            var ambientLight = new THREE.AmbientLight(0x222222);
            scene.add(ambientLight);


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

