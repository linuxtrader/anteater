#!/usr/bin/perl

# videoexport.pl v14feb2011

# Userjob Called from mythtv backend with
# starttime=%STARTTIME% chanid=%CHANID% dir=%DIR% devices=%PLAYGROUP% 2>&1 > /tmp/mp4.$$err


# Original By Justin Hornsby 27 July 2007
# Many player formats and mythtv interactions added by Dan Rose
# Converted to handBrake
# 
# A MythTV user job script for exporting MythTV recordings to iphone and other formats
#
# Contains elements of mythtv.pl by Nigel Pearson
# Initial idea from nuvexport
#
# PERL MODULES WE WILL BE USING
use DBI;
use DBD::mysql;
use MythTV;

#  Set default values

#  Scratch area for doing conversion 
my $exportdir = '/home/mythtv';

#  may be NFS mounted storage:  rss is served here via apache2, this dir is served by mythbackend
my $appledir = '/var/lib/mythtv/videos/apple';
my $rssemptydir = $appledir."/.empty";

# These are not normally used
my $bitrate = '128k';
my $aspect = '4:3';
my $size = '640x480';

$debug = 0;

##################################
#                                #
#    Main code starts here !!    #
#                                #
##################################

#Most of this is the old usage info, it is not current.
$usage = "\nHow to use videoexport.pl : \n"
        ."videoexport.pl exportdir=/foo/bar starttime=%STARTTIME% chanid=%CHANID \n"
        ."\n%CHANID% = channel ID associated with the recording to export\n"
        ."%STARTTIME% = recording start time in either 'yyyy-mm-dd hh:mm:ss' or 'yyyymmddhhmmss' format\n"
        ."exportdir = dir to export completed MP4 files to (note the user the script runs as must have write permission on that dir\n"
        ."debug = enable debugging information - outputs which commands would be run etc\n"
        ."\nExample: videoexport.pl exportdir=/home/juski starttime=20060803205900 chanid=1006 size=320x340 aspect=16:9 bitrate=192 debug \n";

#
# Get all the arguments
#

foreach (@ARGV){
    if ($_ =~ m/debug/) {
        $debug = 1;
    }
    elsif ($_ =~ m/size/) {
        $size = (split(/\=/,$_))[1];
    }
    elsif ($_ =~ m/aspect/) {
        $aspect = (split(/\=/,$_))[1];
    }
    elsif ($_ =~ m/bitrate/) {
        $bitrate = (split(/\=/,$_))[1];
    }
    elsif ($_ =~ m/dir/) {
        $dir = (split(/\=/,$_))[1];
    }
    elsif ($_ =~ m/starttime/) {
        $starttime = (split(/\=/,$_))[1];
    }
    elsif ($_ =~ m/chanid/) {
        $chanid = (split(/\=/,$_))[1];
    }
    elsif ($_ =~ m/devices/) {
        $devlist = (split(/\=/,$_))[1];
        @devices=split(',', $devlist);
    }
    elsif ($_ =~ m/exportdir/) {
        $exportdir = (split(/\=/,$_))[1];
    }
}


#
#
my $myth = new MythTV();
# connect to database
$connect = $myth->{'dbh'};

# GENERAL INFO QUERY
# chanid=2681  for channel 68.1,  2211 = 21
$query = "SELECT title, subtitle, description FROM recorded WHERE chanid=$chanid AND starttime='$starttime'";
$query_handle = $connect->prepare($query);
$query_handle->execute() || die "Cannot connect to database \n";

# GENERAL INFO bind table columns to variables
$query_handle->bind_columns(undef, \$title, \$subtitle, \$description);

# GENERAL INFO loop through results
$query_handle->fetch();

# CHANNEL NAME QUERY
$query = "SELECT callsign FROM channel WHERE chanid=$chanid";
$query_handle = $connect->prepare($query);
$query_handle->execute()  || die "Unable to query chanid table";
my ($channame) = $query_handle->fetchrow_array;

# SERIES VS MOVIE QUERY
$query = "SELECT category_type, originalairdate, airdate FROM recordedprogram WHERE chanid=$chanid AND starttime='$starttime'";
$query_handle = $connect->prepare($query);
$query_handle->execute()  || die "Unable to query category_type table";
$query_handle->bind_columns(undef, \$type, \$origdate, \$airdate);
$query_handle->fetch();

if ($type eq 'movie')     { 
  $showdate=$airdate;
} else {
  $showdate=substr($origdate, 2, 9);
}

# replace whitespace in CHANNAME with dashes
# not actually needed on the callsign
$channame =~ s/\s+/-/g;

