require 'test_helper'
require 'robut/plugin/alias'
require 'robut/plugin/echo'

class Robut::Plugin::AliasTest < Test::Unit::TestCase

  def setup
    @connection = Robut::ConnectionMock.new
    @plugin = Robut::Plugin::Alias.new(@connection)
    @plugin.aliases = {}
  end
  
  def test_aliases_this_to_that
    @plugin.handle(Time.now, "@john", "@robut alias w weather?")
    assert_equal 'weather?', @plugin.aliases['w']
  end
  
  def test_thinks_this_is_that
    @plugin.handle(Time.now, "@john", "@robut alias this @robut echo that")
    @plugin.handle(Time.now, "@john", "this")
    message = @plugin.connection.messages.first
    assert_equal "@john", message[1]
    assert_equal "@robut echo that", message[2]
  end
  
  def test_doesnt_alias_when_it_shouldnt
    @plugin.handle(Time.now, "@john", "@robut somthing alias w weather?")
    assert @plugin.aliases.empty?
  end  
  
  def test_can_alias_with_quotes
    @plugin.handle(Time.now, "@john", '@robut alias "long string" "some other long string"')
    assert_equal 'some other long string', @plugin.aliases['long string']
  end
  
  def test_can_apply_aliases_with_quotes
    @plugin.handle(Time.now, "@john", '@robut alias "long string" "some other long string"')
    @plugin.handle(Time.now, "@john", "long string")
    message = @plugin.connection.messages.first
    assert_equal "@john", message[1]
    assert_equal "some other long string", message[2]    
  end
  
  def test_aliases_can_be_removed
    @plugin.handle(Time.now, "@john", "@robut alias this that")
    @plugin.handle(Time.now, "@john", "@robut remove alias this")
    assert @plugin.aliases.empty?
  end
  
  def test_remove_aliases_doesnt_choke_on_missing_key
    @plugin.handle(Time.now, "@john", "@robut alias this that")
    @plugin.handle(Time.now, "@john", "@robut remove alias")
    assert_equal({'this' => 'that'}, @plugin.aliases)
  end
  
  def test_remove_alias_handles_quotes
    @plugin.handle(Time.now, "@john", '@robut alias "long string" "that"')
    @plugin.handle(Time.now, "@john", '@robut remove alias "long string"')
    assert @plugin.aliases.empty?
  end
  
  def test_can_list_all_aliases
    @plugin.handle(Time.now, "@john", "@robut alias this that")
    @plugin.handle(Time.now, "@john", "@robut alias something something else")
    @plugin.handle(Time.now, "@john", "@robut aliases")
    assert_equal ["this => that\nsomething => something else"], @plugin.connection.replies
  end
  
  def test_can_clear_aliases
    @plugin.handle(Time.now, "@john", "@robut alias this that")
    @plugin.handle(Time.now, "@john", "@robut clear aliases")
    assert_equal({}, @plugin.aliases)
  end
  
end
