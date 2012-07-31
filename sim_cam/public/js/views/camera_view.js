        var camera_view = Backbone.View.extend({
            initialize: function(options) {
                var m = Backbone.Model.extend({ }); 
                this.model = new m({
                    u: 400, v: 320, fov: 35, ar: 400/320,
                    near: .4, far: 10000, p_x: -15, p_y: 10, p_z: 15

                }); 

                $.each( this.model.attributes, function( i, a ) { $('[data-camera="'+i+'"]').val( a ); } );
                this.render();
            },
            events : {
                'change input' : 'update',
            },
            render : function() {
             
            var c = $(this.el).find('#cam_canvas');
            if( this.renderer ) { delete this.renderer; } 
            this.renderer = new THREE.WebGLRenderer();
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
            scene.add( cube );

            var light = new THREE.PointLight( 0xFFFF00 );
            light.position.set( 10, 0, 10 );
            scene.add( light );
            this.renderer.render(scene, camera);
            },
            update : function(e) {
                var input = $(e.currentTarget);
                this.model.set( input.attr('data-camera'), input.val() );
                this.render();
            }
        });

