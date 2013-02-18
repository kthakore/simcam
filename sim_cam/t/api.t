use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('SimCam');


# Sending an API Image 

my $api_image_tm = $t->post_ok('/api/image'  => json => { type => 'base64', image => 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAFc0lEQVR4Xu3VQW5CURDEwM/9D51wgWTRysJkCrF9Uo+Nxevred5fHwT+lsDred7fz/+8BPL5EosXCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMgX8TSIaoIQgECbxD90EAgZ8ICMRvA4FfCAjEzwMBgfgNILAR8A+ycfPqCAGBHBHtzI2AQDZuXh0hIJAjop25ERDIxs2rIwQEckS0MzcCAtm4eXWEgECOiHbmRkAgGzevjhAQyBHRztwICGTj5tURAgI5ItqZGwGBbNy8OkJAIEdEO3MjIJCNm1dHCAjkiGhnbgQEsnHz6ggBgRwR7cyNgEA2bl4dISCQI6KduREQyMbNqyMEBHJEtDM3AgLZuHl1hIBAjoh25kZAIBs3r44QEMgR0c7cCAhk4+bVEQICOSLamRsBgWzcvDpCQCBHRDtzIyCQjZtXRwgI5IhoZ24EBLJx8+oIAYEcEe3MjYBANm5eHSEgkCOinbkREMjGzasjBARyRLQzNwIC2bh5dYSAQI6IduZGQCAbN6+OEBDIEdHO3AgIZOPm1RECAjki2pkbAYFs3Lw6QkAgR0Q7cyMgkI2bV0cICOSIaGduBASycfPqCAGBHBHtzI2AQDZuXh0hIJAjop25ERDIxs2rIwQEckS0MzcCAtm4eXWEgECOiHbmRkAgGzevjhAQyBHRztwICGTj5tURAgI5ItqZGwGBbNy8OkJAIEdEO3MjIJCNm1dHCAjkiGhnbgQEsnHz6ggBgRwR7cyNgEA2bl4dISCQI6KduREQyMbNqyMEBHJEtDM3AgLZuHl1hIBAjoh25kZAIBs3r44QEMgR0c7cCAhk4+bVEQICOSLamRsBgWzcvDpCQCBHRDtzIyCQjZtXRwgI5IhoZ24EBLJx8+oIAYEcEe3MjYBANm5eHSEgkCOinbkREMjGzasjBARyRLQzNwIC2bh5dYSAQI6IduZGQCAbN6+OEBDIEdHO3AgIZOPm1RECAjki2pkbAYFs3Lw6QkAgR0Q7cyMgkI2bV0cICOSIaGduBASycfPqCAGBHBHtzI2AQDZuXh0hIJAjop25ERDIxs2rIwQEckS0MzcCAtm4eXWEgECOiHbmRkAgGzevjhAQyBHRztwICGTj5tURAgI5ItqZGwGBbNy8OkJAIEdEO3MjIJCNm1dHCAjkiGhnbgQEsnHz6ggBgRwR7cyNgEA2bl4dISCQI6KduREQyMbNqyMEBHJEtDM3AgLZuHl1hIBAjoh25kbgG5oglsk2/xIBAAAAAElFTkSuQmCC' });

warn  $api_image_tm->tx->res->body;
$api_image_tm->status_is(200);
$api_image_tm->content_like(qr/img/i);

my $img =  $api_image_tm->tx->res->json->{img};


is( -e 'public/uploads/'.$img.'_in.png', 1 );

$t->get_ok('/api/image/'.$img)->status_is(200);


my $api_image2_tm = $t->post_ok('/api/image' => json => { 
					type => 'base64',
					image => 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAFZUlEQVR4Xu3VQW5CURDEwM/9D51wgWTRysJkCrF9Uo+Nxevred5fHwT+lsDred7fz/+8BPL5EosXCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJGAQIpWbMoQEEhGhSFFAgIpWrEpQ0AgGRWGFAkIpGjFpgwBgWRUGFIkIJCiFZsyBASSUWFIkYBAilZsyhAQSEaFIUUCAilasSlDQCAZFYYUCQikaMWmDAGBZFQYUiQgkKIVmzIEBJJRYUiRgECKVmzKEBBIRoUhRQICKVqxKUNAIBkVhhQJCKRoxaYMAYFkVBhSJCCQohWbMgQEklFhSJHAvwmkCNcmBCoE3qH7IIDATwQE4reBwC8EBOLngYBA/AYQ2Aj4B9m4eXWEgECOiHbmRkAgGzevjhAQyBHRztwICGTj5tURAgI5ItqZGwGBbNy8OkJAIEdEO3MjIJCNm1dHCAjkiGhnbgQEsnHz6ggBgRwR7cyNgEA2bl4dISCQI6KduREQyMbNqyMEBHJEtDM3AgLZuHl1hIBAjoh25kZAIBs3r44QEMgR0c7cCAhk4+bVEQICOSLamRsBgWzcvDpCQCBHRDtzIyCQjZtXRwgI5IhoZ24EBLJx8+oIAYEcEe3MjYBANm5eHSEgkCOinbkREMjGzasjBARyRLQzNwIC2bh5dYSAQI6IduZGQCAbN6+OEBDIEdHO3AgIZOPm1RECAjki2pkbAYFs3Lw6QkAgR0Q7cyMgkI2bV0cICOSIaGduBASycfPqCAGBHBHtzI2AQDZuXh0h8A3H9CzYKca6IAAAAABJRU5ErkJggg=='
					})->status_is(200);

my $img2 =  $api_image2_tm->tx->res->json->{img};

warn $img2;

$t->get_ok('/api/diff/'.$img.'/'.$img2)->status_is(200);

done_testing();
