# == session_org_id, session_chair_id, room_id, session_type, session_title, session_start
# start_array = []
# start_date = 3
# while start_date < 6
#     (9..16).each do |h|
#         session_start = ""
#         if h < 10
#             h = "0" + h.to_s
#         elsif h > 12
#             h = "0" + (h - 12).to_s
#         end
#         puts "h: #{h.inspect}"
#         session_start += h.to_s + ":"
#         puts "session_start: #{session_start.inspect}"
#         (0..40).step(20) do |m|
#             if m < 10
#                 m = "0" + m.to_s
#             end
#             date_string = "0" + start_date.to_s +  "-Oct-2018 " + session_start + m.to_s + ":00"
#             puts "date_string: #{date_string.inspect}"
#             start_array << date_string
#         end
#     end
#     start_date = start_date + 1
# end
# # session_start = DateTime.parse("3-Oct-2018 " + session_start)
# puts "start_array: #{start_array.inspect}"

# session_array = ["Forests in Space and Time (Fischer)",
# "Forest Biodiversity (Chirici)",
# "Remote Sensing for GHG Inventories (McRoberts)",
# "Forest Functional Traits/Spectroscopy (Townsend)",
# "Forest Carbon MRV (Poulter)",
# "Near Real-Time Monitoring (Reiche)",
# "Early Detection of Plant Stress (Suarez)",
# "Mangroves (Lucas)",
# "Monitoring Tropical Forest Dynamics (Hansen)",
# "Sensor Fusion for Global Forest Structure (Healey)",
# "Terrestrial Laser Scanning (Disney)",
# "Other/Plenary"]
#
# session_data_array = []
# session_array.each_with_index do |session, index|
#     session_object = { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"", session_start:nil }
#     session_object[:session_org_id] = index
#     session_object[:session_title] = session
#     session_data_array << session_object
#     session_object = {}
# end
# puts "session_data_array: #{session_data_array.inspect}"

# [
# {:session_org_id=>11, :session_chair_id=>nil, :room_id=>nil, :session_type=>"special", :session_title=>"Other/Plenary", :session_start=>nil}
# ]
