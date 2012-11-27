use utf8;
package SimCam::Schema::Result::Camera;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SimCam::Schema::Result::Camera

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Helper::Row::ToJSON>

=item * L<DBIx::Class::Helper::ResultSet::Random>

=back

=cut

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "Helper::Row::ToJSON",
  "Helper::ResultSet::Random",
);

=head1 TABLE: C<Camera>

=cut

__PACKAGE__->table("Camera");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 alpha

  data_type: 'real'
  is_nullable: 1

=head2 near

  data_type: 'real'
  is_nullable: 1

=head2 far

  data_type: 'real'
  is_nullable: 1

=head2 final_image

  data_type: 'text'
  is_nullable: 1

=head2 fov

  data_type: 'real'
  is_nullable: 1

=head2 image

  data_type: 'text'
  is_nullable: 1

=head2 job_id

  data_type: 'integer'
  is_nullable: 1

=head2 p_x

  data_type: 'real'
  is_nullable: 1

=head2 p_y

  data_type: 'real'
  is_nullable: 1

=head2 p_z

  data_type: 'real'
  is_nullable: 1

=head2 r1

  data_type: 'real'
  is_nullable: 1

=head2 r2

  data_type: 'real'
  is_nullable: 1

=head2 r3

  data_type: 'real'
  is_nullable: 1

=head2 r_x

  data_type: 'real'
  is_nullable: 1

=head2 r_y

  data_type: 'real'
  is_nullable: 1

=head2 r_z

  data_type: 'real'
  is_nullable: 1

=head2 success

  data_type: 'integer'
  is_nullable: 1

=head2 t1

  data_type: 'real'
  is_nullable: 1

=head2 t2

  data_type: 'real'
  is_nullable: 1

=head2 u

  data_type: 'real'
  is_nullable: 1

=head2 v

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "alpha",
  { data_type => "real", is_nullable => 1 },
  "near",
  { data_type => "real", is_nullable => 1 },
  "far",
  { data_type => "real", is_nullable => 1 },
  "final_image",
  { data_type => "text", is_nullable => 1 },
  "fov",
  { data_type => "real", is_nullable => 1 },
  "image",
  { data_type => "text", is_nullable => 1 },
  "job_id",
  { data_type => "integer", is_nullable => 1 },
  "p_x",
  { data_type => "real", is_nullable => 1 },
  "p_y",
  { data_type => "real", is_nullable => 1 },
  "p_z",
  { data_type => "real", is_nullable => 1 },
  "r1",
  { data_type => "real", is_nullable => 1 },
  "r2",
  { data_type => "real", is_nullable => 1 },
  "r3",
  { data_type => "real", is_nullable => 1 },
  "r_x",
  { data_type => "real", is_nullable => 1 },
  "r_y",
  { data_type => "real", is_nullable => 1 },
  "r_z",
  { data_type => "real", is_nullable => 1 },
  "success",
  { data_type => "integer", is_nullable => 1 },
  "t1",
  { data_type => "real", is_nullable => 1 },
  "t2",
  { data_type => "real", is_nullable => 1 },
  "u",
  { data_type => "real", is_nullable => 1 },
  "v",
  { data_type => "real", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2012-11-27 15:17:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:owjdVokJn2X/j5NVWHjYWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
