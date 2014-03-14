########### this part copies the job and changes settings ####################

############# this is the part that pings job id and gets json #############
require 'json'
require 'crowdflower'
require 'nokogiri'

new_id = ARGV[0].to_s # job that wiil be made into a golddigging job

auth_key = "5b7d73e5e7eb06556f12b45f87b013fc419f45f2"
domain_base = "https://api.crowdflower.com/"

CrowdFlower::Job.connect! auth_key, domain_base

# grab job
new_job_resource = CrowdFlower::Job.new(new_id)

#units per assignment = 1
new_job_resource.update({:units_per_assignment => 1})
new_job_resource.update({:pages_per_assignment => 1})
#judgments per unit is 1 sharp
new_job_resource.update({:variable_judgments_mode => "none" })
# judgments per unit -> 1
new_job_resource.update({:judgments_per_unit => "1" })
#no quiz mode
new_job_resource.update({:options => {:front_load => false } })
#after gold nothing
new_job_resource.update({:options => {:after_gold => "1" } })
# reject at 0
new_job_resource.update({:options => {:reject_at => "10" } })
# warn at 0
new_job_resource.update({:options => {:warn_at => "0" } })
# reset all country restrictions, and channels, and skill requirements
new_job_resource.update({:included_countries => nil })
new_job_resource.update({:excluded_countries => nil })
#save or print out new id and status
# IMPORTANT: set requirements to golddigging crowd
new_job_resource.update({:desired_requirements => {}.to_json })
new_job_resource.update({:minimum_requirements => {:priority => 1, :skill_scores => {:goldbusters => 1}, :min_score => 1}.to_json })
# don't flag on anything
new_job_resource.update({:flag_on_rate_limit => false })
# set maximum work so 1 worker doesn't do all 100
new_job_resource.update({:max_judgments_per_worker => 30 })
new_job_resource.update({:max_judgments_per_ip => 200 })
# remove webhook
new_job_resource.update({:flag_on_rate_limit => nil })
new_job_resource.update({:auto_order => false })
# remove min account age
new_job_resource.update({:minimum_account_age_seconds => "0" })
#set compensation to smth
new_job_resource.update({:payment_cents => 20 })

# order on all channels
#curl -d 'key={api_key}&channels[0]=amt&channels[0]=sama&debit[units_count]=20' https://api.crowdflo$
`curl -H "Content-Type: application/json" -X PUT 'https://api.crowdflower.com/v1/jobs/#{new_id}/gold.json?key=#{auth_key}' -d '{"reset": true}'`
#golds per assignment = 0
new_job_resource.update({:gold_per_assignment => 0})





