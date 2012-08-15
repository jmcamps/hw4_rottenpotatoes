# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)    
  end  
end

Then /the director of "(.*)" should be "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string. 
  movie = Movie.find_by_title(e1)
  assert(movie.director == e2, "expected: #{e2} but found #{movie.director}")
end