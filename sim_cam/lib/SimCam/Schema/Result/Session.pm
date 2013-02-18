use utf8;
package SimCam::Schema::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SimCam::Schema::Result::Session

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

=head1 TABLE: C<Sessions>

=cut

__PACKAGE__->table("Sessions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 usr_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 start_time

  data_type: 'datetime'
  is_nullable: 0

=head2 end_time

  data_type: 'datetime'
  is_nullable: 1

=head2 milestone

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 json_store

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "usr_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "start_time",
  { data_type => "datetime", is_nullable => 0 },
  "end_time",
  { data_type => "datetime", is_nullable => 1 },
  "milestone",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "json_store",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 usr

Type: belongs_to

Related object: L<SimCam::Schema::Result::Usr>

=cut

__PACKAGE__->belongs_to(
  "usr",
  "SimCam::Schema::Result::Usr",
  { id => "usr_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-18 11:32:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0tpJTYxZxE5xBK91ZlkoZA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
