Rails.application.routes.draw do

    get "/" => "users#home"
    get "/faq" => "users#faq"
    get "/home" => "users#home"
    get "/new_user" => "users#new"
    get "/signed_in_msg" => "users#signed_in_msg"

    devise_for :users, :controllers => { :registrations => "registrations" }

    resources :users, :only => [:index, :show]
    resources :affiliations
    resources :presentations
    resources :keywords
    resources :authors
    resources :rooms

    get "/abstracts" => "abstracts#index"
    get "/my_abstracts/:my" => "abstracts#index"
    post "/my_abstracts" =>  "abstracts#index"

    get "/admin_functions" => "users#admin_functions"
    post "/process_admin_functions" => "users#process_admin_functions"

    get "/select_reviewers" =>  "users#select_reviewers"
    post "/save_selected_reviewers" =>  "users#save_selected_reviewers"
    get "/assign_reviewers" =>  "users#assign_reviewers"
    post "/save_assigned_reviewers" =>  "users#save_assigned_reviewers"

    get "/review_abstracts" =>  "abstracts#review_abstracts"
    get "/get_abs_comment" => "abstracts#get_abs_comment"
    get "/save_abs_comment" => "abstracts#save_abs_comment"
    post "/save_all_reviews" => "abstracts#save_all_reviews"

    get "/select_abstracts" =>  "abstracts#select_abstracts"
    get "/get_reviewer_comments/:abstract_id/:reviewer" =>  "abstracts#get_reviewer_comments"
    get "/filter_by_keyword" =>  "abstracts#select_abstracts"
    post "/filter_by_keyword" =>  "abstracts#filter_by_keyword"
    post "/save_selection" =>  "abstracts#save_selection"

    post "/signup_abstract" => "abstracts#create"
    post "/save_abstract" => "abstracts#update"
    patch "/save_abstract" => "abstracts#update"

    get "/new_author_affiliation/:author_id" => "affiliations#new_author_affiliation"

    resources :abstracts

end
