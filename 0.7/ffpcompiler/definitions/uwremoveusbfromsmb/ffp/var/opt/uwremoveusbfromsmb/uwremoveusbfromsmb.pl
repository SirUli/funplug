#!/ffp/bin/perl

# Add additonal path to include paths as the Samba.pm was modified
use lib ('libs');
# Load the library
use File::Samba;

# Load the configuration file
my $smb = File::Samba->new("/etc/samba/smb.conf");
# Samba version is set to 3
$smb->version(3);
print "\n";
# Remove all USB* Shares
my @shares = $smb->listShares();
@sharerm = grep(/USBDisk/, @shares);
print "Following shares are now removed: " . join(", ", @sharerm) . "\n";
for ($i=0;$i<@sharerm;$i++){
	print "Removing: $sharerm[$i] ...";
	$smb->deleteShare($sharerm[$i]);
	print " done";
}

my @shares = $smb->listShares();
print "Following shares are now available: " . join(", ", @shares) . "\n";
# Save the configuration. Do not forget to restart samba!
$smb->save('/etc/samba/smb.conf');
