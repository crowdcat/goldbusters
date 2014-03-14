############# this is the part that pings job id and gets json #############
require 'json'
require 'crowdflower'
require 'nokogiri'

job_id = ARGV[0].to_s # job that wiil be made into a golddigging job

auth_key = "5b7d73e5e7eb06556f12b45f87b013fc419f45f2"
domain_base = "https://api.crowdflower.com/"

CrowdFlower::Job.connect! auth_key, domain_base


def download_json(job_id, auth_key)
        filename = "/tmp/job_#{job_id}.json"
        json = `curl https://api.crowdflower.com/v1/jobs/#{job_id}.json?key=#{auth_key}`
        #parsed_json = JSON.parse(json)
    return json
end

original_json = download_json(job_id, auth_key)

# f = File.new('~/Documents/new_goldbuster_app/json_file_'+job_id+'.json', 'w')
# f.puts original_json
# f.close
#json.dumps(original_json, '~/Documents/new_goldbuster_app/json_file_'+job_id+'.json')
puts original_json


# the test id 363910