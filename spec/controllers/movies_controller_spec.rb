require 'spec_helper'

describe MoviesController do
  describe 'Home page' do
    it 'should change session if sort order has been changed to title' do
      session[:sort] = 'release_date'
      get :index, {:sort => 'title'}
      session[:sort] == 'title'
    end
    
    it 'should change session if sort order has been changed to release_date' do
      session[:sort] = 'title'
      get :index, {:sort => 'release_date'}
      session[:sort] == 'release_date'
    end
    
    it 'should make the movies availables to home page' do
      fake_results = [mock('Movie'), mock('Movie')]        
      Movie.stub(:find_all_by_rating).and_return(fake_results)              
      get :index
      assigns(:movies).should == fake_results
    end
    
    it 'should call the model method that performs a search for movies by rating' do            
      Movie.should_receive(:find_all_by_rating).with([], nil)              
      get :index      
    end    
    
    it 'should call the model method that performs a search for movies by rating whit sort by release_date' do      
      session[:sort] = 'release_date'        
      Movie.should_receive(:find_all_by_rating).with([], {:order => :release_date})              
      get :index, {:sort => 'release_date'}      
    end
    
    it 'should call the model method that performs a search for movies by rating whit sort by title' do
      session[:sort] = 'title'        
      Movie.should_receive(:find_all_by_rating).with([], {:order => :title})           
      get :index, {:sort => 'title'}      
    end
        
    it 'should redirect if selected ratings are changed' do
      get :index, {:ratings => {:G => 1}}
      response.should redirect_to(movies_path(:ratings => {:G => 1}))
    end
  end 
    
  describe 'Delete movie' do
    it 'should delete the selected movie' do
      movie = mock('Movie')
      movie.stub!(:title)
      
      Movie.should_receive(:find).with('13').and_return(movie)
      movie.should_receive(:destroy)
      post :destroy, {:id => '13'}
      response.should redirect_to(movies_path)
    end
  end
  
  describe 'Create page' do
    it 'should redirect to movies path' do
      mock_movie = mock('Movie') 
      mock_movie.stub(:title)
      Movie.should_receive(:create!).and_return(mock_movie)
      post :create, {:movie => mock_movie}
      response.should redirect_to(movies_path)
    end
  end
  
  describe 'Update page' do
    it 'should redirect to movie path' do
      mock_movie = mock('Movie')       
      mock_movie.stub(:title) 
      mock_movie.stub(:id).and_return(13)
      mock_movie.stub(:update_attributes!).and_return(mock_movie)
      Movie.should_receive(:find).with('13').and_return(mock_movie)         
      post :update, {:id => 13, :movie => mock_movie}
      response.should redirect_to(movie_path(mock_movie))
    end
  end
  
  describe 'Edit page' do
    it 'should make movie available to edit page' do
      mock_movie = mock('Movie')
      Movie.stub(:find).with('13').and_return(mock_movie)            
      get :show, {:id => '13'}     
      assigns(:movie).should == mock_movie
    end
  end
  
  describe 'Show page' do
    it 'should make movie available to show page' do
      mock_movie = mock('Movie')
      Movie.stub(:find).with('13').and_return(mock_movie)            
      get :edit, {:id => '13'}     
      assigns(:movie).should == mock_movie
    end
  end
  
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