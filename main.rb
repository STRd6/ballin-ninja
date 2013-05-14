Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

puts "Heeey1"

HardWorker.perform_async("lul", "wat")
