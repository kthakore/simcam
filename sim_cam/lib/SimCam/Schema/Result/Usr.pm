use utf8;
package SimCam::Schema::Result::Usr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SimCam::Schema::Result::Usr

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

=head1 TABLE: C<Usrs>

=cut

__PACKAGE__->table("Usrs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  default_value: 'D'
  is_nullable: 0
  size: 3

=head2 current_session

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 json_store

  data_type: 'text'
  is_nullable: 1

=head2 study

  data_type: 'varchar'
  default_value: 'CV'
  is_nullable: 0
  size: 3

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "type",
  { data_type => "varchar", default_value => "D", is_nullable => 0, size => 3 },
  "current_session",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "json_store",
  { data_type => "text", is_nullable => 1 },
  "study",
  { data_type => "varchar", default_value => "CV", is_nullable => 0, size => 3 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 sessions

Type: has_many

Related object: L<SimCam::Schema::Result::Session>

=cut

__PACKAGE__->has_many(
  "sessions",
  "SimCam::Schema::Result::Session",
  { "foreign.usr_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-18 11:32:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CSGc0DKezAmvyS0YsvZdrA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
