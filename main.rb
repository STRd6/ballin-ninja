Dir[File.dirname(__FILE__) + '/app/workers/*.rb'].each do |file|
  require file
end

HardWorker.perform_async("lul", "wat")
