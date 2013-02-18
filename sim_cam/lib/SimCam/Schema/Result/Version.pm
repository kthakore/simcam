use utf8;
package SimCam::Schema::Result::Version;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SimCam::Schema::Result::Version

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

=head1 TABLE: C<Versions>

=cut

__PACKAGE__->table("Versions");

=head1 ACCESSORS

=head2 code

  data_type: 'float'
  is_nullable: 1

=head2 created

  data_type: 'datetime'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "code",
  { data_type => "float", is_nullable => 1 },
  "created",
  { data_type => "datetime", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-17 19:29:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VZGOPqmCOvglpRw/t0q82g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
