require 'spec_helper'

describe Movie do
  describe 'searching by director' do
    it 'should call where method' do           
      Movie.should_receive(:where).with({:director =>'Fake director'})
      Movie.search_by_director('Fake director')
    end 
    it 'shold return nil if there aren not movies whit the director' do            
      Movie.stub!(:where).with({:director =>'Fake director'}).and_return(nil)
      assert Movie.search_by_director('Fake director') == nil  
    end
    it 'should return movies with same director if movies with same director exists' do
      fake_results = [mock('Movie'), mock('Movie')]
      Movie.stub!(:where).with({:director =>'Fake director'}).and_return(fake_results)
      assert Movie.search_by_director('Fake director') == fake_results      
    end
  end
end