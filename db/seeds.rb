# AuthorAffiliation.delete_all
# Keyword.delete_all
# AbstractAuthor.delete_all
# Author.delete_all
# Affiliation.delete_all
# Abstract.delete_all
Presentation.delete_all
Room.delete_all

# Keyword.create([
#     { keyword_name:"Analytical Methods", keyword_category:"1" },
#     { keyword_name:"Forest Structure and Biomass", keyword_category:"1" },
#     { keyword_name:"Forest Cover & Biomass Change", keyword_category:"1" },
#     { keyword_name:"Characterizing Uncertainty", keyword_category:"1" },
#     { keyword_name:"Climate-Vegetation Interactions", keyword_category:"1" },
#     { keyword_name:"Land and Forest Cover Mapping", keyword_category:"1" },
#     { keyword_name:"Deforestation & Land Use Change", keyword_category:"1" },
#     { keyword_name:"Disturbance", keyword_category:"1" },
#     { keyword_name:"Fire Dynamics and Impacts", keyword_category:"1" },
#     { keyword_name:"Forest Health", keyword_category:"1" },
#     { keyword_name:"Forest Monitoring", keyword_category:"1" },
#     { keyword_name:"Habitat and Biodiversity", keyword_category:"1" },
#     { keyword_name:"Forest Composition and Traits", keyword_category:"1" },
#     { keyword_name:"Function and Physiology", keyword_category:"1" },
#     { keyword_name:"Large Area Mapping", keyword_category:"1" },
#     { keyword_name:"Recovery and Growth", keyword_category:"1" },
#     { keyword_name:"Sampling & Estimation", keyword_category:"1" },
#     { keyword_name:"Science & Decision Support", keyword_category:"1" },
#     { keyword_name:"Carbon and Water Cycling", keyword_category:"1" },
#     { keyword_name:"In Situ Measurements", keyword_category:"1" },
#     { keyword_name:"UAVs and New Technologies", keyword_category:"1" },
#     { keyword_name:"Multi- and Hyperspectral Remote Sensing", keyword_category:"1" },
#     { keyword_name:"Radar Remote Sensing", keyword_category:"1" },
#     { keyword_name:"Lidar Remote Sensing", keyword_category:"1" }
# ])

# Author.create([
#     { firstname:"Jeffrey", lastname:"Masek", user_id:nil }
#     # { firstname:"George", lastname:"Bush", user_id:nil },
#     # { firstname:"Jimmy", lastname:"Carter", user_id:nil },
#     # { firstname:"Donald", lastname:"Trump", user_id:nil },
#     # { firstname:"Barak", lastname:"Obama", user_id:nil }
# ])

# Affiliation.create([
#     { institution:"NASA", department:"Goddard" }
#     # { institution:"Texas Tech", department:"Business" },
#     # { institution:"Georgia Tech", department:"Engineering" },
#     # { institution:"NYU", department:"Real Estate" },
#     # { institution:"Yale University", department:"Law" }
# ])

# AuthorAffiliation.create([
#     { author_id:"1", affiliation_id:"1" }
#     # { author_id:"2", affiliation_id:"2" },
#     # { author_id:"3", affiliation_id:"3" },
#     # { author_id:"4", affiliation_id:"4" },
#     # { author_id:"5", affiliation_id:"5" },
# ])

Room.create([
    { room_name:"R100", room_type:"conference", room_floor:"1" },
    { room_name:"R200", room_type:"conference", room_floor:"2" }
])

default_author = Author.all.first
default_author_id = default_author[:id]
default_room = Room.all.first
default_room_id = default_room[:id]
puts "\ndefault_author: #{default_author.inspect}"
puts "default_author_id: #{default_author_id.inspect}"
puts "\ndefault_room: #{default_room.inspect}"
puts "default_room_id: #{default_room_id.inspect}"

Presentation.create!([
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Forests in the Global Carbon Cycle (Fischer/Huth)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Forest Biodiversity (Chirici/McRoberts)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Remote Sensing for GHG Inventories (McRoberts/Naesset)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Forest Carbon MRV (Poulter/Hurtt/Pederson/Pugh)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Near Real-Time Monitoring (Reiche/Herold)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Plantation Management with High-Resolution RS (Pang)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Early Detection of Plant Stress (Suarez)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Mangroves (Lucas)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Monitoring Tropical Forest Dynamics (Hansen)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Next Generation Large-area Forest Monitoring (Wulder/Healey)", session_start:nil },
    { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Terrestrial Laser Scanning (Disney/Schaaf)", session_start:nil }
])

default_session = Presentation.all.first
default_session_id = default_session[:id]
puts "\ndefault_session: #{default_session.inspect}"
puts "default_session_id: #{default_session_id.inspect}"
