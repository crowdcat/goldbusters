###### update title

require 'json'
require 'crowdflower'
require 'nokogiri'

# get job id and new instructions
new_job_id = ARGV[0].to_s # job that wiil be made into a golddigging job
new_cml = ARGV[1].to_s

auth_key = "5b7d73e5e7eb06556f12b45f87b013fc419f45f2"
domain_base = "https://api.crowdflower.com/"

CrowdFlower::Job.connect! auth_key, domain_base
new_job_resource = CrowdFlower::Job.new(new_job_id)

new_job_resource.update({:cml => new_cml})