# Simply remove certain chars from the TITLE
$title =~ s/[;:?!.'\$]//g;
# keep full name for RSS feed titles
$TITLE=$title;
# Plus replace non-word characters in TITLE with underscores
$title =~ s/\W+/_/g;
# But PCs need short titles
#$title =~ s/\W+//g;

$subtitle =~ s/[;:?!.'\$]//g;
# limit length of the SUBTITLE
$subtitle=substr($subtitle, 0, 75);
# Plus replace non-word characters in SUBTITLE with underscores
$subtitle =~ s/\W+/_/g;
# But PCs may need short titles
#$subtitle =~ s/\W+//g;

# replace non-word characters in DESC with underscores
$description =~ s/[;:?!.'\$]//g;
$description =~ s/\W+/_/g;
# limit length of the description
$description=substr($description, 0, 75);


# Remove non alphanumeric chars from $starttime & $endtime
$newstarttime = $starttime;
$newstarttime =~ s/[|^\W|\s|-|]//g;

# orginal file, still has commercials unless we cut them out with transcode
#$ofilename = $dir."/".$chanid."_".$newstarttime.".mpg";

#Drop the 
$title =~ s/^The_//;

# shorten the title of all series recordings
if ($type eq 'series')     { 

   #if ($title =~ /^(.)[a-z,A-Z]*$/) { $title="$1";},  hard to distinguish with only one letter
   if ($title =~ /^[a-z,A-Z]*$/) { $title=substr($title, 0, 10);}
   if ($title =~ /^([a-z,A-Z]*)_(.)[a-z,A-Z]*$/) { $title="$1$2";}
   if ($title =~ /^([a-z,A-Z]*)_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*$/) { $title="$1$2$3";}
   if ($title =~ /^([a-z,A-Z]*)_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*$/) { $title="$1$2$3$4";}
   if ($title =~ /^([a-z,A-Z]*)_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*$/) { $title="$1$2$3$4$5";}
   if ($title =~ /^([a-z,A-Z]*)_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*$/) { $title="$1$2$3$4$5$6";}
   if ($title =~ /^([a-z,A-Z]*)_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*_(.)[a-z,A-Z]*/) { $title="$1$2$3$4$5$6$7";}
   
   $title =~ tr/a-z/A-Z/;
}
#old method
#if ($title =~ /^George[_, ]Lopez/) { $title="GL"; } 
#if ($title =~ /^Burn[_, ]Notice/)  { $title="BN"; } 
#if ($title =~ /^Cold[_, ]Case/)    { $title="CC"; } 
#if ($title =~ /^Hannah[_, ]Montana/)    { $title="HM"; } 
#if ($title =~ /^How[_, ]It[_, ]s[_, ]Made/)    { $title="HIM"; } 
#if ($title =~ /^What[_, ]Not[_, ][T,t]o[_, ]Wear/)    { $title="WNTW"; } 
#if ($title =~ /^The[_, ]Secret[_, ]Life[_, ].*/)    { $title="TSLOTAT"; } 

# Ouch, some series have no subtitle, but desc IS unique, example How its Made
# If series and no subtitle, then use shortened description
# Though we ignore most series episodes that dont have a subtitle already
# Others are sports, tvshow, movies
if (($type eq 'series') && ($subtitle eq '')) { $subtitle="$description"; }


# TITLE AND SUBTITLE FINALLY DEFINED

# Our scratch file w/o commercials, and timestamp
$filename = $exportdir."/".$title."_".$subtitle.".src";
$startjob = $exportdir."/".$title."_".$subtitle.".starttime";


# These are movie formats.
$zenfilename  = $exportdir."/".$title."[".$showdate.".".$channame."]".$subtitle.".avi";
$pspfilename  = $exportdir."/".$title."[".$showdate.".".$channame."]".$subtitle.".MP4";
$mp4filename  = $exportdir."/".$title."[".$showdate.".".$channame."]".$subtitle.".AVI";
$amvfilename  = $exportdir."/".$title."[".$showdate.".".$channame."]".$subtitle.".amv";
$ipodout      = $exportdir."/".$title.$subtitle.".mp4";

if ($debug) { print "\n\n Source filename:$filename \nDestination filename:$ipodout\n \n"; }


#Must decide audience before determining type like movie or series
foreach $dev (@devices){
 if ($dev eq 'FAMILY' || $dev eq 'family') { 
   $appledir = $appledir."/family";
 }

 if ($dev eq 'TEEN' || $dev eq 'teen') { 
   $appledir = $appledir."/teen";
 }
}

if ($type eq 'series')     { 
   $appledir = $appledir."/".$title;
   $ipodout  = $exportdir."/".$title.".".$subtitle.".mp4";
} else {
   #we watch mostly series and movies, but it could be other things. to be continued...
   $appledir = $appledir."/movies/";
}


# GET THE INPUT FILE and CHECK IT

# Fetch a scratch copy minus commercials
# -l = --honorcutlist
system "/usr/bin/mythtranscode -c $chanid -s $starttime -p autodetect -l -o $filename";

# Check this scratch file for audio style. Is it with Dolby or without, one stereo or two.
# no longer 34,35, or 81,81 cause transcode to generate scratch file already reordered the file.
# Must run this here before the commands are defined or they capture prior values.
# shift 8 to get actual return code
# ffmpeg is faster, but hand -t is accurate with respect to order, see add_audio_to_title, and + audio tracks.

#  Select the first audio track unless we determine otherwise,
#  Like when mythtranscode orders the audio tracks differently for some shows with dual stereo tracks.

$audio = 1;
$cleanup = "/bin/rm -f $filename $filename.map $startjob";


system ("/usr/bin/ffmpeg -i $filename 2>&1 |grep Audio| grep -q '5.1'");
if ( ( $? >> 8 ) == 0 ) # Then Dolby is present. 
{ 
  # Which channel has Dolby according to handbrake
  # Rarely hand sees 2x stereo when ffmpeg saw dolby, so audio is cleared. 
  $audio = `/usr/bin/hand -t 0 --input $filename 2>&1|grep Hz|grep +|grep '5.1'|cut -c7`;
  chomp($audio);
}
else  # Dolby is NOT present 
{ 
  system ("/usr/bin/ffmpeg -i $filename 2>&1 |grep Audio| grep -q mono");
  if ( ( $? >> 8 ) == 0 ) # Then mono is present
  { 
    # Which channel is not mono, if hand agrees with ffmpeg.
    $audio = `/usr/bin/hand -t 0 --input $filename 2>&1|grep Hz|grep +|grep -v '1.0'|cut -c7`;
    chomp($audio);
  }
  else # Are two or more channels in stereo
  {
    $tct = `/usr/bin/ffmpeg -i $filename 2>&1 |grep Audio| grep stereo|wc -l`;
    chomp($tct);
    if ( $tct >= 2 ) 
    {
      #So just combine audio tracks since probably one of them is silence.
      #$audio = "1,2";

      #$cleanup = "/bin/rm -f           $filename.map $startjob";
      #Test each track for silence
      $audio = `/usr/local/sbin/soundchk $filename`;
      chomp($audio);

      #system ("/usr/bin/ffmpeg -i $filename 2>&1 |grep Audio| grep 0.1|grep -q 0x80");
      #if ( ( $? >> 8 ) == 0 )  # If stereo channels are reordered and program stream.
      #{ $audio = 2; }
      #else
      #{ $audio = 1; }
    }
  }
}

#On rare occasion, hand cant find it.
if ( $audio == "") {$audio = 1;}


# DEFINE CONVERSIONS based on above checks

# mencoder makes avi for Zen
#-ss 10   #start after 10 seconds
#-endpos  #stop after this time or size

#Creative ZEN Vision, works great, but slower, run last
my $zendir = $appledir;
$zendir =~ s/apple/zen/;
my $zenfilename = $ipodout;
$zenfilename =~ s/mp4$/avi/;
$command1 = "nice -n19 mencoder -quiet $filename -oac mp3lame -lameopts cbr:br=128 -ovc xvid -xvidencopts bitrate=1000:chroma_opt:vhq=4:quant_type=mpeg -vf pp=de,scale=320:240 -o '$zenfilename' 2>&1 >/tmp/zen.err;mkdir -p $zendir;mv $zenfilename $zendir";

#Iphone format works for PSP , use instead.
#Sony PSP, wish could spread this line out more readable
#$commandP = "nice -19 mencoder $filename -quiet -sws 9 -af volume=10:0 -vf pullup,softskip,dsize=480:272,scale=0:0,harddup,unsharp=l3x3:0.7 -ofps 24000/1001 -oac faac -faacopts br=128:mpeg=4:object=2:raw -channels 2 -srate 48000 -ovc x264 -x264encopts bitrate=500:global_header:partitions=all:trellis=1:level_idc=30 -of lavf -lavfopts format=psp -info name=”$subtitle” -o '$pspfilename'  2>&1 >/tmp/psp.err;mv $pspfilename /var/www";

#Pixxo mencoder, quick converts so run first
$command2 = "nice -n19 mencoder -quiet -noodml $filename -of avi -vf-pre rotate=0 -vf-add scale=176:224 -vf-add expand=176:224:-1:-1:1 -oac lavc -lavcopts acodec=mp2:abitrate=96 -srate 44100 -af volume=8 -ovc xvid -xvidencopts bitrate=600:max_bframes=0:quant_type=h263:me_quality=4 -ofps 20 -o '$mp4filename' 2>&1 >>/tmp/ipod.err;mkdir -p $exportdir/ToPixxo; mv $mp4filename $exportdir/ToPixxo";

#AMV very cheap players, 
#or or 160x128, 
#$command3c = "nice -n19 /var/tmp/ffmpeg_amv -i $filename -y -f amv -s 160x120 -r 16 -qmin 3 -qmax 3 -ac 1 -ar 22050 '$amvfilename' 2>&1 >>/tmp/ipod.err";

#Apple
#Iphone3g format works for PSP also.
#Iphone3g, or older itouch, using 0.9.3 handbrake or better 
# 
# Seems 80 is preferred over 81, and dolby over stereo,
# But 81 is added first by mythtranscode if the sources were listed as 34,35 instead of 80,81 internally.
# And Anything, like Dolby, is better than mono track.
#
# Default audio 1, 5.1 Dolby, for NOOF, channel 8,  on Dec 4th, and works better cause
# other channel, audio 2, was mono to start with, weather talk
# Or instead could trigger based on channel 8, or on dont pick mono channel
# or always pick the 5.1 Dobly Pro Logic,  which downsamples to mono for iphone.
# Except for shows that have stereo vs stereo. English is normally first.
# But also broke Frasier, on this exact date, which uses 34,35 instead of 80,81 
# cause mythtranscode orders 81 as first, and has no sound, if Dolby is present.
# So if x80 is not first, then select audio to source 2, unless Dolby is present, logic added above.
#
# Also fixed single episode of The Event where stereo produced no sound and 5.1 Dobly had sound.
# ..also might have to chop first minute off the recording if audio stream is corrupt.
# intend to right a user job, chop1.
# 
#iphone 3G and above, plays on nexus and other android players too.
#$command3 = "nice -n19 /usr/bin/hand --preset=\"iPhone & iPod Touch\" --maxWidth 960 --cpu 1 --audio $audio --input $filename --output '$ipodout' --format mp4;mkdir -p $appledir;mv $ipodout $appledir";
$command3 = "nice -n19 /usr/bin/hand -e x264  -q 20.0 -a $audio -E faac -B 128 -6 dpl2 -R 48 -D 0.0 -f mp4 -X 960 -m -x cabac=0:ref=2:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0 --cpu 1 --input $filename --output '$ipodout' ;mkdir -p $appledir;mv $ipodout $appledir";

#For iphone 4 and above in 0.9.4 of handbrake only
# Runs too long and creates very large files.
#$command3 = "nice -n19 /usr/bin/hand --preset=\"AppleTV\"              --cpu 1 --audio $audio --input $filename --output '$ipodout' --format mp4;mkdir -p $appledir;mv $ipodout $appledir";

# -croptop 2
#$command3 = "nice -n19 ffmpeg -i $filename -f mp4 -vcodec mpeg4 -b 1000k -qmin 3 -qmax 5 -g 300 -acodec aac -ab 128k -s 320x240 -aspect 4:3 '$ipodout'  2>&1 >>/tmp/ipod.err;mv $ipodout $appledir";


$rssload = "if [ ! -e $appledir/index.php ]; then cp -pr $rssemptydir/* $appledir; sed -i 's/SERIES/$TITLE/' $appledir/index.php; fi";

# START CONVERSIONS

# Timestamp the transcode start for debugging
system "/usr/bin/touch $startjob";

# Each conversion to do
foreach $dev (@devices){

 if ($dev eq 'Default')     { system "$command3"; system "$rssload";}  #iPhone .mp4
 if ($dev eq 'iphone')      { system "$command3"; system "$rssload";}  #iPhone .mp4
 if ($dev eq 'itouch')      { system "$command3"; system "$rssload";}  #iTouch .mp4
 if ($dev eq 'iphone4')     { system "$command4"; system "$rssload";}  #iPhone .mp4
 if ($dev eq 'zen')         { system "$command1"; }  #Zen    .avi
 if ($dev eq 'pixxo')       { system "$command2"; }  #Pixxo  .AVI

}

# Finished, so MARK SHOW AS WATCHED, and AUTOEXPIRE candidate.
# so it can be deleted and not record this episode again.
# File deletion (autoexpire candidate),too soon can mark the job as finished, launches the next job
# and potentially have too many running at once.

# Probably the original connection (above)has expired, make a new one...
$connect = $myth->{'dbh'};
$query = "UPDATE recorded set watched=1,autoexpire=1 WHERE chanid=$chanid AND starttime='$starttime'";

# OR NOT WATCHed, no-AUTOEXPIRE if override was selected
foreach $dev (@devices){
 if ($dev eq 'no_autoexpire') { 
   $query = "UPDATE recorded set watched=0,autoexpire=0 WHERE chanid=$chanid AND starttime='$starttime'";
 }
}
#Done with @devices for this job.  Could reset devices to default here, but might affect other jobs, or job rerun.
$query_handle = $connect->prepare($query);
$query_handle->execute();

# Clean up 
# conditional cleanup decided above
 system "$cleanup";
#system "/bin/rm -f $filename $filename.map $startjob";
#system "/bin/rm -f           $filename.map $startjob";
