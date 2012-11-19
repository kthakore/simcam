    use Tempest;

    use JSON;
    
    # Create new instance
    $heatmap = new Tempest(
      'input_file' => 'screenshot.png',
      'output_file' => 'heatmap.png',
      'coordinates' => [ [0,10], [2,14], [2,14] ],
    );
    
    # Configure as needed
    $heatmap->set_image_lib( Tempest::LIB_GD );
    
    # Generate and write heatmap image
    $heatmap->render();
