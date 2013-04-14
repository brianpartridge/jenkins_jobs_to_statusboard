#!/usr/bin/env ruby
require 'jenkins_api_client'

def job_order(client, job)
  status = client.job.get_current_build_status(job)

  case status
    when "failure"
      1
    when "unstable"
      2
    when "running"
      3
    when "not_run"
      4
    when "aborted"
      5
    when "success"
      6
    else
      7
  end
end

throw "Pass jenkins_ip, jenkins_port, username, and apiToken as params. You may also include an optional term to filter out." unless ARGV.length >= 4

address = ARGV[0]
port = ARGV[1]
username = ARGV[2]
apiToken = ARGV[3]
outputPath = ARGV[4]
filterTerm = ARGV[5]

client = JenkinsApi::Client.new(:server_ip => address, :server_port => port,
                                :username => username, :password => apiToken)

file = File.new(outputPath || "jenkins.html", "w+")
file.puts "<table>"

jobs = client.job.list_all
if filterTerm
    jobs = jobs.delete_if { |x| x.include? filterTerm }
end
jobs = jobs.sort { |x, y| job_order(client, x) <=> job_order(client, y) }
jobs.each do |job|
  status = client.job.get_current_build_status(job)
  file.puts "<tr><td width='50'><img width='32' height='32' src='http://#{address}/JenkinsStatusBoardIcons/#{status}@2x.png'/></td><td>#{job}</td></tr>"
end
file.puts "</table>"

file.close()

