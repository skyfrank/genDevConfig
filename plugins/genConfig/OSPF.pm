# -*-perl-*-
#    genDevConfig plugin module
#
#    Copyright (C) 2013 Francois Mikus
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

package OSPF;

use strict;

use Common::Log;
use genConfig::Utils;
use genConfig::File;
use genConfig::SNMP;

### Start package init

use genConfig::Plugin;

our @ISA = qw(genConfig::Plugin);

my $VERSION = 1.00;

### End package init

my %ospfSpfRuns;

# These are the OIDS used by this plugin
# the OIDS should only be those necessary for index mapping or
# recognizing if a feature is supported or not by the device.
my %OIDS = (

       # OIDs for RFC 1850 Number of OSPF runs, indicator of routing stability
       'ospfSpfRuns' => '1.3.6.1.2.1.14.2.1.4',
    );

###############################################################################
## These are device types we can handle in this plugin
## the names should be contained in the sysdescr string
## returned by the devices. The name is a regular expression.
################################################################################
my @types = ( "",
            );


###############################################################################
### Private variables
###############################################################################

my $snmp;
my $script = "OSPF genDevConfig Module";
my $module = "OSPF";

###############################################################################
###############################################################################

#-------------------------------------------------------------------------------
# plugin_name
# IN : N/A
# OUT: returns the name of the plugin
#-------------------------------------------------------------------------------

sub plugin_name {
    my $self = shift;
    return $script;
}

#-------------------------------------------------------------------------------
# device_types
# IN : N/A
# OUT: returns an array ref of devices this plugin can handle
#-------------------------------------------------------------------------------

sub device_types {
    my $self = shift;
    return \@types;
}

#-------------------------------------------------------------------------------
# can_handle
# IN : opts reference
# OUT: returns a true if the device can be handled by this plugin
#-------------------------------------------------------------------------------

sub can_handle {
    my($self, $opts) = @_;
    
    Debug ("Trying to see if OID ospfSpfRuns is supported : " . $OIDS{ospfSpfRuns});
    ### Add our OIDs to the the global OID list

    register_oids(%OIDS);
    Debug ("$module Type : check ospfRuns");

    %ospfSpfRuns     = gettable('ospfSpfRuns');
    return 1 if ( %ospfSpfRuns );
    return 0;
}

#-------------------------------------------------------------------------------
# discover
# IN : options reference
# OUT: N/A
#-------------------------------------------------------------------------------

sub discover {
    my($self, $opts) = @_;



    ###
    ### START DEVICE DISCOVERY SECTION
    ###

    if ($opts->{req_ospfruns} eq 1) {
        $opts->{ospfruns} = 1;
    }
    ### Figure out the OS version number this device is running.  
    ### We need this to figure out which oid to use to get
    ### interface descriptions and which
    ### MIBs are supported.
    
    return;
}

#-------------------------------------------------------------------------------
# custom_targets
# IN : data reference for transient data, options reference
# OUT: N/A
#-------------------------------------------------------------------------------

sub custom_targets {
    my ($self,$data,$opts) = @_;
        
    # Saving local copies of runtime data
    my %ifspeed    = %{$data->{ifspeed}};
    my %ifdescr    = %{$data->{ifdescr}};
    my %intdescr   = %{$data->{intdescr}};
    my %iftype     = %{$data->{iftype}};
    my %ifmtu      = %{$data->{ifmtu}};
    my %slotPortMapping   = %{$data->{slotPortMapping}};
    my $file = $opts->{file};

    # Skip generating OSPF MIB-II targets if overriden by another plugin
    return if (!$opts->{ospfruns} == 1);
    
    ###
    ### START DEVICE CUSTOM CONFIG SECTION
    ###
    if ( %ospfSpfRuns ) {
        foreach my $key ( keys %ospfSpfRuns ) {
            Debug("OSPF spfruns table key: " . $key . "value: " .$ospfSpfRuns{$key});
            next if ($ospfSpfRuns{$key} eq 0);
            my ($a,$b,$c,$area) = split(/\./,$key);        
            my ($servicename) = "Area_" . $area . "_Number_of_SPFruns";
            my ($ldesc) = "Number of OSPF runs for area: " .$area ." <BR> Increasing numbers show instability in the routing architecture.";
            $file->writetarget("service {", '',
                'service_description'  => $servicename,
                'display_name'         => $servicename,
                'host_name'            => $opts->{devicename},
                '_inst'                => $key,
                '_triggergroup'        => 'ospf',
                '_display_order'       => $opts->{order},
                'use'                  => $opts->{dtemplate},
                'notes'                => $ldesc,
                '_dstemplate'          => 'routing-ospf-spfruns'
            );
            $opts->{order} -= 1;
        }
    }
      
    ###
    ### END DEVICE CUSTOM CONFIG SECTION
    ###

    # Saving local copies of runtime data
    %{$data->{ifspeed}} = %ifspeed;
    %{$data->{ifdescr}} = %ifdescr;
    %{$data->{intdescr}} = %intdescr;
    %{$data->{iftype}} = %iftype;
    %{$data->{ifmtu}} = %ifmtu;
    %{$data->{slotPortMapping}} = %slotPortMapping;

    return;
}

#-------------------------------------------------------------------------------
# custom_interfaces
# IN : current ifIndex, 
#      data reference for transient data
#      options reference
# OUT: N/A
#-------------------------------------------------------------------------------

sub custom_interfaces {
    my ($self,$index,$data,$opts) = @_;

    # Saving local copies of runtime data
    my %ifspeed    = %{$data->{ifspeed}};
    my %ifdescr    = %{$data->{ifdescr}};
    my %intdescr   = %{$data->{intdescr}};
    my %iftype     = %{$data->{iftype}};
    my %ifmtu      = %{$data->{ifmtu}};
    my %slotPortMapping   = %{$data->{slotPortMapping}};
    my @config     = @{$data->{config}};
    my $hc         = $data->{hc};
    my $class      = $data->{class};
    my $match      = $data->{match};
    my $customsdesc = $data->{customsdesc};
    my $customldesc = $data->{customldesc};

    ###
    ### START DEVICE CUSTOM INTERFACE CONFIG SECTION
    ###
    
   ###
    ### END INTERFACE CUSTOM CONFIG SECTION
    ###

    # Saving local copies of runtime data
    %{$data->{ifspeed}}  = %ifspeed;
    %{$data->{ifdescr}}  = %ifdescr;
    %{$data->{intdescr}} = %intdescr;
    %{$data->{iftype}}   = %iftype;
    %{$data->{ifmtu}}    = %ifmtu;
    %{$data->{slotPortMapping}} = %slotPortMapping;
    @{$data->{config}} = @config;
    $data->{hc}     = $hc;
    $data->{class}  = $class;
    $data->{match}  = $match;
    $data->{customsdesc} = $customsdesc;
    $data->{customldesc} = $customldesc;

    return;
}

#-------------------------------------------------------------------------------
# custom_files
# IN : options hash
# OUT: returns the options hash
#-------------------------------------------------------------------------------

sub custom_files {
    my ($self,$data,$opts) = @_;

    # Saving local copies of runtime data
    my $file           = $data->{file};
    my $c              = $data->{c};
    my $target         = $data->{target};
    my @config         = @{$data->{config}};
    my $wmatch         = $data->{wmatch};

    ###
    ### START FILE CUSTOM CONFIG SECTION
    ###

    ###
    ### END FILE CUSTOM CONFIG SECTION
    ###

    # Save return value in the reference hash
    $data->{wmatch}  = $wmatch;
}

1;
