log_level                :info
log_location             STDOUT
node_name                'drose'
client_key               '/home/drose/.chef/drose.pem'
validation_client_name   'chef-validator'
validation_key           '.chef/validation.pem'
chef_server_url          'http://server1.home:4000'
cache_type               'BasicFile'
cache_options( :path => '/home/drose/.chef/checksums' )
current_dir = File.dirname(__FILE__)
cookbook_path ["#{current_dir}/../cookbooks", "#{current_dir}/../site-cookbooks"]
cookbook_copyright "linuxtrader, Com."
cookbook_email     "linuxtrader@gmail.com"
cookbook_license   "apachev2"
