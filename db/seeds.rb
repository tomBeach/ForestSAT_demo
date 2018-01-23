AuthorAffiliation.delete_all
Presentation.delete_all
Keyword.delete_all
AbstractAuthor.delete_all
Author.delete_all
Affiliation.delete_all
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

Author.create([
    { firstname:"Jeffrey", lastname:"Masek", user_id:nil }
    # { firstname:"George", lastname:"Bush", user_id:nil },
    # { firstname:"Jimmy", lastname:"Carter", user_id:nil },
    # { firstname:"Donald", lastname:"Trump", user_id:nil },
    # { firstname:"Barak", lastname:"Obama", user_id:nil }
])

Affiliation.create([
    { institution:"NASA", department:"Goddard" }
    # { institution:"Texas Tech", department:"Business" },
    # { institution:"Georgia Tech", department:"Engineering" },
    # { institution:"NYU", department:"Real Estate" },
    # { institution:"Yale University", department:"Law" }
])

AuthorAffiliation.create([
    { author_id:"1", affiliation_id:"1" }
    # { author_id:"2", affiliation_id:"2" },
    # { author_id:"3", affiliation_id:"3" },
    # { author_id:"4", affiliation_id:"4" },
    # { author_id:"5", affiliation_id:"5" },
])

Room.create([
    { room_name:"R100", room_type:"conference", room_floor:"1" },
    { room_name:"R200", room_type:"conference", room_floor:"2" }
])

Presentation.create([
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Forest Biodiversity (Chirici)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Remote Sensing for GHG Inventories (McRoberts)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Forest Functional Traits/Spectroscopy (Townsend)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Forest Carbon MRV (Poulter)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Near Real-Time Monitoring (Reiche)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Early Detection of Plant Stress (Suarez)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Mangroves (Lucas)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Monitoring Tropical Forest Dynamics (Hansen)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Sensor Fusion for Global Forest Structure (Healey)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Terrestrial Laser Scanning (Disney)", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Other/Plenary", session_start:nil },
    { session_org_id:"1", session_chair_id:"1", room_id:"1", session_type:"special", session_title:"Forests in Space and Time (Fischer)", session_start:nil  }
])

# Affiliation.delete_all
# Affiliation.create([
#     { institution:"Cornell", department:"Geology" },
#     { institution:"Texas Tech", department:"Business" },
#     { institution:"Georgia Tech", department:"Engineering" },
#     { institution:"Atlantic City", department:"Real Estate" },
#     { institution:"Yale University", department:"Law" }
# ])
#
# AuthorAffiliation.delete_all
# AuthorAffiliation.create([
#     { author_id:1, affiliation_id:1 },
#     { author_id:2, affiliation_id:2 },
#     { author_id:3, affiliation_id:3 },
#     { author_id:4, affiliation_id:4 },
#     { author_id:5, affiliation_id:5 }
# ])

# Forests in Space and Time (Fischer)
# Forest Biodiversity (Chirici)
# Remote Sensing for GHG Inventories (McRoberts)
# Forest Functional Traits/Spectroscopy (Townsend)
# Forest Carbon MRV (Poulter)
# Near Real-Time Monitoring (Reiche)
# Early Detection of Plant Stress (Suarez)
# Mangroves (Lucas)
# Monitoring Tropical Forest Dynamics (Hansen)
# Sensor Fusion for Global Forest Structure (Healey)
# Terrestrial Laser Scanning (Disney)
# Other/Plenary

# Analytical Methods
# Forest Structure and Biomass
# Forest Cover & Biomass Change
# Characterizing Uncertainty
# Climate-Vegetation Interactions
# Land and Forest Cover Mapping
# Deforestation & Land Use Change
# Disturbance
# Fire Dynamics and Impacts
# Forest Health
# Forest Monitoring
# Habitat and Biodiversity
# Forest Composition and Traits
# Function and Physiology
# Large Area Mapping
# Recovery and Growth
# Sampling & Estimation
# Science & Decision Support
# Carbon and Water Cycling
# In Situ Measurements
# UAVs and New Technologies
# Multi- and Hyperspectral Remote Sensing
# Radar Remote Sensing
# Lidar Remote Sensing
