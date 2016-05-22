require 'net/http'
require 'OpenSSL'
def srclist
  `gem source list`.scan(/^http.*/).to_a
end
def remove x
  system "gem source -r #{x}"
end

def clear
  srclist.each{|x|
    remove x
  }    
end

def work?
  r = `gem list -r y`
  r.strip != '' 
end

def gethttps(uri)
  url = URI(uri)
   http = Net::HTTP.new(url.host, url.port)
   http.use_ssl = true
   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   request = Net::HTTP::Get.new(url.request_uri)
   response = http.request(request)
   response.body
end

def get(uri)
  url = URI(uri)
   http = Net::HTTP.new(url.host, url.port)
   request = Net::HTTP::Get.new(url.request_uri)
   response = http.request(request)
   response.body
end

def sanitize(a)
  a.gsub(/<[^>]*?>/, "").gsub("&#39", "'")
end

def tryadd(a)
     puts "* try adding #{a}"
     system "gem source -a #{a}"
end

if work?
  puts "it seemed that it already works"
else
  puts "reset source list"
  clear
  puts "repairing"
  u = get("http://www.baidu.com/s?wd=ruby%20%E6%BA%90")
  sanitize(u).scan(/http:\/\/[^'" ]*/).each{|x|
    next if x[/baidu/] || x[/bdstatic\.com/] || x[/bdimg\.com/]
    tryadd x
    if work?
       puts "problem solved"
       puts "#{x} is the source for you"
       exit!
   end
  }
 puts "problem unsolved"

end