

var main_camera_view = Backbone.View.extend({

    initialize: function() {
        var that = this;
                this.mouse =  new THREE.Vector2(), this.offset = new THREE.Vector3();

  				this.camera = new THREE.PerspectiveCamera( 35, $(this.el).innerWidth() / window.innerHeight, 1, 10000 );
                this.camera.position.set(65,65,65);

				this.controls = new THREE.OrbitControls( this.camera );
				this.controls.rotateSpeed = 1.0;
				this.controls.zoomSpeed = 1.2;
				this.controls.panSpeed = 0.8;
				this.controls.noZoom = false;
				this.controls.noPan = false;
				this.controls.staticMoving = true;
				this.controls.dynamicDampingFactor = 0.3;

				this.scene = new THREE.Scene();
                this.objects = $([]);

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
                this.lights = $([]);
                this.lights.push( light );

				this.scene.add( light );

                var jsonLoader = new THREE.JSONLoader();
                jsonLoader.load( "/3d_objs/camera.js", function( geometry ) {  

                    var cam_obj = new THREE.Mesh( geometry, new THREE.MeshLambertMaterial( { color: 0x2200cc } ) );

					cam_obj.material.ambient = cam_obj.material.color;

					cam_obj.position.x = 0;
					cam_obj.position.y = 20;
					cam_obj.position.z = 45;

					cam_obj.scale.x = 5;
					cam_obj.scale.y = 5;
					cam_obj.scale.z = 5;

                    cam_obj.rotation.set(  Math.PI/2 ,0,  0 );
                    cam_obj.model = that.options.models.camera;
//					cam_obj.castShadow = false;
//					cam_obj.receiveShadow = false;

					that.scene.add( cam_obj );

					that.objects.push( cam_obj );


                    } );
                    
				this.plane = new THREE.Mesh( new THREE.PlaneGeometry( 4000, 4000, 4, 4), new THREE.MeshBasicMaterial( { color: 0x000000, opacity: 0.25, transparent: true, wireframe: true } ) );
				xplane = new THREE.Mesh( new THREE.PlaneGeometry( 4000, 4000, 4, 4 ), new THREE.MeshBasicMaterial( { color: 0xCC0000, opacity: 0.25, transparent: true, wireframe: true } ) );
				yplane = new THREE.Mesh( new THREE.PlaneGeometry( 4000, 4000, 4, 4 ), new THREE.MeshBasicMaterial( { color: 0x00CC00, opacity: 0.25, transparent: true, wireframe: true } ) );
				zplane = new THREE.Mesh( new THREE.PlaneGeometry( 4000, 4000, 4, 4 ), new THREE.MeshBasicMaterial( { color: 0x0000CC, opacity: 0.25, transparent: true, wireframe: true } ) );

                yplane.rotation.set( 0, 1.57079633, 0 );
                zplane.rotation.set( 1.57079633, 0, 0 );


                this.scene.add(xplane); this.scene.add(yplane); this.scene.add(zplane);

				this.plane.visible = false;
				this.scene.add(this.plane );

				this.projector = new THREE.Projector();

				this.renderer = new THREE.WebGLRenderer( { antialias: true } );
				this.renderer.sortObjects = false;
				this.renderer.setSize( $(this.el).innerWidth(), window.innerHeight );

				this.renderer.shadowMapEnabled = true;
				this.renderer.shadowMapSoft = true;

				this.el.appendChild(this.renderer.domElement );

				/*
				renderer.domElement.addEventListener( 'mousemove', onDocumentMouseMove, false );
				renderer.domElement.addEventListener( 'mousedown', onDocumentMouseDown, false );
				renderer.domElement.addEventListener( 'mouseup', onDocumentMouseUp, false );


				window.addEventListener( 'resize', onWindowResize, false );
                */
                $(window).on('resize', function() { that.on_resize(); } )
                this.animate();
    },
    events : {
       'mousemove canvas' : 'on_canvas_mmove',
       'mousedown canvas' : 'on_canvas_mdown',
       'mouseup canvas' : 'on_canvas_mup',
    },
    on_canvas_mmove : function( event ) {
                


				event.preventDefault();

			    this.mouse.x = ( event.clientX / $(this.el).innerWidth() ) * 2 - 1;
				this.mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;

				//

				var vector = new THREE.Vector3( this.mouse.x, this.mouse.y, 0.5 );
				this.projector.unprojectVector( vector, this.camera );

				var ray = new THREE.Ray( this.camera.position, vector.subSelf( this.camera.position ).normalize() );


				if ( this.SELECTED ) {

					var intersects = ray.intersectObject( this.plane );
                    if( intersects[0] && intersects[0].point ) {
                        if( event.shiftKey )
                        {
                            var loc =  intersects[ 0 ].point.subSelf( this.offset ); 
                            var vector = new THREE.Vector3(0,0,0);

                            vector.sub( this.SELECTED.position, loc );

                                                // Direction we are already facing (without rotation)
                    var forward = new THREE.Vector3(0,0,-1);

                    // Direction we want to be facing (towards mouse pointer)
                    var target = new THREE.Vector3().sub(vector, this.SELECTED.position).normalize();

                    // Axis and angle of rotation
                    var axis = new THREE.Vector3().cross(forward, target);
                    var sinAngle = axis.length(); // |u x v| = |u|*|v|*sin(a)
                    var cosAngle = forward.dot(target); // u . v = |u|*|v|*cos(a)
                    var angle = Math.atan2(sinAngle, cosAngle); // atan2(sin(a),cos(a)) = a
                    axis.normalize();
                    
                    this.SELECTED.useQuaternion = true;
                    this.SELECTED.quaternion.setFromAxisAngle(axis, angle);
       
                        }
                        else {
					       this.SELECTED.position.copy( intersects[ 0 ].point.subSelf( this.offset ) );
                        }
                        this.SELECTED.model.trigger( 'move', this.SELECTED );
                    }
					return;

				}


				var intersects = ray.intersectObjects( this.objects );

				if ( intersects.length > 0 ) {

					if ( this.INTERSECTED != intersects[ 0 ].object ) {

						if ( this.INTERSECTED ) this.INTERSECTED.material.color.setHex( this.INTERSECTED.currentHex );

						this.INTERSECTED = intersects[ 0 ].object;
						this.INTERSECTED.currentHex = this.INTERSECTED.material.color.getHex();

						this.plane.position.copy( this.INTERSECTED.position );
						this.plane.lookAt( this.camera.position );
                        this.plane.rotation.copy( this.camera.rotation );

					}

				    this.el.style.cursor = 'pointer';

				} else {

					if ( this.INTERSECTED ) this.INTERSECTED.material.color.setHex( this.INTERSECTED.currentHex );

					this.INTERSECTED = null;

					this.el.style.cursor = 'auto';

				}


    },
    on_canvas_mdown : function(event ) {

				event.preventDefault();

				var vector = new THREE.Vector3( this.mouse.x, this.mouse.y, 0.5 );
				this.projector.unprojectVector( vector, this.camera );

				var ray = new THREE.Ray( this.camera.position, vector.subSelf( this.camera.position ).normalize() );

				var intersects = ray.intersectObjects( this.objects );

				if ( intersects.length > 0 ) {

					this.controls.enabled = false;

					this.SELECTED = intersects[ 0 ].object;

					var intersects = ray.intersectObject( this.plane );
					this.offset.copy( intersects[ 0 ].point ).subSelf( this.plane.position );

					this.el.style.cursor = 'move';

				}


    },
    on_canvas_mup : function(event ) {
				event.preventDefault();

				this.controls.enabled = true;

				if ( this.INTERSECTED ) {

					this.plane.position.copy( this.INTERSECTED.position );

					this.SELECTED = null;

				}

				this.el.style.cursor = 'auto';

    },
    on_resize : function (event ) {

				this.camera.aspect = $(this.el).innerWidth() / window.innerHeight;
				this.camera.updateProjectionMatrix();

				this.renderer.setSize( $(this.el).innerWidth(), window.innerHeight );


    },
    animate : function () {
                var that = this; 
				requestAnimationFrame( function() { that.animate() } );
				this.render();
    }, 
    render : function () {

				this.controls.update();

				this.renderer.render( this.scene, this.camera );


    }
   
    //PUBLIC METHODS:

    //add_obj( type, update_callback )

});
