#!/Users/zog/.rbenv/versions/2.1.5/bin/ruby

source_filepath = ARGV[0]
version_string = ARGV[1]
p ARGV
source = open source_filepath, "r"
info = source.read
source = open source_filepath, "w"

bundle = info.match /<key>CFBundleVersion<\/key>.*?<string>(.+?)<\/string>/m
bundle = bundle[1]

bundle_date, bundle_incr = bundle.split "."
new_bundle_date = Time.now.strftime "%Y%m%d"
if new_bundle_date == bundle_date
  new_bundle_incr = "%03d" % (bundle_incr.to_i + 1)
else
  new_bundle_incr = "001"
end
new_bundle = "#{new_bundle_date}.#{new_bundle_incr}"

new_info = info.gsub bundle, new_bundle

if version_string
  puts "New version: #{version_string}"
  prev_version_string = info.match /<key>CFBundleShortVersionString<\/key>.*?<string>(.+?)<\/string>/m
  prev_version_string = prev_version_string[1]
  new_info = new_info.gsub prev_version_string, version_string
end

source.write new_info

