var main_view = Backbone.View.extend({
        initialize: function() {
            this.model = new m({} );
            this.renderer = new THREE.WebGLRenderer({ clearColor: 0x888888, clearAlpha: 255  });
            var width = $(this.el).width();
            var height = (width * 4) /8;
            this.renderer.setSize( $(this.el).width(), height );
            $(this.el).html( this.renderer.domElement );

            this.scene = new THREE.Scene();
            this.camera = new THREE.PerspectiveCamera(
                35, width/height, .4, 1000 );
            this.camera.position.set( 2, 2, 10 );
            this.camera.lookAt( this.scene.position );
            this.scene.add( this.camera );


            this.plane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 8, 8 ), new THREE.MeshBasicMaterial( { color: 0x000000, opacity: 0.25, transparent: true, wireframe: true } ) );
            this.plane.visible = false;
            this.scene.add( this.plane );

            var x_plane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 32, 32 ), new THREE.MeshBasicMaterial( { color: 0x000000, opacity: 0.25, transparent: true, wireframe: true } ) );
            x_plane.rotation.set( 3.14159 /2, 0, 0 );
            this.scene.add( x_plane );


            var sphere = new THREE.Mesh(
                    new THREE.SphereGeometry( .2, 20, 20),
                    new THREE.MeshLambertMaterial( { color: 0x00FF00 } )
                    );

            this.scene.add( sphere );
            sphere.position.set(2, 2 , 0 );

            this.pickable_objects = [sphere];
            this.pickable_objects.push( sphere );


            var light = new THREE.SpotLight( 0xffffff, 1.0 );
            light.position.set( 0, 500, 2000 );
            light.castShadow = true;

            light.shadowCameraNear = 200;
            light.shadowCameraFar = this.camera.far;
            light.shadowCameraFov = 50;

            light.shadowBias = -0.00022;
            light.shadowDarkness = 0.5;

            light.shadowMapWidth = 2048;
            light.shadowMapHeight = 2048;

            this.scene.add( light );
            this.offset = new THREE.Vector3();

            var controls = new THREE.TrackballControls( this.camera );
            controls.rotateSpeed = 1.0;
            controls.zoomSpeed = 1.2;
            controls.panSpeed = 0.8;
            controls.noZoom = false;
            controls.noPan = false;
            controls.staticMoving = true;
            controls.dynamicDampingFactor = 0.3;
            this.controls = controls;

            this.animate();

            this.render();

            console.log('Main View Loaded');


        },
        add_camera_view : function(c) {
            var cube = new THREE.Mesh(
                    new THREE.CubeGeometry( 0.5, 0.5, 0.5 ),
                    new THREE.MeshLambertMaterial( { color: 0xFF0000 } )
                    );
            cube.position.set( offset.x, offset.y, offset.z ); //c.get('p_x'), c.get('p_y'), c.get('p_z') );
            console.log(cube);
            this.scene.add( cube );
            this.pickable_objects.push( cube );
            this.render();
        },
        animate : function () {
            var me = this;
            // build custom animation frame request
            window.requestAnimFrame(function() {
                me.animate();

            });
                me.render();
        },
        events : {
            'mousedown canvas' : 'pick_objects',
            'mouseup canvas' : 'mouseup',
            'mousemove canvas' : 'mousemove'
        },
        mouseup : function( e ) {
            e.preventDefault();
            console.log('MOuse up');
            
            if ( this.INTERSECTED )
            {
                this.plane.position.copy( this.INTERSECTED.position );
                this.SELECTED = null;
                console.log('Letting object go');
                this.controls.enabled = true;
            } else if ( this.SELECTED ){ 
                this.SELECTED = null;
                this.controls.enabled = true;
            }
            this.el.style.cursor = 'auto';
        },
        mousemove : function(e) {
                e.preventDefault();
                var canvas = $(this.el).find('canvas');

                var vector = new THREE.Vector3( ( ( e.clientX ) / canvas.width() ) * 2 - 1, -( ( e.clientY ) / canvas.height() ) * 2 + 1, 0.5);
                var projector = new THREE.Projector();

                projector.unprojectVector( vector, this.camera );


                var ray = new THREE.Ray(this.camera.position, vector.subSelf(this.camera.position).normalize());


                if ( this.SELECTED ) {

                    var intersects = ray.intersectObject( this.plane );
                    this.SELECTED.position.copy( intersects[ 0 ].point.subSelf( this.offset ) );
                    return;

                }

                var intersects = ray.intersectObjects( this.pickable_objects);

                if ( intersects.length > 0 ) {

                    if ( this.INTERSECTED != intersects[ 0 ].object ) {

                        if ( this.INTERSECTED ) this.INTERSECTED.material.color.setHex( this.INTERSECTED.currentHex );

                        this.INTERSECTED = intersects[ 0 ].object;
                        this.INTERSECTED.currentHex = this.INTERSECTED.material.color.getHex();

                        this.plane.position.copy( this.INTERSECTED.position );
                        this.plane.lookAt( this.camera.position );

                    }

                    this.el.style.cursor = 'pointer';

                } else {

                    if ( this.INTERSECTED ) this.INTERSECTED.material.color.setHex( this.INTERSECTED.currentHex );

                    this.INTERSECTED = null;

                    this.el.style.cursor = 'auto';

                }


        },
        pick_objects: function (e) {
              e.preventDefault();
              var canvas = $(this.el).find('canvas');

              var vector = new THREE.Vector3( ( ( e.offsetX ) / canvas.width() ) * 2 - 1, -( ( e.offsetY ) / canvas.height() ) * 2 + 1, 0.5);

              var projector = new THREE.Projector();
              projector.unprojectVector(vector, this.camera);
              var ray = new THREE.Ray(this.camera.position, vector.subSelf(this.camera.position).normalize());

              var objects =  ray.intersectObjects( this.pickable_objects );//this.scene.children );
              console.log( objects );

              if( objects.length )
              {
                  this.controls.enabled = false;
                  this.SELECTED = objects[0].object;
                  this.picked_object = objects[0];
                  var intersects = ray.intersectObject( this.plane );
                  this.offset.copy( objects[ 0 ].point ).subSelf( this.plane.position );

                  this.el.style.cursor = 'move';


              }
    
        },
        draw_camera : function( c ) {

        }, // draw_camera
        render : function ()  {
            this.controls.update();
            this.renderer.render(this.scene, this.camera);
        }
    }); //main_view




