package Z3::FFI::PointerType;

use strict;
use warnings;
use Carp qw/carp/;

use FFI::Platypus;

# ABSTRACT - Z3 Opaque array type creator
our $VERSION="0.002";

use constant _pointer_size => FFI::Platypus->new->sizeof('opaque');
use constant _numeric_type => _pointer_size == 8 ? "Q" : "L";

sub ffi_custom_type_api_1 {
# arg0 = class
# arg1 = FFI::Platypus instance
# arg2 = raw type name
  my ($class, $ffi, $raw_type) = @_;
  my $z3_class = "Z3::FFI::Types::$raw_type";

  my $config = {native_type => 'opaque'};

  # This gets used to track and preserve the perl side of things while we call the native side.
  # Prevent the GC from destroying the values we point at.
  my @stack;

  $config->{perl_to_native_post} = sub {
    pop @stack;
    ();
  };

  $config->{perl_to_native} = sub {
    my $in_type = ref($_[0]);
    carp "Input type is $in_type and not type $z3_class" unless $in_type eq $z3_class || !defined($_[0]);

    if (!defined($_[0])) {
      my $pointer = pack(_numeric_type(), 0);
      push @stack, \$pointer;
      return $pointer;
    } else {
      my $pointer = pack(_numeric_type(), $$_[0]);
      push @stack, \$pointer;

    }

    my $pointers = pack((_numeric_type() x $count+1), (map {$$_} @{$_[0]}), 0);
    my $array_pointer = unpack(_numeric_type(), pack('P', $pointers));
    # Save a reference to the pointer list, and the objects themselves so they don't get GC'd
    push @stack, [ \$_[0], \$pointers ];
    return $array_pointer;
  };

  $config->{native_to_perl} = sub {
    ... # unimplemented, not needed.
  };

  return $config;
}

1;

__END__
=pod

Internal class used to translate an array of opaque objects to a pointer list for Z3

=cut
