Keyword.delete_all
Presentation.delete_all
Room.delete_all

Keyword.create([
    { keyword_name:"Analytical Methods", keyword_category:"1" },
    { keyword_name:"Forest Structure and Biomass", keyword_category:"1" },
    { keyword_name:"Forest Cover & Biomass Change", keyword_category:"1" },
    { keyword_name:"Characterizing Uncertainty", keyword_category:"1" },
    { keyword_name:"Climate-Vegetation Interactions", keyword_category:"1" },
    { keyword_name:"Land and Forest Cover Mapping", keyword_category:"1" },
    { keyword_name:"Deforestation & Land Use Change", keyword_category:"1" },
    { keyword_name:"Disturbance", keyword_category:"1" },
    { keyword_name:"Fire Dynamics and Impacts", keyword_category:"1" },
    { keyword_name:"Forest Health", keyword_category:"1" },
    { keyword_name:"Forest Monitoring", keyword_category:"1" },
    { keyword_name:"Habitat and Biodiversity", keyword_category:"1" },
    { keyword_name:"Forest Composition and Traits", keyword_category:"1" },
    { keyword_name:"Function and Physiology", keyword_category:"1" },
    { keyword_name:"Large Area Mapping", keyword_category:"1" },
    { keyword_name:"Recovery and Growth", keyword_category:"1" },
    { keyword_name:"Sampling & Estimation", keyword_category:"1" },
    { keyword_name:"Science & Decision Support", keyword_category:"1" },
    { keyword_name:"Carbon and Water Cycling", keyword_category:"1" },
    { keyword_name:"In Situ Measurements", keyword_category:"1" },
    { keyword_name:"UAVs and New Technologies", keyword_category:"1" },
    { keyword_name:"Multi- and Hyperspectral Remote Sensing", keyword_category:"1" },
    { keyword_name:"Radar Remote Sensing", keyword_category:"1" },
    { keyword_name:"Lidar Remote Sensing", keyword_category:"1" }
])

Room.create([
    { room_name:"R100", room_type:"conference", room_floor:"1" },
    { room_name:"R200", room_type:"conference", room_floor:"2" }
])

Presentation.create!([
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Forests in the Global Carbon Cycle (Fischer)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Forest Biodiversity (Chirici)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Remote Sensing for GHG Inventories (McRoberts)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Forest Carbon MRV (Poulter)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Near Real-Time Monitoring (Reiche)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Plantation Management With High-Resolution RS (Pang)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Early Detection of Plant Stress (Suarez)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Mangroves (Lucas)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Monitoring Tropical Forest Dynamics (Hansen)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Next Generation Large-area Forest Monitoring (Wulder)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Terrestrial Laser Scanning (Disney)", session_start:nil },
    { session_org_id:nil, session_chair_id:nil, room_id:nil, session_type:"special", session_title:"Other/Plenary", session_start:nil  }
])

default_keyword = Room.all.first
default_keyword_id = default_keyword[:id]
default_room = Room.all.first
default_room_id = default_room[:id]
default_presentation = Room.all.first
default_presentation_id = default_presentation[:id]
puts "\ndefault_keyword: #{default_keyword.inspect}"
puts "default_keyword_id: #{default_keyword_id.inspect}"
puts "\ndefault_room: #{default_room.inspect}"
puts "default_room_id: #{default_room_id.inspect}"
puts "\ndefault_presentation: #{default_presentation.inspect}"
puts "default_presentation_id: #{default_presentation_id.inspect}"


# Presentation.create!([
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Forests in the Global Carbon Cycle (Fischer)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Forest Biodiversity (Chirici)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Remote Sensing for GHG Inventories (McRoberts)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Forest Carbon MRV (Poulter)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Near Real-Time Monitoring (Reiche)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Plantation Management With High-Resolution RS (Pang)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Early Detection of Plant Stress (Suarez)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Mangroves (Lucas)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Monitoring Tropical Forest Dynamics (Hansen)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Next Generation Large-area Forest Monitoring (Wulder)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Terrestrial Laser Scanning (Disney)", session_start:nil },
#     { session_org_id:default_author_id, session_chair_id:default_author_id, room_id:default_room_id, session_type:"special", session_title:"Other/Plenary", session_start:nil  }
# ])
