require 'test_helper'
require 'robut/storage/hash_store'

class Robut::Storage::HashStoreTest < Test::Unit::TestCase

  def setup
    @store = Robut::Storage::HashStore
  end
  
  def test_can_write_and_read
    assert_equal 'in the trunk', (@store['junk'] = 'in the trunk')
    assert_equal 'in the trunk', @store['junk']
  end
    
end