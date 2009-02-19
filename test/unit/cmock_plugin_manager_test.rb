require File.expand_path(File.dirname(__FILE__)) + "/../test_helper"
require File.expand_path(File.dirname(__FILE__)) + "/../../lib/cmock_plugin_manager"

class CMockPluginManagerTest < Test::Unit::TestCase
  def setup
    create_mocks :config, :utils, :pluginA, :pluginB
    @config.stubs!(:respond_to?).returns(true)
  end

  def teardown
  end
  
  should "return all plugins by default" do
    @config.stubs!(:tab).returns("  ")
    @config.expect.plugins.returns(['cexception','ignore'])
    @utils.expect.helpers.returns({})
    
    @cmock_plugins = CMockPluginManager.new(@config, @utils)

    test_plugins = @cmock_plugins.plugins
    contained = { :expect => false, :ignore => false, :cexception => false }
    test_plugins.each do |plugin|
      contained[:expect]     = true   if plugin.instance_of?(CMockGeneratorPluginExpect)
      contained[:ignore]     = true   if plugin.instance_of?(CMockGeneratorPluginIgnore)
      contained[:cexception] = true   if plugin.instance_of?(CMockGeneratorPluginCException)
    end
    assert_equal(true, contained[:expect])
    assert_equal(true, contained[:ignore])
    assert_equal(true, contained[:cexception])
  end
  
  should "return restricted plugins based on config" do
    @config.stubs!(:tab).returns("  ")
    @config.expect.plugins.returns([])
    @utils.expect.helpers.returns({})
    
    @cmock_plugins = CMockPluginManager.new(@config, @utils)
    
    test_plugins = @cmock_plugins.plugins
    contained = { :expect => false, :ignore => false, :cexception => false }
    test_plugins.each do |plugin|
      contained[:expect]     = true   if plugin.instance_of?(CMockGeneratorPluginExpect)
      contained[:ignore]     = true   if plugin.instance_of?(CMockGeneratorPluginIgnore)
      contained[:cexception] = true   if plugin.instance_of?(CMockGeneratorPluginCException)
    end
    assert_equal(true, contained[:expect])
    assert_equal(false,contained[:ignore])
    assert_equal(false,contained[:cexception])
  end
  
  should "run a desired method over each plugin requested and return the results" do
    @config.stubs!(:tab).returns("  ")
    @config.expect.plugins.returns([])
    @utils.expect.helpers.returns({})
    @cmock_plugins = CMockPluginManager.new(@config, @utils)
    
    @cmock_plugins.plugins = [@pluginA, @pluginB]
    @pluginA.stubs!(:test_method).returns("This Is An Awesome Test")
    @pluginB.stubs!(:test_method).returns(["And This is Part 2","Of An Awesome Test"])
    
    expected = ["This Is An Awesome Test","And This is Part 2","Of An Awesome Test"]
    output   = @cmock_plugins.run(:test_method)
    assert_equal(expected, output.flatten)
  end
  
  should "run a desired method and arg list over each plugin requested and return the results" do
    @config.stubs!(:tab).returns("  ")
    @config.expect.plugins.returns([])
    @utils.expect.helpers.returns({})
    @cmock_plugins = CMockPluginManager.new(@config, @utils)
    
    @cmock_plugins.plugins = [@pluginA, @pluginB]
    @pluginA.stubs!(:test_method).returns("This Is An Awesome Test")
    @pluginB.stubs!(:test_method).returns(["And This is Part 2","Of An Awesome Test"])
    
    expected = ["This Is An Awesome Test","And This is Part 2","Of An Awesome Test"]
    output   = @cmock_plugins.run(:test_method, "chickenpotpie")
    assert_equal(expected, output.flatten)
  end
end
