require 'spec_helper'

describe MoviesController do
  describe 'searching by director' do
    before :each do
      @fake_results_with_movies = [mock('Movie'), mock('Movie')]
      @movie_with_director_stub = mock('Movie')          
      @movie_with_director_stub.stub!(:director).and_return('Fake director')
      @movie_without_director_stub = mock('Movie')
      @movie_without_director_stub.stub!(:title).and_return('Fake title') 
      @movie_without_director_stub.stub!(:director).and_return(nil)
    end
    
    it 'should call the model method that performs a search for movies with same director' do             
      Movie.should_receive(:find).with('13').and_return(@movie_with_director_stub)
      Movie.should_receive(:search_by_director).with(@movie_with_director_stub.director).and_return(@fake_results_with_movies)      
      get :search_by_director, {:id => '13'}      
    end 
    
    it 'shold select the Similar Movies template for rendering if has director' do           
      Movie.stub(:find).and_return(@movie_with_director_stub)
      Movie.stub(:search_by_director).and_return(@fake_results_with_movies)
      get :search_by_director, {:id => '13'}      
      response.should render_template('search_by_director')
    end
    
    it 'should make the movies with same director availables to Similar Movies template' do           
      Movie.stub(:find).and_return(@movie_with_director_stub)
      Movie.stub(:search_by_director).and_return(@fake_results_with_movies)      
      get :search_by_director, {:id => '13'}     
      assigns(:movies).should == @fake_results_with_movies      
    end
    
    it 'shold select the Index template for rendering if has no director' do           
      Movie.stub(:find).and_return(@movie_without_director_stub)      
      get :search_by_director, {:id => '13'}
      response.should redirect_to(movies_path)
    end
    
    it 'shold select the Index template for rendering if director is empty string and not null' do  
      @movie_without_director_stub.stub!(:director).and_return('')         
      Movie.stub(:find).and_return(@movie_without_director_stub)      
      get :search_by_director, {:id => '13'}
      response.should redirect_to(movies_path)
    end
    
    it 'shold show message to user if has no director' do      
      Movie.stub(:find).and_return(@movie_without_director_stub)      
      get :search_by_director, {:id => '13'}
      flash[:notice].should =~ /'Fake title' has no director info/i
    end  
  end
end