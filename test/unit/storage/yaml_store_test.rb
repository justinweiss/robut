require 'test_helper'
require 'robut/storage/yaml_store'

class Robut::Storage::YamlStoreTest < Test::Unit::TestCase

  def setup
    @store = Robut::Storage::YamlStore
    @store.file = new_yaml_file
  end
  
  def teardown
    File.delete new_yaml_file if File.exists?(new_yaml_file)
  end

  def test_can_write_and_read
    assert_equal 'in the trunk', (@store['junk'] = 'in the trunk')
    assert_equal 'in the trunk', @store['junk']
  end
  
  def test_read_from_file
    @store.file = test_yaml_file
    assert_equal 'bar', @store['foo']
  end
  
  def test_persists_to_file
    @store['pot'] = 'roast'
    assert File.exists?(new_yaml_file)
    yaml = YAML.load_file(new_yaml_file)
    assert_equal 'roast', yaml['pot']
  end
  
  private
  
  def test_yaml_file
    File.join(File.dirname(__FILE__), 'yaml_test.yml')
  end
  
  def new_yaml_file
    File.join(File.dirname(__FILE__), 'new_yaml_test.yml')
  end
  
end