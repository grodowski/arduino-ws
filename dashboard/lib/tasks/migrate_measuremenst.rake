desc 'migrate existing measurements from embedded to referenced documents'
task migrate_measurements: :environment do
  db = Mongoid::Sessions.default
  counter = 0

  db[:sensors].find.each do |sensor|
    puts "Processing sensor #{sensor[:device_uid]}"

    sensor[:measurements].each do |m|
      db[:measurements].insert sensor_id: sensor[:_id],
                               temp_c: m[:temp_c],
                               created_at: m[:created_at],
                               updated_at: m[:updated_at]
      counter += 1
    end
    puts "Done."
  end

  puts "Remove measurements from sensors collection schema"
  db[:sensors].find.update_all({'$unset' => {'measurements' => 1}})

  puts "Done. Updated #{counter} measurements."
end