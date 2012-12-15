

var dof_camera_view = Backbone.View.extend({

    initialize: function() {
        var that = this;
                this.mouse =  new THREE.Vector2(), this.offset = new THREE.Vector3();

  				this.camera = new THREE.PerspectiveCamera( 35, window.innerWidth / window.innerHeight, 1, 10000 );
                this.camera.position.set(15,7.5,15);

				this.controls = new THREE.OrbitControls( this.camera );
				this.controls.rotateSpeed = 1.0;
				this.controls.zoomSpeed = 0;
				this.controls.panSpeed = 0;
				this.controls.userZoom = true;
				this.controls.noPan = true;
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


            this.material_depth = new THREE.MeshDepthMaterial();

            var material = new THREE.MeshLambertMaterial({
            map: THREE.ImageUtils.loadTexture("/img/gridsquare.gif")
            });
            var hi_material = new THREE.MeshLambertMaterial({ color: 0x000000});



            material.map.needsUpdate = true;

            for( i = 0; i < 20; i++ ){

                  for ( k = 0; k < 20; k++ ){

                        var c_m = material;

                        if( i == 5 && k == 5) {
                            c_m = hi_material;
                        }
                        var cube = new THREE.Mesh(
                                new THREE.CubeGeometry( 5, 5, 5 ),
                                c_m
                                );
                        cube.model = that.options.models.grid;
                        cube.model.trigger( 'init', cube.model, cube ); 
                        cube.overdraw = true;
                        that.scene.add( cube ); that.objects.push( cube );
                        var x = -1 * i * 10;
                        var z = -1 * k * 10;

                        x += 50; y = 0; z += 50;

                        cube.position.set(x,y,z);
                }

            }

                    
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

				this.renderer = new THREE.WebGLRenderer( { antialias: true, clearColor: 0x888888, clearAlpha: 255  } );
				this.renderer.sortObjects = false;
				this.renderer.setSize( window.innerWidth, window.innerHeight );

				this.renderer.shadowMapEnabled = true;
				this.renderer.shadowMapSoft = true;

				this.el.appendChild(this.renderer.domElement );

                $(this.el).find('canvas').addClass('working_canvas');

				this.scene.matrixAutoUpdate = false;
                this.postprocessing = { enabled  : true };


				this.initPostprocessing();


				/*renderer.domElement.addEventListener( 'mousemove', onDocumentMouseMove, false );
				renderer.domElement.addEventListener( 'mousedown', onDocumentMouseDown, false );
				renderer.domElement.addEventListener( 'mouseup', onDocumentMouseUp, false );


				window.addEventListener( 'resize', onWindowResize, false );*/
                $(window).on('resize', function() { that.on_resize(); } )
                this.animate();
                that.on_resize();
    },
    initPostprocessing : function() {
                postprocessing = this.postprocessing;
            	postprocessing.scene = new THREE.Scene();

                
				postprocessing.camera = new THREE.OrthographicCamera( window.innerWidth / - 2, window.innerWidth / 2,  window.innerHeight / 2, window.innerHeight / - 2, -10000, 10000 );
                postprocessing.camera.position.set(15,7.5,15);

				postprocessing.scene.add( postprocessing.camera );

                var width = window.innerWidth; var height = window.innerHeight;

				var pars = { minFilter: THREE.NearestFilter, magFilter: THREE.NearestFilter, format: THREE.RGBFormat };
				postprocessing.rtTextureDepth = new THREE.WebGLRenderTarget( width, height, pars );
				postprocessing.rtTextureColor = new THREE.WebGLRenderTarget( width, height, pars );

				var bokeh_shader = THREE.BokehShader;

				postprocessing.bokeh_uniforms = THREE.UniformsUtils.clone( bokeh_shader.uniforms );

				postprocessing.bokeh_uniforms[ "tColor" ].value = postprocessing.rtTextureColor;
				postprocessing.bokeh_uniforms[ "tDepth" ].value = postprocessing.rtTextureDepth;
				postprocessing.bokeh_uniforms[ "focus" ].value = 0.800;
				postprocessing.bokeh_uniforms[ "aperture" ].value = 0.400;

				postprocessing.bokeh_uniforms[ "aspect" ].value = width / height;


				postprocessing.materialBokeh = new THREE.ShaderMaterial( {

					uniforms: postprocessing.bokeh_uniforms,
					vertexShader: bokeh_shader.vertexShader,
					fragmentShader: bokeh_shader.fragmentShader

				} );

				postprocessing.quad = new THREE.Mesh( new THREE.PlaneGeometry( width, height ), postprocessing.materialBokeh );
				postprocessing.quad.position.z = - 500;
				postprocessing.scene.add( postprocessing.quad );

                this.postprocessing = postprocessing;

    },
    events : {
//       'mousemove canvas' : 'on_canvas_mmove',
//       'mousedown canvas' : 'on_canvas_mdown',
//       'mouseup canvas' : 'on_canvas_mup',
    },
    on_canvas_mmove : function( event ) {
                


				event.preventDefault();
                var p = $(this.el).find('canvas').position();

			    this.mouse.x = ( (event.clientX - p.left) / $(this.el).innerWidth() ) * 2 - 1;
				this.mouse.y = - ( (event.clientY -p.top)/ $(this.el).innerHeight() ) * 2 + 1;

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
                    var target = vector.normalize();

                    // Axis and angle of rotation
                    var axis = new THREE.Vector3().cross(forward, target);
                    var sinAngle = axis.length(); // |u x v| = |u|*|v|*sin(a)
                    var cosAngle = forward.dot(target); // u . v = |u|*|v|*cos(a)
                    var angle = Math.atan2(sinAngle, cosAngle); // atan2(sin(a),cos(a)) = a
                    axis.normalize();
                   
                    var a = new THREE.Mesh();
                    a.useQuaternion = true;
                    a.quaternion.setFromAxisAngle(axis, angle);
                        this.SELECTED.rotation.set( a.quaternion.x, a.quaternion.y, a.quaternion.z );
                        this.SELECTED.rotation.multiplyScalar( 0.5 );
       
                        }
                        else {
					       this.SELECTED.position.copy( intersects[ 0 ].point.subSelf( this.offset ) );
                        }
                        this.SELECTED.model.trigger( 'move', this.SELECTED.model, this.SELECTED );
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

				this.camera.aspect =window.innerWidth / window.innerHeight;
				this.camera.updateProjectionMatrix();

				this.renderer.setSize( window.innerWidth, window.innerHeight );


    },
    animate : function () {
                var that = this; 
				requestAnimationFrame( function() { that.animate() } );
				this.render();
    }, 
    render : function () {

				this.controls.update();
                var renderer = this.renderer;
                var scene = this.scene;
                var camera = this.camera;

                var postprocessing = this.postprocessing;

            	if ( postprocessing.enabled ) {

					renderer.clear();

					// Render scene into texture

					scene.overrideMaterial = null;
					renderer.render( scene, camera, postprocessing.rtTextureColor, true );

					// Render depth into texture

					scene.overrideMaterial = this.material_depth;
					renderer.render( scene, camera, postprocessing.rtTextureDepth, true );

					// Render bokeh composite

					renderer.render( postprocessing.scene, postprocessing.camera );


				} else {

					renderer.clear();
					renderer.render( scene, camera );

				}


    },
   
    //PUBLIC METHODS:
   

    //add_obj( type, update_callback )

});
